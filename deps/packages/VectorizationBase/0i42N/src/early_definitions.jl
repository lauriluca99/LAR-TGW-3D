_ispow2(x::Integer) = count_ones(x) < 2
@generated _ispow2(::StaticInt{N}) where {N} = Expr(:call, ispow2(N) ? :True : :False)

function integer_of_bytes_symbol(bytes::Int, unsigned::Bool = false)
  if bytes ≥ 8
    unsigned ? :UInt64 : :Int64
  elseif bytes ≥ 4
    unsigned ? :UInt32 : :Int32
  elseif bytes ≥ 2
    unsigned ? :UInt16 : :Int16
  elseif bytes ≥ 1
    unsigned ? :UInt8 : :Int8
  else
    throw("$bytes is an invalid number of bytes for integers.")
  end
end
function integer_of_bytes(bytes::Int)
  if bytes ≥ 8
    Int64
  elseif bytes ≥ 4
    Int32
  elseif bytes ≥ 2
    Int16
  elseif bytes ≥ 1
    Int8
  else
    throw("$bytes is an invalid number of bytes for integers.")
  end
end
@generated int_type_bytes(::StaticInt{B}) where {B} = integer_of_bytes_symbol(B)
@inline int_type(::Union{Val{W},StaticInt{W}}) where {W} =
  int_type_bytes(simd_integer_register_size() ÷ StaticInt{W}())

@generated function _promote_rule(
  ::Val{W},
  ::Type{T2},
  ::StaticInt{RS},
  ::StaticInt{SIRS},
) where {W,T2<:NativeTypes,RS,SIRS}
  if RS ≥ sizeof(T2) * W
    return :(Vec{$W,$T2})
  elseif T2 <: Signed
    return :(Vec{$W,$(integer_of_bytes_symbol(max(1, SIRS ÷ W), false))})
  elseif T2 <: Unsigned
    return :(Vec{$W,$(integer_of_bytes_symbol(max(1, SIRS ÷ W), true))})
  else
    return :(Vec{$W,$T2})
  end
end
@inline function Base.promote_rule(
  ::Type{MM{W,X,I}},
  ::Type{T2},
) where {W,X,I,T2<:NativeTypes}
  _promote_rule(Val{W}(), T2, register_size(T2), simd_integer_register_size())
end

@inline integer_preference(::StaticInt{B}) where {B} =
  ifelse(ArrayInterface.ge(StaticInt{B}(), StaticInt{8}()), Int, Int32)

@inline pick_integer(::Union{StaticInt{W},Val{W}}) where {W} =
  integer_preference(simd_integer_register_size() ÷ StaticInt{W}())

@inline function pick_integer(::Val{W}, ::Type{T}) where {W,T}
  BT = static_sizeof(T)
  BW = register_size(T) ÷ StaticInt{W}()
  I = ifelse(le(BT, BW), T, int_type_bytes(smax(StaticInt{4}(), BW)))
  signorunsign(I, issigned(T))
end


function mask_type_symbol(W)
  if W <= 8
    return :UInt8
  elseif W <= 16
    return :UInt16
  elseif W <= 32
    return :UInt32
  elseif W <= 64
    return :UInt64
  elseif W <= 128
    return :UInt128
  elseif W <= 256
    return :UInt256
  elseif W <= 512
    return :UInt512
  else#if W <= 1024
    return :UInt1024
  end
end
function mask_type(W)
  if W <= 8
    return UInt8
  elseif W <= 16
    return UInt16
  elseif W <= 32
    return UInt32
  elseif W <= 64
    return UInt64
  elseif W <= 128
    return UInt128
  elseif W <= 256
    return UInt256
  elseif W <= 512
    return UInt512
  else#if W <= 1024
    return UInt1024
  end
end
mask_type(::Union{Val{1},StaticInt{1}}) = UInt8#Bool
mask_type(::Union{Val{2},StaticInt{2}}) = UInt8
mask_type(::Union{Val{4},StaticInt{4}}) = UInt8
mask_type(::Union{Val{8},StaticInt{8}}) = UInt8
mask_type(::Union{Val{16},StaticInt{16}}) = UInt16
mask_type(::Union{Val{24},StaticInt{24}}) = UInt32
mask_type(::Union{Val{32},StaticInt{32}}) = UInt32
mask_type(::Union{Val{40},StaticInt{40}}) = UInt64
mask_type(::Union{Val{48},StaticInt{48}}) = UInt64
mask_type(::Union{Val{56},StaticInt{56}}) = UInt64
mask_type(::Union{Val{64},StaticInt{64}}) = UInt64

@generated _mask_type(::StaticInt{W}) where {W} = mask_type_symbol(W)
@inline mask_type(::Type{T}) where {T} = _mask_type(pick_vector_width(T))
@inline mask_type(::Type{T}, ::Union{StaticInt{P},Val{P}}) where {T,P} =
  _mask_type(pick_vector_width(StaticInt{P}(), T))
