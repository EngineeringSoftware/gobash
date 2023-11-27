#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the bdoc module.

if [ -n "${BDOC_TEST_MOD:-}" ]; then return 0; fi
readonly BDOC_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${BDOC_TEST_MOD}/bdoc.sh
. ${BDOC_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_bdoc_file() {
        local -r tmpf=$(os_mktemp_file)
        _bdoc_file "${BDOC_TEST_MOD}/bdoc.sh" "bdoc" > "${tmpf}"

        grep '@file bdoc.h' "${tmpf}" || \
                assert_fail

        grep '@brief Document generation tool.' "${tmpf}" || \
                assert_fail
}
readonly -f test_bdoc_file
