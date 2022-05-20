
#include "Orc.h"

#if LLVM_VERSION_MAJOR == 12
#include "LLJIT.h"
#include "llvm-c/LLJIT.h"
#include "llvm-c/Orc.h"
#include "llvm-c/OrcEE.h"
#include "llvm-c/TargetMachine.h"

#include "llvm/ExecutionEngine/Orc/LLJIT.h"
#include "llvm/ExecutionEngine/Orc/Core.h"
#include "llvm/Support/CBindingWrapping.h"

using namespace llvm;
using namespace llvm::orc;

namespace llvm {
namespace orc {

class InProgressLookupState;

class OrcV2CAPIHelper {
public:
  using PoolEntry = SymbolStringPtr::PoolEntry;
  using PoolEntryPtr = SymbolStringPtr::PoolEntryPtr;

  // Move from SymbolStringPtr to PoolEntryPtr (no change in ref count).
  static PoolEntryPtr moveFromSymbolStringPtr(SymbolStringPtr S) {
    PoolEntryPtr Result = nullptr;
    std::swap(Result, S.S);
    return Result;
  }

  // Move from a PoolEntryPtr to a SymbolStringPtr (no change in ref count).
  static SymbolStringPtr moveToSymbolStringPtr(PoolEntryPtr P) {
    SymbolStringPtr S;
    S.S = P;
    return S;
  }

  // Copy a pool entry to a SymbolStringPtr (increments ref count).
  static SymbolStringPtr copyToSymbolStringPtr(PoolEntryPtr P) {
    return SymbolStringPtr(P);
  }

  static PoolEntryPtr getRawPoolEntryPtr(const SymbolStringPtr &S) {
    return S.S;
  }

  static void retainPoolEntry(PoolEntryPtr P) {
    SymbolStringPtr S(P);
    S.S = nullptr;
  }

  static void releasePoolEntry(PoolEntryPtr P) {
    SymbolStringPtr S;
    S.S = P;
  }

  static InProgressLookupState *extractLookupState(LookupState &LS) {
    return LS.IPLS.release();
  }

  static void resetLookupState(LookupState &LS, InProgressLookupState *IPLS) {
    return LS.reset(IPLS);
  }
};

} // namespace orc
} // namespace llvm

DEFINE_SIMPLE_CONVERSION_FUNCTIONS(ExecutionSession, LLVMOrcExecutionSessionRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(SymbolStringPool, LLVMOrcSymbolStringPoolRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(OrcV2CAPIHelper::PoolEntry,
                                   LLVMOrcSymbolStringPoolEntryRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(MaterializationUnit,
                                   LLVMOrcMaterializationUnitRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(MaterializationResponsibility,
                                   LLVMOrcMaterializationResponsibilityRef)

DEFINE_SIMPLE_CONVERSION_FUNCTIONS(JITDylib, LLVMOrcJITDylibRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(ResourceTracker, LLVMOrcResourceTrackerRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(DefinitionGenerator,
                                   LLVMOrcDefinitionGeneratorRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(InProgressLookupState, LLVMOrcLookupStateRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(ThreadSafeContext,
                                   LLVMOrcThreadSafeContextRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(ThreadSafeModule, LLVMOrcThreadSafeModuleRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(JITTargetMachineBuilder,
                                   LLVMOrcJITTargetMachineBuilderRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(ObjectLayer, LLVMOrcObjectLayerRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(IRTransformLayer, LLVMOrcIRTransformLayerRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(IndirectStubsManager,
                                   LLVMOrcIndirectStubsManagerRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(LazyCallThroughManager,
                                   LLVMOrcLazyCallThroughManagerRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(LLJITBuilder, LLVMOrcLLJITBuilderRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(LLJIT, LLVMOrcLLJITRef)
DEFINE_SIMPLE_CONVERSION_FUNCTIONS(TargetMachine, LLVMTargetMachineRef)

namespace {

class OrcCAPIMaterializationUnit : public llvm::orc::MaterializationUnit {
public:
  OrcCAPIMaterializationUnit(
      std::string Name, SymbolFlagsMap InitialSymbolFlags,
      SymbolStringPtr InitSymbol, void *Ctx,
      LLVMOrcMaterializationUnitMaterializeFunction Materialize,
      LLVMOrcMaterializationUnitDiscardFunction Discard,
      LLVMOrcMaterializationUnitDestroyFunction Destroy)
      : llvm::orc::MaterializationUnit(std::move(InitialSymbolFlags),
                                       std::move(InitSymbol)),
        Name(std::move(Name)), Ctx(Ctx), Materialize(Materialize),
        Discard(Discard), Destroy(Destroy) {}

  ~OrcCAPIMaterializationUnit() {
    if (Ctx)
      Destroy(Ctx);
  }

  StringRef getName() const override { return Name; }

  void materialize(std::unique_ptr<MaterializationResponsibility> R) override {
    void *Tmp = Ctx;
    Ctx = nullptr;
    Materialize(Tmp, wrap(R.release()));
  }

private:
  void discard(const JITDylib &JD, const SymbolStringPtr &Name) override {
    Discard(Ctx, wrap(&JD), wrap(OrcV2CAPIHelper::getRawPoolEntryPtr(Name)));
  }

  std::string Name;
  void *Ctx = nullptr;
  LLVMOrcMaterializationUnitMaterializeFunction Materialize = nullptr;
  LLVMOrcMaterializationUnitDiscardFunction Discard = nullptr;
  LLVMOrcMaterializationUnitDestroyFunction Destroy = nullptr;
};

static JITSymbolFlags toJITSymbolFlags(LLVMJITSymbolFlags F) {

  JITSymbolFlags JSF;

  if (F.GenericFlags & LLVMJITSymbolGenericFlagsExported)
    JSF |= JITSymbolFlags::Exported;
  if (F.GenericFlags & LLVMJITSymbolGenericFlagsWeak)
    JSF |= JITSymbolFlags::Weak;
  if (F.GenericFlags & LLVMJITSymbolGenericFlagsCallable)
    JSF |= JITSymbolFlags::Callable;
  if (F.GenericFlags & LLVMJITSymbolGenericFlagsMaterializationSideEffectsOnly)
    JSF |= JITSymbolFlags::MaterializationSideEffectsOnly;

  JSF.getTargetFlags() = F.TargetFlags;

  return JSF;
}

  static SymbolMap toSymbolMap(LLVMOrcCSymbolMapPairs Syms, size_t NumPairs) {
    SymbolMap SM;
    for (size_t I = 0; I != NumPairs; ++I) {
      JITSymbolFlags Flags = toJITSymbolFlags(Syms[I].Sym.Flags);
      SM[OrcV2CAPIHelper::moveToSymbolStringPtr(unwrap(Syms[I].Name))] =
          JITEvaluatedSymbol(Syms[I].Sym.Address, Flags);
    }
    return SM;
  }

} // end anonymous namespace

LLVMOrcMaterializationUnitRef LLVMOrcCreateCustomMaterializationUnit(
    const char *Name, void *Ctx, LLVMOrcCSymbolFlagsMapPairs Syms,
    size_t NumSyms, LLVMOrcSymbolStringPoolEntryRef InitSym,
    LLVMOrcMaterializationUnitMaterializeFunction Materialize,
    LLVMOrcMaterializationUnitDiscardFunction Discard,
    LLVMOrcMaterializationUnitDestroyFunction Destroy) {
  SymbolFlagsMap SFM;
  for (size_t I = 0; I != NumSyms; ++I)
    SFM[OrcV2CAPIHelper::moveToSymbolStringPtr(unwrap(Syms[I].Name))] =
        toJITSymbolFlags(Syms[I].Flags);

  auto IS = OrcV2CAPIHelper::moveToSymbolStringPtr(unwrap(InitSym));

  return wrap(new OrcCAPIMaterializationUnit(
      Name, std::move(SFM), std::move(IS), Ctx, Materialize, Discard, Destroy));
}
LLVMOrcMaterializationUnitRef LLVMOrcLazyReexports(
    LLVMOrcLazyCallThroughManagerRef LCTM, LLVMOrcIndirectStubsManagerRef ISM,
    LLVMOrcJITDylibRef SourceJD, LLVMOrcCSymbolAliasMapPairs CallableAliases,
    size_t NumPairs) {

  SymbolAliasMap SAM;
  for (size_t I = 0; I != NumPairs; ++I) {
    auto pair = CallableAliases[I];
    JITSymbolFlags Flags = toJITSymbolFlags(pair.Entry.Flags);
    SymbolStringPtr Name =
        OrcV2CAPIHelper::moveToSymbolStringPtr(unwrap(pair.Entry.Name));
    SAM[OrcV2CAPIHelper::moveToSymbolStringPtr(unwrap(pair.Name))] =
        SymbolAliasMapEntry(Name, Flags);
  }

  return wrap(lazyReexports(*unwrap(LCTM), *unwrap(ISM), *unwrap(SourceJD),
                            std::move(SAM))
                  .release());
}

LLVMOrcIRTransformLayerRef LLVMOrcLLJITGetIRTransformLayer(LLVMOrcLLJITRef J) {
  return wrap(&unwrap(J)->getIRTransformLayer());
}

void LLVMOrcIRTransformLayerEmit(LLVMOrcIRTransformLayerRef IRLayer,
                                 LLVMOrcMaterializationResponsibilityRef MR,
                                 LLVMOrcThreadSafeModuleRef TSM) {
  std::unique_ptr<ThreadSafeModule> TmpTSM(unwrap(TSM));
  unwrap(IRLayer)->emit(
      std::unique_ptr<MaterializationResponsibility>(unwrap(MR)),
      std::move(*TmpTSM));
}

LLVMErrorRef
LLVMOrcThreadSafeModuleWithModuleDo(LLVMOrcThreadSafeModuleRef TSM,
                                    LLVMOrcGenericIRModuleOperationFunction F,
                                    void *Ctx) {
  return wrap(unwrap(TSM)->withModuleDo(
      [&](Module &M) { return unwrap(F(Ctx, wrap(&M))); }));
}

LLVMErrorRef LLVMOrcLLJITApplyDataLayout(LLVMOrcLLJITRef JIT, LLVMModuleRef Mod) {
  Module &M = *unwrap(Mod);
  LLJIT &J = *unwrap(JIT);
  DataLayout DL = J.getDataLayout();
  if (M.getDataLayout().isDefault()) {
      M.setDataLayout(DL);
  }

  if (M.getDataLayout() != DL) {
      return wrap(
        make_error<StringError>(
          "Added modules have incompatible DL",
          inconvertibleErrorCode()));
  }
  return wrap(Error::success());
}

LLVMOrcIndirectStubsManagerRef
LLVMOrcCreateLocalIndirectStubsManager(const char *TargetTriple) {
  auto builder = createLocalIndirectStubsManagerBuilder(Triple(TargetTriple));
  return wrap(builder().release());
}

void LLVMOrcDisposeIndirectStubsManager(LLVMOrcIndirectStubsManagerRef ISM) {
  std::unique_ptr<IndirectStubsManager> TmpISM(unwrap(ISM));
}

LLVMErrorRef LLVMOrcCreateLocalLazyCallThroughManager(
    const char *TargetTriple, LLVMOrcExecutionSessionRef ES,
    LLVMOrcJITTargetAddress ErrorHandlerAddr,
    LLVMOrcLazyCallThroughManagerRef *Result) {
    auto LCTM = createLocalLazyCallThroughManager(
      Triple(TargetTriple), *unwrap(ES), ErrorHandlerAddr);

    if (!LCTM) {
      return wrap(LCTM.takeError());
    }
    *Result = wrap(LCTM->release());
    return LLVMErrorSuccess;
}

void LLVMOrcDisposeLazyCallThroughManager(LLVMOrcLazyCallThroughManagerRef LCM) {
  std::unique_ptr<LazyCallThroughManager> TmpLCM(unwrap(LCM));
}

LLVMOrcJITDylibRef LLVMOrcMaterializationResponsibilityGetTargetDylib(
    LLVMOrcMaterializationResponsibilityRef MR) {
  return wrap(&unwrap(MR)->getTargetJITDylib());
}

LLVMOrcExecutionSessionRef
LLVMOrcMaterializationResponsibilityGetExecutionSession(
    LLVMOrcMaterializationResponsibilityRef MR) {
  return wrap(&unwrap(MR)->getExecutionSession());
}

LLVMOrcCSymbolFlagsMapPairs LLVMOrcMaterializationResponsibilityGetSymbols(
    LLVMOrcMaterializationResponsibilityRef MR, size_t *NumPairs) {

  auto Symbols = unwrap(MR)->getSymbols();
  LLVMOrcCSymbolFlagsMapPairs Result = static_cast<LLVMOrcCSymbolFlagsMapPairs>(
      safe_malloc(Symbols.size() * sizeof(LLVMOrcCSymbolFlagsMapPair)));
  size_t I = 0;
  for (auto const &pair : Symbols) {
    auto Name = wrap(OrcV2CAPIHelper::getRawPoolEntryPtr(pair.first));
    auto Flags = pair.second;
    Result[I] = {Name, {Flags.getRawFlagsValue(), Flags.getTargetFlags()}};
    I++;
  }
  *NumPairs = Symbols.size();
  return Result;
}

void LLVMOrcDisposeCSymbolFlagsMap(LLVMOrcCSymbolFlagsMapPairs Pairs) {
  free(Pairs);
}

LLVMOrcSymbolStringPoolEntryRef
LLVMOrcMaterializationResponsibilityGetInitializerSymbol(
    LLVMOrcMaterializationResponsibilityRef MR) {
  auto Sym = unwrap(MR)->getInitializerSymbol();
  return wrap(OrcV2CAPIHelper::getRawPoolEntryPtr(Sym));
}

LLVMOrcSymbolStringPoolEntryRef *
LLVMOrcMaterializationResponsibilityGetRequestedSymbols(
    LLVMOrcMaterializationResponsibilityRef MR, size_t *NumSymbols) {

  auto Symbols = unwrap(MR)->getRequestedSymbols();
  LLVMOrcSymbolStringPoolEntryRef *Result =
      static_cast<LLVMOrcSymbolStringPoolEntryRef *>(safe_malloc(
          Symbols.size() * sizeof(LLVMOrcSymbolStringPoolEntryRef)));
  size_t I = 0;
  for (auto &Name : Symbols) {
    Result[I] = wrap(OrcV2CAPIHelper::getRawPoolEntryPtr(Name));
    I++;
  }
  *NumSymbols = Symbols.size();
  return Result;
}

void LLVMOrcDisposeSymbols(LLVMOrcSymbolStringPoolEntryRef *Symbols) {
  free(Symbols);
}

LLVMErrorRef LLVMOrcMaterializationResponsibilityNotifyResolved(
    LLVMOrcMaterializationResponsibilityRef MR, LLVMOrcCSymbolMapPairs Symbols,
    size_t NumPairs) {
  SymbolMap SM = toSymbolMap(Symbols, NumPairs);
  return wrap(unwrap(MR)->notifyResolved(std::move(SM)));
}

LLVMErrorRef LLVMOrcMaterializationResponsibilityNotifyEmitted(
    LLVMOrcMaterializationResponsibilityRef MR) {
  return wrap(unwrap(MR)->notifyEmitted());
}

void LLVMOrcMaterializationResponsibilityFailMaterialization(
    LLVMOrcMaterializationResponsibilityRef MR) {
  unwrap(MR)->failMaterialization();
}

#endif // LLVM_VERSION_MAJOR == 12
