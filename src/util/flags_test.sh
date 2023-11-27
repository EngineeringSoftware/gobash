#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the flags module.

if [ -n "${FLAGS_TEST_MOD:-}" ]; then return 0; fi
readonly FLAGS_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${FLAGS_TEST_MOD}/flags.sh
. ${FLAGS_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_flags_make() {
        local flags
        flags=$(Flags) && \
                assert_fail

        return 0
}
readonly -f test_flags_make

function test_flags_no_args() {
        local flags
        flags=$(Flags "test") || \
                assert_fail

        local -r omap=$(Map)
        _flags_parse_to_map "${omap}" "${flags}" || \
                assert_fail
        assert_eq 0 "$($omap len)"
}
readonly -f test_flags_no_args

function test_flags_empty_val() {
        local flags
        flags=$(Flags "test") || \
                assert_fail

        $flags add "$(Flag value string 'anything')" || \
                assert_fail

        local -r omap=$(Map)
        _flags_parse_to_map "${omap}" "${flags}" "--value" "" || \
                assert_fail
        assert_eq "" "$($omap get value)"
}
readonly -f test_flags_empty_val

function test_flags_bool() {
        local flags
        flags=$(Flags "test") || \
                assert_fail

        $flags add "$(Flag value ${BOOL} 'anything')" || \
                assert_fail

        local -r omap=$(Map)
        _flags_parse_to_map "${omap}" "${flags}" "--value" || \
                assert_fail
        assert_eq "true" $($omap get "value")
}
readonly -f test_flags_bool

function test_flags_bools() {
        local flags
        flags=$(Flags "test") || \
                assert_fail

        $flags add "$(Flag enable bool 'anything')" || \
                assert_fail
        $flags add "$(Flag push bool 'anything')" || \
                assert_fail

        local -r omap=$(Map)
        _flags_parse_to_map "${omap}" "${flags}" "--enable" "--push" || \
                assert_fail
        assert_eq "true" $($omap get "enable")
        assert_eq "true" $($omap get "push")
}
readonly -f test_flags_bools

function test_flags_dashes() {
        local flags
        flags=$(Flags "test") || \
                assert_fail

        $flags add "$(Flag num_cores_kube int 'anything')" || \
                assert_fail
        $flags add "$(Flag num_runs_parallel int 'anything')" || \
                assert_fail

        local -r omap=$(Map)
        _flags_parse_to_map "${omap}" \
                            "${flags}" \
                            "--num-cores-kube" 3 \
                            "--num-runs-parallel" 4 || \
                assert_fail
        assert_eq 3 $($omap get "num_cores_kube")
        assert_eq 4 $($omap get "num_runs_parallel")
}
readonly -f test_flags_dashes

function test_flags_various() {
        local flags
        flags=$(Flags "test") || \
                assert_fail

        $flags add "$(Flag enable bool 'anything')" || \
                assert_fail
        $flags add "$(Flag num_cores int 'anything')" || \
                assert_fail
        $flags add "$(Flag type string 'anything')" || \
                assert_fail

        local -r omap=$(Map)
        _flags_parse_to_map "${omap}" \
                            "${flags}" \
                            "--enable" \
                            "--num-cores" 3 \
                            "--type" "unknown" || \
                assert_fail

        is_true $($omap get "enable") || \
                assert_fail

        assert_eq "unknown" $($omap get "type")
        assert_eq 3 $($omap get "num_cores")
}
readonly -f test_flags_various

function test_flags_spaces() {
        local flags
        flags=$(Flags "test") || \
                assert_fail

        $flags add "$(Flag value string 'anything')" || \
                assert_fail

        local -r omap=$(Map)
        _flags_parse_to_map "${omap}" \
                            "${flags}" \
                            "--value" "something else" || \
                assert_fail
        assert_eq "something else" "$($omap get value)"
}
readonly -f test_flags_spaces

function test_flags_parse() {
        local flags
        flags=$(Flags "Options for my program.") || \
                assert_fail
        $flags add "$(Flag min ${INT} 'min value')" || \
                assert_fail
        $flags add "$(Flag max ${INT} 'max value')" || \
                assert_fail

        local -r args=$(Args)
        $flags parse "${args}" "--max" 5 "--min" 3 || \
                assert_fail

        assert_eq 3 "$($args min)"
        assert_eq 5 "$($args max)"

        $flags parse "${args}" "--max" 10 || \
                assert_fail
        assert_eq 10 "$($args max)"
}
readonly -f test_flags_parse

function test_flags_parse_invalid() {
        local flags
        flags=$(Flags "Options for my function.") || \
                assert_fail
        $flags add "$(Flag min ${INT} 'min value')" || \
                assert_fail
        $flags add "$(Flag max ${INT} 'max value')" || \
                assert_fail

        local -r args=$(Args)
        local -r ctx=$(ctx_make)
        $flags $ctx parse "${args}" "--x" 5 && \
                assert_fail
        ctx_show $ctx | grep "Flag 'x' does not exit." || \
                assert_fail
}
readonly -f test_flags_parse_invalid

function test_flags_parse_types() {
        local flags
        flags=$(Flags "Checking types")
        $flags add "$(Flag i int 'anything')"
        $flags add "$(Flag f float 'anything')"
        $flags add "$(Flag z bool 'anything')"

        local -r args=$(Args)
        local ctx

        ctx=$(ctx_make)
        $flags $ctx parse "${args}" "--i" "abc" && \
                assert_fail
        ctx_show $ctx | grep "Value abc cannot be parsed to int." || \
                assert_fail

        ctx=$(ctx_make)
        $flags $ctx parse "${args}" "--f" "abc" && \
                assert_fail
        ctx_show $ctx | grep "Value abc cannot be parsed to float." || \
                assert_fail

        ctx=$(ctx_make)
        $flags $ctx parse "${args}" "--z" "abc" && \
                assert_fail
        ctx_show $ctx | grep "Value abc cannot be parsed to bool." || \
                assert_fail

        $flags parse "${args}" "--i" 10 "--f" 33.3 "--z" || \
                assert_fail
        assert_eq 10 "$($args i)"
        assert_eq 33.3 "$($args f)"
        assert_eq "true" "$($args z)"
}
readonly -f test_flags_parse_types
