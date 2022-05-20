# Example of mutable types that can implement this API: BigInt, Array, JuMP.AffExpr, MultivariatePolynomials.AbstractPolynomial
# `mutable_operate!(add_mul, ...)` is similar to `JuMP.add_to_expression(...)`
# `operate!(add_mul, ...)` is similar to `JuMP.destructive_add(...)`
# `operate!` is similar to `MOI.Utilities.operate!`

# `promote_operation_fallback` gives fallbacks for any type with no risk of
# ambiguity with specific methods defined for a given type, even if these are
# quite broad in the allowed operations.
function promote_operation_fallback(op::Function, x::Type{<:AbstractArray}, y::Type{<:AbstractArray})
    # `zero` is not defined for `AbstractArray` so the fallback would fail with a cryptic MethodError.
    # We replace it by a more helpful error here.
    error("`promote_operation($op, $x, $y)` not implemented yet, please report this.")
end
function promote_operation_fallback(::typeof(/), ::Type{S}, ::Type{T}) where {S,T}
    return typeof(zero(S) / oneunit(T))
end
# Julia v1.0.x has trouble with inference with the `Vararg` method, see
# https://travis-ci.org/jump-dev/JuMP.jl/jobs/617606373
function promote_operation_fallback(op::F, ::Type{S}, ::Type{T}) where {F<:Function,S,T}
    return typeof(op(zero(S), zero(T)))
end
function promote_operation_fallback(op::F, args::Vararg{Type,N}) where {F<:Function,N}
    return typeof(op(zero.(args)...))
end
promote_operation_fallback(::typeof(*), ::Type{T}) where {T} = T
function promote_operation_fallback(
    ::typeof(*),
    ::Type{S},
    ::Type{T},
    ::Type{U},
    args::Vararg{Type,N},
) where {S,T,U,N}
    return promote_operation(*, promote_operation(*, S, T), U, args...)
end

# `Vararg` gives extra allocations on Julia v1.3, see https://travis-ci.com/jump-dev/MutableArithmetics.jl/jobs/260666164#L215-L238
function promote_operation_fallback(op::AddSubMul, T::Type, x::Type, y::Type)
    return promote_operation(add_sub_op(op), T, promote_operation(*, x, y))
end
function promote_operation_fallback(
    op::AddSubMul,
    x::Type{<:AbstractArray},
    y::Type{<:AbstractArray},
)
    return promote_operation(add_sub_op(op), x, y)
end
function promote_operation_fallback(op::Union{AddSubMul,typeof(add_dot)}, T::Type, args::Vararg{Type,N}) where {N}
    return promote_operation(reduce_op(op), T, promote_operation(map_op(op), args...))
end

"""
    promote_operation(op::Function, ArgsTypes::Type...)

Returns the type returned to the call `operate(op, args...)` where the types of
the arguments `args` are `ArgsTypes`.
"""
function promote_operation(op::F, args::Vararg{Type,N}) where {F<:Function,N}
    return promote_operation_fallback(op, args...)
end

# Helpful error for common mistake
function promote_operation(
    op::Union{typeof(+),typeof(-),AddSubMul},
    A::Type{<:Array},
    α::Type{<:Number},
)
    error("Operation `$op` between `$A` and `$α` is not allowed. You should use broadcast.")
end
function promote_operation(
    op::Union{typeof(+),typeof(-),AddSubMul},
    α::Type{<:Number},
    A::Type{<:Array},
)
    error("Operation `$op` between `$α` and `$A` is not allowed. You should use broadcast.")
end

"""
    operate(op::Function, args...)

Return an object equal to the result of `op(args...)` that can be mutated
through the MultableArithmetics API without affecting the arguments.

By default:
* `operate(+, x)` and `operate(+, x)` redirect to `copy_if_mutable(x)` so a
  mutable type `T` can return the same instance from unary operators
  `+(x::T) = x` and `*(x::T) = x`.
* `operate(+, args...)` (resp. `operate(-, args...)` and `operate(*, args...)`)
  redirect to `+(args...)` (resp. `-(args...)` and `*(args...)`) if `length(args)`
  is at least 2 (or the operation is `-`).

Note that when `op` is a `Base` function whose implementation can be improved
for mutable arguments, `operate(op, args...)` may have an implementation in
this package relying on the MutableArithmetics API instead of redirecting to
`op(args...)`. This is the case for instance:

* for `Base.sum`,
* for `LinearAlgebra.dot` and
* for matrix-matrix product and matrix-vector product.

Therefore, for mutable arguments, there may be a performance advantage to call
`operate(op, args...)` instead of `op(args...)`.

## Example

If for a mutable type `T`, the following is defined:
```julia
function Base.:*(a::Bool, x::T)
    return a ? x : zero(T)
end
```
then `operate(*, a, x)` will return the instance `x` whose modification will
affect the argument of `operate`. Therefore, the following method need to
be implemented
```julia
function MA.operate(::typeof(*), a::Bool, x::T)
    return a ? MA.mutable_copy(x) : zero(T)
end
```
"""
function operate end

# /!\ We assume these three return an object that can be modified through the MA
#     API without altering `x` and `y`. If it is not the case, implement a
#     custom `operate` method.
operate(::typeof(-), x) = -x
operate(
    op::Union{typeof(+),typeof(-),typeof(*),AddSubMul,typeof(add_dot)},
    x,
    y,
    args::Vararg{Any,N},
) where {N} = op(x, y, args...)
operate(::typeof(convert), ::Type{T}, x) where {T} = convert(T, x)
operate(::typeof(convert), ::Type{T}, x::T) where {T} = copy_if_mutable(x)

operate(::Union{typeof(+),typeof(*)}, x) = copy_if_mutable(x)

# We could only give `typeof(x)` to `zero` and `one` to be sure that modifying the
# returned object cannot alter `x` but for some objects, `one` and `zero` depends
# on some values of the fields (e.g. square matrices), elements of the cyclic group
# of order `n` (`n` is one of the field).
operate(::typeof(zero), x) = zero(x)
operate(::typeof(one), x) = one(x)

# Define Traits

"""
    abstract type MutableTrait end

Abstract type for [`IsMutable`](@ref) and [`NotMutable`](@ref) that are
returned by [`mutability`](@ref).
"""
abstract type MutableTrait end

"""
    struct IsMutable <: MutableTrait end

When this is returned by [`mutability`](@ref), it means that object of the given
type can always be mutated to equal the result of the operation.
"""
struct IsMutable <: MutableTrait end

"""
    struct NotMutable <: MutableTrait end

When this is returned by [`mutability`](@ref), it means that object of the given
type cannot be mutated to equal the result of the operation.
"""
struct NotMutable <: MutableTrait end

"""
    mutability(T::Type, ::typeof(op), args::Type...)::MutableTrait

Return either [`IsMutable`](@ref) to indicate an object of type `T` can be
modified to be equal to `op(args...)` or [`NotMutable`](@ref) otherwise.
"""
function mutability(T::Type, op, args::Vararg{Type,N}) where {N}
    if mutability(T) isa IsMutable && promote_operation(op, args...) == T
        return IsMutable()
    else
        return NotMutable()
    end
end
mutability(x, op, args::Vararg{Any,N}) where {N} =
    mutability(typeof(x), op, typeof.(args)...)
mutability(::Type) = NotMutable()

"""
    mutable_copy(x)

Return a copy of `x` that can be mutated with MultableArithmetics's API without
altering `x`.

## Examples

The copy of a JuMP affine expression does not copy the underlying model as it
cannot be modified though the MultableArithmetics's API, however, it calls
[`copy_if_mutable`](@ref) on the coefficients and on the constant as they could
be mutated.
"""
function mutable_copy end
mutable_copy(A::AbstractArray) = mutable_copy.(A)
copy_if_mutable_fallback(::NotMutable, x) = x
copy_if_mutable_fallback(::IsMutable, x) = mutable_copy(x)

"""
    copy_if_mutable(x)

Return a copy of `x` that can be mutated with MultableArithmetics's API without
altering `x`. If `mutability(x)` is `NotMutable` then `x` is returned as none of
`x` can be mutated. Otherwise, it redirects to [`mutable_copy`](@ref).
Mutable types should not implement a method for this function but should
implement a method for [`mutable_copy`](@ref) instead.
"""
copy_if_mutable(x) = copy_if_mutable_fallback(mutability(typeof(x)), x)

function mutable_operate_to_fallback(::NotMutable, output, op::Function, args...)
    throw(
        ArgumentError(
            "Cannot call `mutable_operate_to!(::$(typeof(output)), $op, ::$(join(typeof.(args), ", ::")))` as objects of type `$(typeof(output))` cannot be modifed to equal the result of the operation. Use `operate_to!` instead which returns the value of the result (possibly modifying the first argument) to write generic code that also works when the type cannot be modified.",
        ),
    )
end

function mutable_operate_to_fallback(::IsMutable, output, op::AddSubMul, x, y)
    return mutable_operate_to!(output, add_sub_op(op), x, y)
end
function mutable_operate_to_fallback(::IsMutable, output, op::Function, args...)
    error(
        "`mutable_operate_to!(::$(typeof(output)), $op, ::",
        join(typeof.(args), ", ::"),
        ")` is not implemented yet.",
    )
end

"""
    mutable_operate_to!(output, op::Function, args...)

Modify the value of `output` to be equal to the value of `op(args...)`. Can
only be called if `mutability(output, op, args...)` returns `true`.

If `output === args[i]` for some `i`,
* The user should expect to get an error. `operate!` or `mutable_operate!` should be used instead.
* Any method not supporting this case should throw an error.

For instance, in DynamicPolynomials, `mutable_operate_to!(p, +, p, q)` throws an
error because otherwise, the algorithm would fill `p` while iterating over the
terms of `p` and `q` hence it will never terminate. On the other hand
`mutable_operate!(+, p, q)` uses a different algorithm that efficiently inserts
the terms of `q` in the sorted list of terms of `p` with minimal displacement.
"""
function mutable_operate_to!(output, op::F, args::Vararg{Any,N}) where {F<:Function,N}
    mutable_operate_to_fallback(mutability(output, op, args...), output, op, args...)
end

function mutable_operate_fallback(::NotMutable, op::Function, args...)
    throw(
        ArgumentError(
            "Cannot call `mutable_operate!($op, ::$(join(typeof.(args), ", ::")))` as objects of type `$(typeof(args[1]))` cannot be modifed to equal the result of the operation. Use `operate!` instead which returns the value of the result (possibly modifying the first argument) to write generic code that also works when the type cannot be modified.",
        ),
    )
end

function mutable_operate_fallback(::IsMutable, op::AddSubMul, x, y)
    return mutable_operate!(add_sub_op(op), x, y)
end
function mutable_operate_fallback(::IsMutable, op::Function, args...)
    error(
        "`mutable_operate!($op, ::",
        join(typeof.(args), ", ::"),
        ")` is not implemented yet.",
    )
end

"""
    mutable_operate!(op::Function, args...)

Modify the value of `args[1]` to be equal to the value of `op(args...)`. Can
only be called if `mutability(args[1], op, args...)` returns `true`.
"""
function mutable_operate!(op::F, args::Vararg{Any,N}) where {F<:Function,N}
    mutable_operate_fallback(mutability(args[1], op, args...), op, args...)
end

buffer_for(::F, args::Vararg{Type,N}) where {F<:Function,N} = nothing

function mutable_buffered_operate_to_fallback(::NotMutable, buffer, output, op::Function, args...)
    throw(
        ArgumentError(
            "Cannot call `mutable_buffered_operate_to!(::$(typeof(buffer)), ::$(typeof(output)), $op, ::$(join(typeof.(args), ", ::")))` as objects of type `$(typeof(output))` cannot be modifed to equal the result of the operation. Use `buffered_operate_to!` instead which returns the value of the result (possibly modifying the first argument) to write generic code that also works when the type cannot be modified.",
        ),
    )
end


function mutable_buffered_operate_to_fallback(::IsMutable, buffer, output, op::Function, args...)
    error(
        "`mutable_buffered_operate_to!(::$(typeof(buffer)), ::$(typeof(output)), $op, ::",
        join(typeof.(args), ", ::"),
        ")` is not implemented.",
    )
end

function mutable_buffered_operate_to_fallback(
    buffer,
    output,
    op::F,
    args::Vararg{Any,N},
) where {F<:Function,N}
    return mutable_buffered_operate_to_fallback(
        mutability(output, op, args...),
        buffer,
        output,
        op,
        args...
    )
end

function mutable_buffered_operate_to_fallback(
    ::Nothing,
    output,
    op::F,
    args::Vararg{Any,N},
) where {F<:Function,N}
    return mutable_operate_to!(output, op, args...)
end

"""
    mutable_buffered_operate_to!(buffer, output, op::Function, args...)

Modify the value of `output` to be equal to the value of `op(args...)`,
possibly modifying `buffer`. Can only be called if
`mutability(output, op, args...)` returns `true`.
"""
function mutable_buffered_operate_to!(
    buffer,
    output,
    op::F,
    args::Vararg{Any,N},
) where {F<:Function,N}
    return mutable_buffered_operate_to_fallback(buffer, output, op, args...)
end

function mutable_buffered_operate_fallback(::NotMutable, buffer, op::Function, args...)
    throw(
        ArgumentError(
                      "Cannot call `mutable_buffered_operate!(::$(typeof(buffer)), $op, ::$(join(typeof.(args), ", ::")))` as objects of type `$(typeof(args[1]))` cannot be modifed to equal the result of the operation. Use `buffered_operate!` instead which returns the value of the result (possibly modifying the first argument) to write generic code that also works when the type cannot be modified.",
        ),
    )
end

function mutable_buffered_operate_fallback(::IsMutable, buffer, op::Function, args...)
    error(
        "`mutable_buffered_operate!(::$(typeof(buffer)), $op, ::",
        join(typeof.(args), ", ::"),
        ")` is not implemented.",
    )
end

function mutable_buffered_operate_fallback(
    buffer,
    op::F,
    args::Vararg{Any,N},
) where {F<:Function,N}
    return mutable_buffered_operate_fallback(
        mutability(args[1], op, args...),
        buffer,
        op,
        args...
    )
end

function mutable_buffered_operate_fallback(
    ::Nothing,
    op::F,
    args::Vararg{Any,N},
) where {F<:Function,N}
    return mutable_operate!(op, args...)
end

"""
    mutable_buffered_operate!(buffer, op::Function, args...)

Modify the value of `args[1]` to be equal to the value of `op(args...)`,
possibly modifying `buffer`. Can only be called if
`mutability(args[1], op, args...)` returns `true`.
"""
function mutable_buffered_operate! end
function mutable_buffered_operate!(buffer, op::F, args::Vararg{Any,N}) where {F<:Function,N}
    return mutable_buffered_operate_fallback(buffer, op, args...)
end

"""
    operate_to!(output, op::Function, args...)

Returns the value of `op(args...)`, possibly modifying `output`.
"""
function operate_to!(output, op::F, args::Vararg{Any,N}) where {F<:Function,N}
    return operate_to_fallback!(mutability(output, op, args...), output, op, args...)
end

function operate_to_fallback!(
    ::NotMutable,
    output,
    op::F,
    args::Vararg{Any,N},
) where {F<:Function,N}
    return operate(op, args...)
end
function operate_to_fallback!(
    ::IsMutable,
    output,
    op::F,
    args::Vararg{Any,N},
) where {F<:Function,N}
    return mutable_operate_to!(output, op, args...)
end

"""
    operate!(op::Function, args...)

Returns the value of `op(args...)`, possibly modifying `args[1]`.
"""
function operate!(op::F, args::Vararg{Any,N}) where {F<:Function,N}
    return operate_fallback!(mutability(args[1], op, args...), op, args...)
end

function operate_fallback!(::NotMutable, op::F, args::Vararg{Any,N}) where {F<:Function,N}
    return operate(op, args...)
end
function operate_fallback!(::IsMutable, op::F, args::Vararg{Any,N}) where {F<:Function,N}
    return mutable_operate!(op, args...)
end

"""
    buffered_operate_to!(buffer, output, op::Function, args...)

Returns the value of `op(args...)`, possibly modifying `buffer` and `output`.
"""
function buffered_operate_to!(buffer, output, op::F, args::Vararg{Any,N}) where {F<:Function,N}
    return buffered_operate_to_fallback!(
        mutability(output, op, args...),
        buffer,
        output,
        op,
        args...,
    )
end

function buffered_operate_to_fallback!(
    ::NotMutable,
    buffer,
    output,
    op::F,
    args::Vararg{Any,N},
) where {F<:Function,N}
    return operate(op, args...)
end
function buffered_operate_to_fallback!(
    ::IsMutable,
    buffer,
    output,
    op::F,
    args::Vararg{Any,N},
) where {F<:Function,N}
    return mutable_buffered_operate_to!(buffer, output, op, args...)
end

"""
    buffered_operate!(buffer, op::Function, args...)

Returns the value of `op(args...)`, possibly modifying `buffer`.
"""
function buffered_operate!(buffer, op::F, args::Vararg{Any,N}) where {F<:Function,N}
    return buffered_operate_fallback!(mutability(args[1], op, args...), buffer, op, args...)
end

function buffered_operate_fallback!(
    ::NotMutable,
    buffer,
    op::F,
    args::Vararg{Any,N},
) where {F<:Function,N}
    return operate(op, args...)
end
function buffered_operate_fallback!(
    ::IsMutable,
    buffer,
    op::F,
    args::Vararg{Any,N},
) where {F<:Function,N}
    return mutable_buffered_operate!(buffer, op, args...)
end

# For most types, `dot(b, c) = adjoint(b) * c`.
promote_operation_fallback(::typeof(adjoint), a::Type) = a
function promote_operation_fallback(::typeof(LinearAlgebra.dot), b::Type, c::Type)
    return promote_operation(*, promote_operation(adjoint, b), c)
end
function buffer_for(::typeof(add_dot), a::Type, b::Type, c::Type)
    return buffer_for(add_mul, a, promote_operation(adjoint, b), c)
end
function mutable_operate_to_fallback(::IsMutable, output, ::typeof(add_dot), a, b, c) where {N}
    return mutable_operate_to!(output, add_mul, a, adjoint(b), c)
end
function mutable_operate_fallback(::IsMutable, ::typeof(add_dot), a, b, c) where {N}
    return mutable_operate!(add_mul, a, adjoint(b), c)
end
function mutable_buffered_operate_to_fallback(::IsMutable, buffer, output, ::typeof(add_dot), a, b, c)
    return mutable_buffered_operate_to!(buffer, output, add_mul, a, adjoint(b), c)
end
function mutable_buffered_operate_fallback(::IsMutable, buffer, ::typeof(add_dot), a, b, c)
    return mutable_buffered_operate!(buffer, add_mul, a, adjoint(b), c)
end
