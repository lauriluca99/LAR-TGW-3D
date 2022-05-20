# Attributes that can be associated with parameters, function results, or the function
# itself.

export Attribute,
       EnumAttribute, StringAttribute, TypeAttribute,
       kind, value

abstract type Attribute end

Base.unsafe_convert(::Type{API.LLVMAttributeRef}, attr::Attribute) = attr.ref

@checked struct EnumAttribute <: Attribute
    ref::API.LLVMAttributeRef
end

@checked struct StringAttribute <: Attribute
    ref::API.LLVMAttributeRef
end

@checked struct TypeAttribute <: Attribute
    ref::API.LLVMAttributeRef
end

# TODO: make the identify mechanism flexible enough to cover cases like this one,
#       and not only Value and Type

function Attribute(ref::API.LLVMAttributeRef)
    ref == C_NULL && throw(UndefRefError())
    if convert(Core.Bool, API.LLVMIsEnumAttribute(ref))
        return EnumAttribute(ref)
    elseif convert(Core.Bool, API.LLVMIsStringAttribute(ref))
        return StringAttribute(ref)
    else
        @static if LLVM.version() >= v"12"
            if convert(Core.Bool, API.LLVMIsTypeAttribute(ref))
                return TypeAttribute(ref)
            end
        end
        error("unknown attribute kind")
    end
end

function Base.show(io::IO, attr::T) where T<:Attribute
    print(io, "$T $(kind(attr))=$(value(attr))")
end


## enum attribute

# NOTE: the AttrKind enum is not exported in the C API,
#       so we don't expose a way to construct EnumAttribute from its raw enum value
#       (which also would conflict with the inner ref constructor)
function EnumAttribute(kind::String, value::Integer=0; ctx::Context)
    enum_kind = API.LLVMGetEnumAttributeKindForName(kind, Csize_t(length(kind)))
    return EnumAttribute(API.LLVMCreateEnumAttribute(ctx, enum_kind, UInt64(value)))
end

kind(attr::EnumAttribute) = API.LLVMGetEnumAttributeKind(attr)

value(attr::EnumAttribute) = API.LLVMGetEnumAttributeValue(attr)


## string attribute

StringAttribute(kind::String, value::String=""; ctx::Context) =
    StringAttribute(API.LLVMCreateStringAttribute(ctx, kind, length(kind),
                                                  value, length(value)))

function kind(attr::StringAttribute)
    len = Ref{Cuint}()
    data = API.LLVMGetStringAttributeKind(attr, len)
    return unsafe_string(convert(Ptr{Int8}, data), len[])
end

function value(attr::StringAttribute)
    len = Ref{Cuint}()
    data = API.LLVMGetStringAttributeValue(attr, len)
    return unsafe_string(convert(Ptr{Int8}, data), len[])
end

## type attribute

function TypeAttribute(kind::String, value::LLVMType; ctx::Context)
    enum_kind = API.LLVMGetEnumAttributeKindForName(kind, Csize_t(length(kind)))
    return TypeAttribute(API.LLVMCreateTypeAttribute(ctx, enum_kind, value))
end

kind(attr::TypeAttribute) = API.LLVMGetEnumAttributeKind(attr)

function value(attr::TypeAttribute)
    return LLVMType(API.LLVMGetTypeAttributeValue(attr))
end
