# Normed{T,f} maps UInts from 0 to 2^f-1 to the range [0.0, 1.0]
# For example, Normed{UInt8,8} == N0f8 maps 0x00 to 0.0 and 0xff to 1.0

struct Normed{T<:Unsigned,f} <: FixedPoint{T,f}
    i::T

    Normed{T, f}(i::Integer,_) where {T,f} = new{T, f}(i%T)   # for setting by raw representation
end

Normed{T, f}(x::AbstractChar) where {T,f} = throw(ArgumentError("Normed cannot be constructed from a Char"))
Normed{T, f}(x::Complex) where {T,f} = Normed{T, f}(convert(real(typeof(x)), x))
Normed{T, f}(x::Base.TwicePrecision) where {T,f} = Normed{T, f}(convert(Float64, x))
Normed{T1,f}(x::Normed{T2,f}) where {T1 <: Unsigned,T2 <: Unsigned,f} = Normed{T1,f}(convert(T1, x.i), 0)

typechar(::Type{X}) where {X <: Normed} = 'N'
signbits(::Type{X}) where {X <: Normed} = 0

for T in (UInt8, UInt16, UInt32, UInt64)
    for f in 1:sizeof(T)*8
        sym = Symbol(String(take!(showtype(_iotypealias, Normed{T,f}))))
        @eval begin
            const $sym = Normed{$T,$f}
            export $sym
        end
    end
end

reinterpret(::Type{Normed{T,f}}, x::T) where {T <: Unsigned,f} = Normed{T,f}(x, 0)

zero(::Type{Normed{T,f}}) where {T,f} = Normed{T,f}(zero(T),0)
function oneunit(::Type{T}) where {T <: Normed}
    T(typemax(rawtype(T)) >> (8*sizeof(T)-nbitsfrac(T)), 0)
end
one(::Type{T}) where {T <: Normed} = oneunit(T)
zero(x::Normed) = zero(typeof(x))
oneunit(x::Normed) =  one(typeof(x))
one(x::Normed) = oneunit(x)
rawone(v) = reinterpret(one(v))

# Conversions
function Normed{T,f}(x::Normed{T2}) where {T <: Unsigned,T2 <: Unsigned,f}
    U = Normed{T,f}
    y = round((rawone(U)/rawone(x))*reinterpret(x))
    (0 <= y) & (y <= typemax(T)) || throw_converterror(U, x)
    reinterpret(U, _unsafe_trunc(T, y))
end
N0f16(x::N0f8) = reinterpret(N0f16, convert(UInt16, 0x0101*reinterpret(x)))

(::Type{U})(x::Real) where {U <: Normed} = _convert(U, x)

function _convert(::Type{U}, x) where {T, f, U <: Normed{T,f}}
    if T == UInt128 # for UInt128, we can't widen
        # the upper limit is not exact
        (0 <= x) & (x <= (typemax(T)/rawone(U))) || throw_converterror(U, x)
        y = round(rawone(U)*x)
    else
        y = round(widen1(rawone(U))*x)
        (0 <= y) & (y <= typemax(T)) || throw_converterror(U, x)
    end
    reinterpret(U, _unsafe_trunc(T, y))
end
# Prevent overflow (https://discourse.julialang.org/t/saving-greater-than-8-bit-images/6057)
function _convert(::Type{U}, x::Float16) where {T, f, U <: Normed{T,f}}
    if Float16(typemax(T)/rawone(U)) > Float32(typemax(T)/rawone(U))
        x == Float16(typemax(T)/rawone(U)) && return typemax(U)
    end
    return _convert(U, Float32(x))
end
function _convert(::Type{U}, x::Tf) where {T, f, U <: Normed{T,f}, Tf <: Union{Float32, Float64}}
    if T == UInt128 && f == 53
        0 <= x <= Tf(3.777893186295717e22) || throw_converterror(U, x)
    else
        0 <= x <= Tf((typemax(T)-rawone(U))/rawone(U)+1) || throw_converterror(U, x)
    end

    significand_bits = Tf == Float64 ? 52 : 23
    if f <= (significand_bits + 1) && sizeof(T) * 8 < significand_bits
        return reinterpret(U, unsafe_trunc(T, round(rawone(U) * x)))
    end
    # cf. the implementation of `frexp`
    Tw = f < sizeof(T) * 8 ? T : widen1(T)
    bits = sizeof(Tw) * 8 - 1
    xu = reinterpret(Tf == Float64 ? UInt64 : UInt32, x)
    k = Int(xu >> significand_bits)
    k == 0 && return zero(U) # neglect subnormal numbers
    significand = xu | (one(xu) << significand_bits)
    yh = unsafe_trunc(Tw, significand) << (bits - significand_bits)
    exponent_bias = Tf == Float64 ? 1023 : 127
    ex = exponent_bias - k + bits - f
    yi = bits >= f ? yh - (yh >> f) : yh
    if ex <= 0
        ex == 0 && return reinterpret(U, unsafe_trunc(T, yi))
        ex != -1 || signbit(signed(yi)) && return typemax(U)
        return reinterpret(U, unsafe_trunc(T, yi + yi))
    end
    ex > bits && return reinterpret(U, ex == bits + 1 ? one(T) : zero(T))
    yi += one(Tw)<<((ex - 1) & bits) # RoundNearestTiesUp
    return reinterpret(U, unsafe_trunc(T, yi >> (ex & bits)))
end

rem(x::T, ::Type{T}) where {T <: Normed} = x
rem(x::Normed, ::Type{T}) where {T <: Normed} = reinterpret(T, _unsafe_trunc(rawtype(T), round((rawone(T)/rawone(x))*reinterpret(x))))
rem(x::Real, ::Type{T}) where {T <: Normed} = reinterpret(T, _unsafe_trunc(rawtype(T), round(rawone(T)*x)))
rem(x::Float16, ::Type{T}) where {T <: Normed} = rem(Float32(x), T)  # avoid overflow

float(x::Normed) = convert(floattype(x), x)

macro f32(x::Float64) # just for hexadecimal floating-point literals
    :(Float32($x))
end
macro exp2(n)
     :(_exp2(Val($(esc(n)))))
end
_exp2(::Val{N}) where {N} = exp2(N)

# for Julia v1.0, which does not fold `div_float` before inlining
inv_rawone(x) = (@generated) ? (y = 1.0 / rawone(x); :($y)) : 1.0 / rawone(x)

function (::Type{T})(x::Normed) where {T <: AbstractFloat}
    # The following optimization for constant division may cause rounding errors.
    # y = reinterpret(x)*(one(rawtype(x))/convert(T, rawone(x)))
    # Therefore, we use a simple form here.
    # If you prefer speed over accuracy, consider using `scaledual` instead.
    y = reinterpret(x) / convert(promote_type(T, floattype(x)), rawone(x))
    convert(T, y)  # needed for types like Float16 which promote arithmetic to Float32
end

function Base.Float16(x::Normed{Ti,f}) where {Ti <: Union{UInt8, UInt16, UInt32}, f}
    f == 1 ? Float16(x.i) : Float16(Float32(x))
end
function Base.Float16(x::Normed{Ti,f}) where {Ti <: Union{UInt64, UInt128}, f}
    f == 1 ? Float16(x.i) : Float16(Float64(x))
end

function Base.Float32(x::Normed{UInt8,f}) where f
    f == 1 && return Float32(x.i)
    f == 2 && return Float32(Int32(x.i) * 0x101) * @f32(0x550055p-32)
    f == 3 && return Float32(Int32(x.i) * 0x00b) * @f32(0xd4c77bp-30)
    f == 4 && return Float32(Int32(x.i) * 0x101) * @f32(0x110011p-32)
    f == 5 && return Float32(Int32(x.i) * 0x003) * @f32(0xb02c0bp-30)
    f == 6 && return Float32(Int32(x.i) * 0x049) * @f32(0xe40039p-36)
    f == 7 && return Float32(Int32(x.i) * 0x01f) * @f32(0x852b5fp-35)
    f == 8 && return Float32(Int32(x.i) * 0x155) * @f32(0xc0f0fdp-40)
    0.0f0
end
function Base.Float32(x::Normed{UInt16,f}) where f
    f32 = Float32(x.i)
    f ==  1 && return f32
    f ==  2 && return f32 * @f32(0x55p-8)  + f32 * @f32(0x555555p-32)
    f ==  3 && return f32 * @f32(0x49p-9)  + f32 * @f32(0x249249p-33)
    f ==  4 && return f32 * @f32(0x11p-8)  + f32 * @f32(0x111111p-32)
    f ==  5 && return f32 * @f32(0x21p-10) + f32 * @f32(0x108421p-35)
    f ==  6 && return f32 * @f32(0x41p-12) + f32 * @f32(0x041041p-36)
    f ==  7 && return f32 * @f32(0x81p-14) + f32 * @f32(0x204081p-42)
    f == 16 && return f32 * @f32(0x01p-16) + f32 * @f32(0x010001p-48)
    Float32(x.i / rawone(x))
end
function Base.Float32(x::Normed{UInt32,f}) where f
    f == 1 && return Float32(x.i)
    i32 = unsafe_trunc(Int32, x.i)
    if f == 32
        rh, rl = Float32(i32>>>0x10), Float32((i32&0xFFFF)<<0x8 | i32>>>0x18)
        return muladd(rh, @f32(0x1p-16), rl * @f32(0x1p-40))
    elseif f >= 25
        rh, rl = Float32(i32>>>0x10), Float32((i32&0xFFFF)<<0xE + i32>>>UInt8(f-14))
        return muladd(rh, Float32(@exp2(16-f)), rl * Float32(@exp2(-14-f)))
    end
    # FIXME: avoid the branch in native x86_64 (non-SIMD) codes
    m = ifelse(i32 < 0, 0x1p32 * inv_rawone(x), 0.0)
    Float32(muladd(Float64(i32), inv_rawone(x), m))
end
function Base.Float32(x::Normed{Ti,f}) where {Ti <: Union{UInt64, UInt128}, f}
    f == 1 ? Float32(x.i) : Float32(Float64(x))
end

function Base.Float64(x::Normed{Ti,f}) where {Ti <: Union{UInt8, UInt16}, f}
    Float64(Normed{UInt32,f}(x))
end
function Base.Float64(x::Normed{UInt32,f}) where f
    f64 = Float64(x.i)
    f ==  1 && return f64
    f ==  2 && return (f64 * 0x040001p0) * 0x15555000015555p-72
    f ==  3 && return (f64 * 0x108421p0) * 0x11b6db76924929p-75
    f ==  4 && return (f64 * 0x010101p0) * 0x11000011000011p-72
    f ==  5 && return (f64 * 0x108421p0) * 0x04000002000001p-75
    f ==  6 && return (f64 * 0x09dfb1p0) * 0x1a56b8e38e6d91p-78
    f ==  7 && return (f64 * 0x000899p0) * 0x0f01480001e029p-70
    f ==  8 && return (f64 * 0x0a5a5bp0) * 0x18d300000018d3p-80
    f ==  9 && return (f64 * 0x001001p0) * 0x080381c8e3f201p-72
    f == 10 && return (f64 * 0x100001p0) * 0x04010000000401p-80
    f == 11 && return (f64 * 0x000009p0) * 0x0e3aaae3955639p-66
    f == 12 && return (f64 * 0x0a8055p0) * 0x186246e46e4cfdp-84
    f == 13 && return (f64 * 0x002001p0) * 0x10000004000001p-78
    f == 14 && return (f64 * 0x03400dp0) * 0x13b13b14ec4ec5p-84
    f == 15 && return (f64 * 0x000259p0) * 0x06d0c5a4f3a5e9p-75
    f == 16 && return (f64 * 0x011111p0) * 0x00f000ff00fff1p-80
    f == 18 && return (f64 * 0x0b06d1p0) * 0x17377445dd1231p-90
    f == 19 && return (f64 * 0x080001p0) * 0x00004000000001p-76
    f == 20 && return (f64 * 0x000101p0) * 0x0ff010ef10ff01p-80
    f == 21 && return (f64 * 0x004001p0) * 0x01fff8101fc001p-84
    f == 22 && return (f64 * 0x002945p0) * 0x18d0000000018dp-88
    f == 23 && return (f64 * 0x044819p0) * 0x07794a23729429p-92
    f == 27 && return (f64 * 0x000a21p0) * 0x0006518c7df9e1p-81
    f == 28 && return (f64 * 0x00000dp0) * 0x13b13b14ec4ec5p-84
    f == 30 && return (f64 * 0x001041p0) * 0x00fc003f03ffc1p-90
    f == 32 && return (f64 * 0x010101p0) * 0x00ff0000ffff01p-96
    f64 / rawone(x)
end
function Base.Float64(x::Normed{UInt64,f}) where f
    f == 1 && return Float64(x.i)
    if f >= 53
        rh = Float64(unsafe_trunc(Int64, x.i>>0x10)) * @exp2(16-f) # upper 48 bits
        rl = Float64(unsafe_trunc(Int32, x.i&0xFFFF)) * @exp2(-f)  # lower 16 bits
        return rh + muladd(rh, @exp2(-f), rl)
    end
    x.i / rawone(x)
end
function Base.Float64(x::Normed{UInt128,f}) where f
    f == 1 && return Float64(x.i)
    ih, il = unsafe_trunc(Int64, x.i>>0x40), unsafe_trunc(Int64, x.i)
    rh = Float64(ih>>>0x10) * @exp2(f <= 53 ? 80 : 80 - f) # upper 48 bits
    km = @exp2(f <= 53 ? 48 : 48 - f) # for middle 32 bits
    rm = Float64(unsafe_trunc(Int32, ih&0xFFFF)) * (0x1p16 * km) +
         Float64(unsafe_trunc(Int32, il>>>0x30)) * km
    rl = Float64(il&0xFFFFFFFFFFFF) * @exp2(f <= 53 ? 0 : -f) # lower 48 bits
    if f <= 53
        return (rh + (rm + rl)) / unsafe_trunc(Int64, rawone(x))
    elseif f < 76
        return rh + (rm + muladd(rh, @exp2(-f), rl))
    else
        return rh + (rm + rl)
    end
end

Base.BigFloat(x::Normed) = reinterpret(x)*(1/BigFloat(rawone(x)))

Base.Bool(x::Normed) = x == zero(x) ? false : true
Base.Integer(x::Normed) = convert(Integer, x*1.0)
(::Type{T})(x::Normed) where {T <: Integer} = convert(T, x*(1/oneunit(T)))
Base.Rational{Ti}(x::Normed) where {Ti <: Integer} = convert(Ti, reinterpret(x))//convert(Ti, rawone(x))
Base.Rational(x::Normed) = reinterpret(x)//rawone(x)

# Traits
abs(x::Normed) = x

(-)(x::T) where {T <: Normed} = T(-reinterpret(x), 0)
(~)(x::T) where {T <: Normed} = T(~reinterpret(x), 0)

+(x::Normed{T,f}, y::Normed{T,f}) where {T,f} = Normed{T,f}(convert(T, x.i+y.i),0)
-(x::Normed{T,f}, y::Normed{T,f}) where {T,f} = Normed{T,f}(convert(T, x.i-y.i),0)
*(x::T, y::T) where {T <: Normed} = convert(T,convert(floattype(T), x)*convert(floattype(T), y))
/(x::T, y::T) where {T <: Normed} = convert(T,convert(floattype(T), x)/convert(floattype(T), y))

# Comparisons
 <(x::T, y::T) where {T <: Normed} = reinterpret(x) < reinterpret(y)
<=(x::T, y::T) where {T <: Normed} = reinterpret(x) <= reinterpret(y)

# Functions
trunc(x::T) where {T <: Normed} = T(div(reinterpret(x), rawone(T))*rawone(T),0)
floor(x::T) where {T <: Normed} = trunc(x)
function round(x::Normed{T,f}) where {T,f}
    mask = convert(T, 1<<(f-1))
    y = trunc(x)
    return convert(T, reinterpret(x)-reinterpret(y)) & mask>0 ?
            Normed{T,f}(y+oneunit(Normed{T,f})) : y
end
function ceil(x::Normed{T,f}) where {T,f}
    k = 8*sizeof(T)-f
    mask = (typemax(T)<<k)>>k
    y = trunc(x)
    return convert(T, reinterpret(x)-reinterpret(y)) & (mask)>0 ?
            Normed{T,f}(y+oneunit(Normed{T,f})) : y
end

trunc(::Type{T}, x::Normed) where {T <: Integer} = convert(T, div(reinterpret(x), rawone(x)))
round(::Type{T}, x::Normed) where {T <: Integer} = round(T, reinterpret(x)/rawone(x))
floor(::Type{T}, x::Normed) where {T <: Integer} = trunc(T, x)
 ceil(::Type{T}, x::Normed) where {T <: Integer} =  ceil(T, reinterpret(x)/rawone(x))

isfinite(x::Normed) = true
isnan(x::Normed) = false
isinf(x::Normed) = false

bswap(x::Normed{UInt8,f}) where {f} = x
bswap(x::Normed)  = typeof(x)(bswap(reinterpret(x)),0)

function minmax(x::T, y::T) where {T <: Normed}
    a, b = minmax(reinterpret(x), reinterpret(y))
    T(a,0), T(b,0)
end

# Iteration
# The main subtlety here is that iterating over N0f8(0):N0f8(1) will wrap around
# unless we iterate using a wider type
@inline start(r::StepRange{T}) where {T <: Normed} = widen1(reinterpret(r.start))
@inline next(r::StepRange{T}, i::Integer) where {T <: Normed} = (T(i,0), i+reinterpret(r.step))
@inline function done(r::StepRange{T}, i::Integer) where {T <: Normed}
    i1, i2 = reinterpret(r.start), reinterpret(r.stop)
    isempty(r) | (i < min(i1, i2)) | (i > max(i1, i2))
end

function decompose(x::Normed)
    g = gcd(reinterpret(x), rawone(x))
    div(reinterpret(x),g), 0, div(rawone(x),g)
end

# Promotions
promote_rule(::Type{T}, ::Type{Tf}) where {T <: Normed,Tf <: AbstractFloat} = promote_type(floattype(T), Tf)
promote_rule(::Type{T}, ::Type{R}) where {T <: Normed,R <: Rational} = R
function promote_rule(::Type{T}, ::Type{Ti}) where {T <: Normed,Ti <: Union{Signed, Unsigned}}
    floattype(T)
end
@generated function promote_rule(::Type{Normed{T1,f1}}, ::Type{Normed{T2,f2}}) where {T1,T2,f1,f2}
    f = max(f1, f2)  # ensure we have enough precision
    T = promote_type(T1, T2)
    # make sure we have enough integer bits
    i1, i2 = 8*sizeof(T1)-f1, 8*sizeof(T2)-f2  # number of integer bits for each
    i = 8*sizeof(T)-f
    while i < max(i1, i2)
        Tw = widen1(T)
        T == Tw && break
        T = Tw
        i = 8*sizeof(T)-f
    end
    :(Normed{$T,$f})
end

_unsafe_trunc(::Type{T}, x::Integer) where {T} = x % T
_unsafe_trunc(::Type{T}, x) where {T}          = unsafe_trunc(T, x)
if !signbit(signed(unsafe_trunc(UInt, -12.345)))
    # a workaround for 32-bit ARMv7 (issue #134)
    function _unsafe_trunc(::Type{T}, x::AbstractFloat) where {T}
        unsafe_trunc(T, unsafe_trunc(typeof(signed(zero(T))), x))
    end
end
