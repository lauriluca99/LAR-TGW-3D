# Matrix-Vector Operations

Here I'll discuss a variety of Matrix-vector operations, naturally starting with matrix-vector multiplication.

```julia
function jgemvavx!(𝐲, 𝐀, 𝐱)
    @turbo for i ∈ eachindex(𝐲)
        𝐲i = zero(eltype(𝐲))
        for j ∈ eachindex(𝐱)
            𝐲i += 𝐀[i,j] * 𝐱[j]
        end
        𝐲[i] = 𝐲i
    end
end
```

Using a square `Size` x `Size` matrix `𝐀`, we find the following results.
![Amulvb](https://github.com/JuliaSIMD/LoopVectorization.jl/raw/docsassets/docs/src/assets/bench_Amulvb_v2.svg)

If `𝐀` is transposed, or equivalently, if we're instead computing `x * 𝐀`:
![Atmulvb](https://github.com/JuliaSIMD/LoopVectorization.jl/raw/docsassets/docs/src/assets/bench_Atmulvb_v2.svg)

Finally, the three-argument dot product `y' * 𝐀 * x`:
![dot3](https://github.com/JuliaSIMD/LoopVectorization.jl/raw/docsassets/docs/src/assets/bench_dot3_v2.svg)

The performance impact of alignment is dramatic here.


