@testset "transform" begin

let
    pmb = PassManagerBuilder()
    dispose(pmb)
end

PassManagerBuilder() do pmb
    optlevel!(pmb, 0)
    sizelevel!(pmb, 0)

    unit_at_a_time!(pmb, false)
    unroll_loops!(pmb, false)
    simplify_libcalls!(pmb, false)
    inliner!(pmb, 0)

    Context() do ctx
    LLVM.Module("SomeModule"; ctx) do mod
        FunctionPassManager(mod) do fpm
            populate!(fpm, pmb)
        end
        ModulePassManager() do mpm
            populate!(mpm, pmb)
        end
    end
    end
end

Context() do ctx
LLVM.Module("SomeModule"; ctx) do mod
ModulePassManager() do pm
    aggressive_dce!(pm)
    dce!(pm)
    bit_tracking_dce!(pm)
    alignment_from_assumptions!(pm)
    cfgsimplification!(pm)
    if LLVM.version() >= v"12"
        cfgsimplification!(pm; hoist_common_insts=true)
    end
    dead_store_elimination!(pm)
    scalarizer!(pm)
    merged_load_store_motion!(pm)
    gvn!(pm)
    div_rem_pairs!(pm)
    ind_var_simplify!(pm)
    instruction_combining!(pm)
    instruction_simplify!(pm)
    jump_threading!(pm)
    licm!(pm)
    loop_deletion!(pm)
    loop_idiom!(pm)
    loop_rotate!(pm)
    loop_reroll!(pm)
    loop_unroll!(pm)
    loop_unswitch!(pm)
    loop_distribute!(pm)
    loop_fuse!(pm)
    loop_load_elimination!(pm)
    mem_cpy_opt!(pm)
    merge_functions!(pm)

    partially_inline_lib_calls!(pm)
    lower_switch!(pm)
    promote_memory_to_register!(pm)
    reassociate!(pm)
    sccp!(pm)
    scalar_repl_aggregates!(pm)
    scalar_repl_aggregates!(pm, 1)
    scalar_repl_aggregates_ssa!(pm)
    simplify_lib_calls!(pm)
    tail_call_elimination!(pm)
    if LLVM.version() < v"12"
        constant_propagation!(pm)
    end
    demote_memory_to_register!(pm)
    verifier!(pm)
    correlated_value_propagation!(pm)
    early_cse!(pm)
    lower_expect_intrinsic!(pm)
    type_based_alias_analysis!(pm)
    scoped_no_alias_aa!(pm)
    basic_alias_analysis!(pm)

    loop_vectorize!(pm)
    slpvectorize!(pm)
    load_store_vectorizer!(pm)
    speculative_execution_if_has_branch_divergence!(pm)
    simple_loop_unroll!(pm)
    inductive_range_check_elimination!(pm)

    argument_promotion!(pm)
    constant_merge!(pm)
    dead_arg_elimination!(pm)
    function_attrs!(pm)
    function_inlining!(pm)
    always_inliner!(pm)
    global_dce!(pm)
    global_optimizer!(pm)
    if LLVM.version() < v"12"
        ipconstant_propagation!(pm)
    end
    prune_eh!(pm)
    ipsccp!(pm)
    strip_dead_prototypes!(pm)
    strip_symbols!(pm)
    internalize!(pm)
    internalize!(pm, true)
    internalize!(pm, false)
    internalize!(pm, ["SomeFunction", "SomeOtherFunction"])
end
end
end

end
