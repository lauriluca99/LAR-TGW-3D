```@meta
CurrentModule = MathOptInterface
DocTestSetup = quote
    using MathOptInterface
    const MOI = MathOptInterface

    # For compatibility with both Julia 1.0.5 and 1.5.2
    # Upon the Julia LTS version becoming 1.6, these imports could be dropped,
    # and all ScalarAffineTerm and VariableIndex instances in doctests below
    # could be replaced with MOI.ScalarAffineTerm and MOI.VariableIndex
    # Check discussion at PR 1184: https://github.com/jump-dev/MathOptInterface.jl/pull/1184#discussion_r515300914
    import MathOptInterface.ScalarAffineTerm
    import MathOptInterface.VariableIndex
end
DocTestFilters = [r"MathOptInterface|MOI"]
```

## Utilities.Model

```@docs
Utilities.Model
```

## Utilities.UniversalFallback

```@docs
Utilities.UniversalFallback
```

## Utilities.@macro

```@docs
Utilities.@model
Utilities.GenericModel
Utilities.GenericOptimizer
Utilities.struct_of_constraint_code
```

### Caching optimizer

```@docs
Utilities.CachingOptimizer
Utilities.attach_optimizer
Utilities.reset_optimizer
Utilities.drop_optimizer
Utilities.state
Utilities.mode
```

## Copy utilities

```@docs
Utilities.automatic_copy_to
Utilities.default_copy_to
Utilities.supports_default_copy_to
```

### [Allocate-Load API](@id allocate_load_api_ref)

```@docs
Utilities.allocate_load
Utilities.supports_allocate_load
Utilities.allocate_variables
Utilities.allocate
Utilities.allocate_constraint
Utilities.load_variables
Utilities.load
Utilities.load_constraint
```

## Fallbacks

```@docs
Utilities.get_fallback
```

## Function utilities

The following utilities are available for functions:

```@docs
Utilities.eval_variables
Utilities.map_indices
Utilities.substitute_variables
Utilities.filter_variables
Utilities.remove_variable
Utilities.all_coefficients
Utilities.unsafe_add
Utilities.isapprox_zero
Utilities.modify_function
```

The following functions can be used to canonicalize a function:

```@docs
Utilities.is_canonical
Utilities.canonical
Utilities.canonicalize!
```

The following functions can be used to manipulate functions with basic algebra:

```@docs
Utilities.scalar_type
Utilities.promote_operation
Utilities.operate
Utilities.operate!
Utilities.operate_output_index!
Utilities.vectorize
```

## Constraint utilities

The following utilities are available for moving the function constant to the
set for scalar constraints:

```@docs
Utilities.shift_constant
Utilities.supports_shift_constant
Utilities.normalize_and_add_constraint
Utilities.normalize_constant
```

The following utility identifies those constraints imposing bounds on a given
variable, and returns those bound values:
```@docs
Utilities.get_bounds
```

The following utilities are useful when working with symmetric matrix cones.
```@docs
Utilities.is_diagonal_vectorized_index
Utilities.side_dimension_for_vectorized_dimension
```
