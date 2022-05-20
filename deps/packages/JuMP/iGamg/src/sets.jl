abstract type AbstractVectorSet end

# Used in `@constraint model f in s`
function build_constraint(_error::Function, f::AbstractVector,
                         s::AbstractVectorSet)
    return build_constraint(_error, f, moi_set(s, length(f)))
end

"""
    SecondOrderCone

Second order cone object that can be used to constrain the euclidean norm of a
vector `x` to be less than or equal to a nonnegative scalar `t`. This is a
shortcut for the `MathOptInterface.SecondOrderCone`.

## Examples

The following constrains ``\\|(x-1, x-2)\\|_2 \\le t`` and ``t \\ge 0``:
```jldoctest; setup = :(using JuMP)
julia> model = Model();

julia> @variable(model, x)
x

julia> @variable(model, t)
t

julia> @constraint(model, [t, x-1, x-2] in SecondOrderCone())
[t, x - 1, x - 2] ∈ MathOptInterface.SecondOrderCone(3)
```
"""
struct SecondOrderCone <: AbstractVectorSet end
moi_set(::SecondOrderCone, dim::Int) = MOI.SecondOrderCone(dim)

"""
    RotatedSecondOrderCone

Rotated second order cone object that can be used to constrain the square of the
euclidean norm of a vector `x` to be less than or equal to ``2tu`` where `t` and
`u` are nonnegative scalars. This is a shortcut for the
`MathOptInterface.RotatedSecondOrderCone`.

## Examples

The following constrains ``\\|(x-1, x-2)\\|_2 \\le 2tx`` and ``t, x \\ge 0``:
```jldoctest; setup = :(using JuMP)
julia> model = Model();

julia> @variable(model, x)
x

julia> @variable(model, t)
t

julia> @constraint(model, [t, x, x-1, x-2] in RotatedSecondOrderCone())
[t, x, x - 1, x - 2] ∈ MathOptInterface.RotatedSecondOrderCone(4)
```
"""
struct RotatedSecondOrderCone <: AbstractVectorSet end
moi_set(::RotatedSecondOrderCone, dim::Int) = MOI.RotatedSecondOrderCone(dim)

# Deprecation for JuMP v0.18 -> JuMP v0.19 transition
function LinearAlgebra.norm(::AbstractVector{<:AbstractJuMPScalar})
    error("JuMP no longer performs automatic transformation of `norm()` ",
          "expressions into second-order cone constraints. They should now ",
          "be expressed using the SecondOrderCone() set. For example, ",
          "`@constraint(model, norm(x) <= t)` should now be written as ",
          "`@constraint(model, [t; x] in SecondOrderCone())`")
end
