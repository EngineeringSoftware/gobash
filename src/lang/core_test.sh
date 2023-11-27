#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the core module.
#
# These tests intentionally do *not* use assert functions.

if [ -n "${CORE_TEST_MOD:-}" ]; then return 0; fi
readonly CORE_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${CORE_TEST_MOD}/core.sh
. ${CORE_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_core_mktemp_file() {
        local -r tmpd="$(core_tmp_dir)"

        local f
        f=$(core_mktemp_file "${tmpd}" "ABC@XXXX" ".z") || return $EC

        local -r re="${tmpd}/ABC@.....z"
        [[ "${f}" =~ ${re} ]] || return $EC

        f=$(core_mktemp_file "${tmpd}" "XXXX" ".json")
        [[ "${f}" = *".json" ]] || return $EC

        f=$(core_mktemp_file "${tmpd}" "XXXX" ".ctx")
        [[ "${f}" = *".ctx" ]] || return $EC
}
readonly -f test_core_mktemp_file

function test_core_ctx_make() {
        local -r c1=$(ctx_make)
        local -r c2=$(ctx_make)

        [ "${c1}" != "${c2}" ]
}
readonly -f test_core_ctx_make

function test_core_ctx_is() {
        local -r c=$(ctx_make)

        is_ctx "$c"
}
readonly -f test_core_ctx_is

function test_core_ctx_w() {
        local -r ctx=$(ctx_make)

        ctx_w "$ctx" "random message"

        [ ! -f "$(core_obj_dir)/${ctx}.ctx" ] && return $EC
        [ ! -f "$(core_obj_dir)/${ctx}.strace" ] && return $EC

        return 0
}
readonly -f test_core_ctx_w

function test_core_ctx_show() {
        local -r ctx=$(ctx_make)

        ctx_w "$ctx" "random message" || return $EC
        ctx_show "$ctx" | grep 'random'
}
readonly -f test_core_ctx_show

function test_core_ctx_global() {
        ctx_w "random message" || return $EC

        [ ! -f "$(core_obj_dir)/context.txt" ] && return $EC
        [ ! -f "$(core_obj_dir)/strace.txt" ] && return $EC

        ctx_show | grep 'random'
}
readonly -f test_core_ctx_global
