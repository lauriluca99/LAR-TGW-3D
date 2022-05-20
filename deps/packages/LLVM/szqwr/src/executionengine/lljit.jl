@checked struct LLJITBuilder
    ref::API.LLVMOrcLLJITBuilderRef
end
Base.unsafe_convert(::Type{API.LLVMOrcLLJITBuilderRef}, builder::LLJITBuilder) = builder.ref

@checked mutable struct LLJIT
    ref::API.LLVMOrcLLJITRef
end
Base.unsafe_convert(::Type{API.LLVMOrcLLJITRef}, lljit::LLJIT) = lljit.ref

function LLJITBuilder()
    ref = API.LLVMOrcCreateLLJITBuilder()
    LLJITBuilder(ref)
end

function dispose(builder::LLJITBuilder)
    API.LLVMOrcDisposeLLJITBuilder(builder)
end

function targetmachinebuilder!(builder::LLJITBuilder, tmb::TargetMachineBuilder)
    API.LLVMOrcLLJITBuilderSetJITTargetMachineBuilder(builder, tmb)
end

function linkinglayercreator!(builder::LLJITBuilder, callback, ctx)
    API.LLVMOrcLLJITBuilderSetObjectLinkingLayerCreator(builder, callback, ctx)
end

"""
    LLJIT(::LLJITBuilder)

Creates a LLJIT stack based on the provided builder.

!!! note
    Takes ownership of the provided builder.
"""
function LLJIT(builder::LLJITBuilder)
    ref = Ref{API.LLVMOrcLLJITRef}()
    @check API.LLVMOrcCreateLLJIT(ref, builder)
    LLJIT(ref[])
end

function dispose(lljit::LLJIT)
    API.LLVMOrcDisposeLLJIT(lljit)
end

"""
    LLJIT(;tm::Union{Nothing, TargetMachine})

Use the provided TargetMachine and construct an LLJIT from it.
"""
function LLJIT(; tm::Union{Nothing, TargetMachine} = nothing)
    builder = LLJITBuilder()
    if tm === nothing
        tmb = TargetMachineBuilder()
    else
        tmb = TargetMachineBuilder(tm)
    end
    targetmachinebuilder!(builder, tmb)
    LLJIT(builder)
end

function LLJIT(f::Core.Function, args...; kwargs...)
    lljit = LLJIT(args...; kwargs...)
    try
        f(lljit)
    finally
        dispose(lljit)
    end
end

function triple(lljit::LLJIT)
    cstr = API.LLVMOrcLLJITGetTripleString(lljit)
    Base.unsafe_string(cstr)
end

if version() < v"13"
function apply_datalayout!(lljit::LLJIT, mod::LLVM.Module)
    LLVM.API.LLVMOrcLLJITApplyDataLayout(lljit, mod)
end
else
function datalayout(lljit::LLJIT)
    Base.unsafe_string(API.LLVMOrcLLJITGetDataLayoutStr(lljit))
end
function apply_datalayout!(lljit::LLJIT, mod::LLVM.Module)
    datalayout!(mod, datalayout(lljit))
end
end

function get_prefix(lljit::LLJIT)
    return API.LLVMOrcLLJITGetGlobalPrefix(lljit)
end
