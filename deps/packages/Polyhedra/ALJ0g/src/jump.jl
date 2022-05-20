using JuMP

"""
    hrep(model::JuMP.Model)

Builds an H-representation from the feasibility set of the JuMP model `model`.
Note that if non-linear constraint are present in the model, they are ignored.
"""
hrep(model::JuMP.Model) = LPHRep(model)
LPHRep(model::JuMP.Model) = LPHRep(backend(model))
polyhedron(model::JuMP.Model, args...) = polyhedron(hrep(model), args...)
