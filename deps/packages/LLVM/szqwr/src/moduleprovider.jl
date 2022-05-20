export ModuleProvider, dispose

# TODO: use this class implicitly? ie. when passing Modules to functions expecting a
#       ModuleProvider. Especially because dispose(mp) destroys the underlying mod.

@checked struct ModuleProvider
    ref::API.LLVMModuleProviderRef
end

Base.unsafe_convert(::Type{API.LLVMModuleProviderRef}, mp::ModuleProvider) = mp.ref

ModuleProvider(mod::Module) =
    ModuleProvider(API.LLVMCreateModuleProviderForExistingModule(mod))

function ModuleProvider(f::Core.Function, args...; kwargs...)
    mp = ModuleProvider(args...; kwargs...)
    try
        f(mp)
    finally
        dispose(mp)
    end
end

# NOTE: this destroys the underlying module
dispose(mp::ModuleProvider) = API.LLVMDisposeModuleProvider(mp)
