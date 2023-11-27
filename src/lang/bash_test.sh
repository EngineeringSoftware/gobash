#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the bash module.

if [ -n "${BASH_TEST_MOD:-}" ]; then return 0; fi
readonly BASH_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${BASH_TEST_MOD}/assert.sh
. ${BASH_TEST_MOD}/bash.sh
. ${BASH_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_bash_version_major() {
        bash_version_major || assert_fail
}
readonly -f test_bash_version_major

function test_bash_version_minor() {
        bash_version_minor || assert_fail
}
readonly -f test_bash_version_minor

function test_bash_version_path() {
        bash_version_patch || assert_fail
}
readonly -f test_bash_version_path

function test_bash_version_build() {
        bash_version_build || assert_fail
}
readonly -f test_bash_version_build

function test_bash_version_release() {
        bash_version_release || assert_fail
}
readonly -f test_bash_version_release

function test_bash_version_arch() {
        bash_version_arch || assert_fail
}
readonly -f test_bash_version_arch

function test_bash_ci_version() {
        local t="${1}"

        [ -z "${GITHUB_ACTIONS}" ] && $t skip "Not running in CI."
        assert_eq "$(bash_version_major)" "${GOBASH_CI_BASH_VERSION}"
}
readonly -f test_bash_ci_version
