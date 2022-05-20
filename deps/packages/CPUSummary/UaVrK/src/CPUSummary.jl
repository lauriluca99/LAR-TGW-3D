module CPUSummary

using Static
using Static: Zero, One, gt, lt
using IfElse: ifelse
export cache_size,
  cache_linesize,
  cache_associativity,
  cache_type,
  cache_inclusive,
  num_cache,
  num_cores,
  num_threads

# const USE_HWLOC = @load_preference("hwloc", Sys.ARCH !== :aarch64 || !Sys.isapple())
# use_hwloc(b) = @set_preferences!("hwloc" => b)

# @static if USE_HWLOC
#   try
#     script = """
#     $(Base.load_path_setup_code())
#     Hwloc = Base.require(Base.PkgId(Base.UUID("0e44f5e4-bd66-52a0-8798-143a42290a1d"), "Hwloc"))
#     Hwloc.gettopology()
#     """
#     p = run(`$(Base.julia_cmd()) -e $(script)`, wait=false)
#     wait(p)
#     if p.exitcode == 0 && p.termsignal == 0
#       include("topology.jl")
#     else
#       use_hwloc(false)
#       include("generic_topology.jl")
#     end
#   catch
#     use_hwloc(false)
#     include("generic_topology.jl")
#   end
# else
if (Sys.ARCH === :x86_64)
  include("x86.jl")
else
  include("generic_topology.jl")
end
function __init__()
  ccall(:jl_generating_output, Cint, ()) == 1 && return
  nc = _get_num_cores()
  syst = Sys.CPU_THREADS::Int
  nt = Threads.nthreads()
  if nc != num_l1cache()
    @eval num_l1cache() = static($nc)
  end
  if nc != num_cores()
    @eval num_cores() = static($nc)
  end
  if syst != sys_threads()
    @eval sys_threads() = static($syst)
  end
  if nt != num_threads()
    @eval num_threads() = static($nt)
  end
  _extra_init()
end


# end
num_cache(::Union{Val{1},StaticInt{1}}) = num_l1cache()
num_cache(::Union{Val{2},StaticInt{2}}) = num_l2cache()
num_cache(::Union{Val{3},StaticInt{3}}) = num_l3cache()
num_cache(::Union{Val{4},StaticInt{4}}) = num_l4cache()
const BASELINE_CORES = Int(num_cores()) * ((Sys.ARCH === :aarch64) && Sys.isapple() ? 2 : 1)
cache_linesize() = cache_linesize(Val(1))
function num_cache_levels()
  numl4 = num_l4cache()
  numl4 === nothing && return nothing
  ifelse(
    eq(numl4, Zero()),
    ifelse(
      eq(num_l3cache(), Zero()),
      ifelse(
        eq(num_l2cache(), Zero()),
        ifelse(eq(num_l1cache(), Zero()), Zero(), One()),
        StaticInt{2}(),
      ),
      StaticInt{3}(),
    ),
    StaticInt{4}(),
  )
end

end
