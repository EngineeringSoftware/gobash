#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the github module.

if [ -n "${GITHUB_TEST_MOD:-}" ]; then return 0; fi
readonly GITHUB_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${GITHUB_TEST_MOD}/github.sh
. ${GITHUB_TEST_MOD}/../../testing/bunit.sh

GITHUB_CM_URL="https://api.github.com/repos/apache/commons-math"
GITHUB_IT_URL="https://api.github.com/repos/EngineeringSoftware/inlinetest"
GITHUB_TEST_URL="https://api.github.com/repos/EngineeringSoftware/gobash-internal"


# ----------
# Functions.

function github_data() {
        echo "${GITHUB_TEST_MOD}/testdata"
}

function test_github_tags() {
        local -r t="${1}"

        [ -z "${GITHUB_USER}" ] && $t skip "User not set."
        [ -z "${GITHUB_TOKEN}" ] && $t skip "Token not set."
        sys_has_connection || $t skip "No connection."

        github_tags && assert_fail

        local f=$(os_mktemp_file)
        github_tags "${GITHUB_USER}" \
                    "${GITHUB_TOKEN}" \
                    "${GITHUB_IT_URL}" > "${f}" || \
                assert_fail

        local len
        len=$(jq 'length' "${f}") || assert_fail

        assert_ge "${len}" 0
}
readonly -f test_github_tags

function test_github_tag_latest() {
        local val
        val=$(github_tag_latest "$(github_data)/tags.json") || \
                assert_fail
        assert_eq "ase22-ae-r" "${val}"
}
readonly -f test_github_tag_latest

function test_github_prs() {
        local -r t="${1}"

        [ -z "${GITHUB_USER}" ] && $t skip "User not set."
        [ -z "${GITHUB_TOKEN}" ] && $t skip "Token not set."
        sys_has_connection || $t skip "No connection."

        github_prs && assert_fail

        local f=$(os_mktemp_file)
        github_prs "${GITHUB_USER}" \
                   "${GITHUB_TOKEN}" \
                   "${GITHUB_IT_URL}" > "${f}" || \
                assert_fail

        local len
        len=$(jq 'length' "${f}") || assert_fail
        assert_ge "${len}" 0
}
readonly -f test_github_prs

function test_github_branches() {
        local -r t="${1}"

        [ -z "${GITHUB_USER}" ] && $t skip "User not set."
        [ -z "${GITHUB_TOKEN}" ] && $t skip "Token not set."
        sys_has_connection || $t skip "No connection."

        github_branches && assert_fail

        local f=$(os_mktemp_file)
        github_branches "${GITHUB_USER}" \
                        "${GITHUB_TOKEN}" \
                        "${GITHUB_IT_URL}" > "${f}" || \
                assert_fail

        local len
        len=$(jq 'length' "${f}") || assert_fail
        assert_ge "${len}" 0
}
readonly -f test_github_branches

function test_github_pr_commits() {
        local -r t="${1}"

        [ -z "${GITHUB_USER}" ] && $t skip "User not set."
        [ -z "${GITHUB_TOKEN}" ] && $t skip "Token not set."
        sys_has_connection || $t skip "No connection."

        github_pr_commits && assert_fail

        local f=$(os_mktemp_file)
        github_pr_commits "${GITHUB_USER}" \
                          "${GITHUB_TOKEN}" \
                          "${GITHUB_IT_URL}" \
                          "1" > "${f}" || \
                assert_fail

        local len
        len=$(jq 'length' "${f}") || assert_fail
        assert_ge "${len}" 0
}
readonly -f test_github_pr_commits

function test_github_branch_info() {
        local -r t="${1}"

        [ -z "${GITHUB_USER}" ] && $t skip "User not set."
        [ -z "${GITHUB_TOKEN}" ] && $t skip "Token not set."
        sys_has_connection || $t skip "No connection."

        github_branch_info && assert_fail

        local f=$(os_mktemp_file)
        # Fragile (using a random branch name from another repo).
        github_branch_info "${GITHUB_USER}" \
                           "${GITHUB_TOKEN}" \
                           "${GITHUB_IT_URL}" \
                           "junit5-features" > "${f}" || \
                assert_fail

        local len
        len=$(jq 'length' "${f}") || assert_fail
        assert_ge "${len}" 0

        grep '"name": "junit5-features"' "${f}" > /dev/null
}
readonly -f test_github_branch_info

function test_github_branch_latest_sha() {
        github_branch_latest_sha && assert_fail

        local val
        val=$(github_branch_latest_sha "$(github_data)/branch_info.json") || \
                assert_fail
        assert_eq "df900dd855e30cabb8c5b76707b432ff8ff7eb61" "${val}"
}
readonly -f test_github_branch_latest_sha

function test_github_runs() {
        local -r t="${1}"

        [ -z "${GITHUB_USER}" ] && $t skip "User not set."
        [ -z "${GITHUB_TOKEN}" ] && $t skip "Token not set."
        sys_has_connection || $t skip "No connection."

        github_runs && assert_fail

        local f=$(os_mktemp_file)
        github_runs "${GITHUB_USER}" \
                    "${GITHUB_TOKEN}" \
                    "${GITHUB_IT_URL}" \
                    "main" > "${f}" || \
                assert_fail

        local len
        len=$(jq '.total_count' "${f}") || assert_fail
        assert_ge "${len}" 32
}
readonly -f test_github_runs

function test_github_jobs() {
        local -r t="${1}"

        [ -z "${GITHUB_USER}" ] && $t skip "User not set."
        [ -z "${GITHUB_TOKEN}" ] && $t skip "Token not set."
        sys_has_connection || $t skip "No connection."

        github_jobs && assert_fail

        local f=$(os_mktemp_file)
        github_jobs "${GITHUB_USER}" \
                    "${GITHUB_TOKEN}" \
                    "${GITHUB_IT_URL}" \
                    "4852740848" > "${f}" || \
                assert_fail

        local len
        len=$(jq '.total_count' "${f}") || assert_fail
        assert_ge "${len}" 5
}
readonly -f test_github_jobs

function test_github_id_to_sha() {
        github_id_to_sha && assert_fail

        local sha
        sha=$(github_id_to_sha "$(github_data)/runs.json" "4852740848") || \
                assert_fail
        assert_eq "ef380ea266b2c7b2d2e18c9b02ceb27e2f2e65e8" "${sha}"
}
readonly -f test_github_id_to_sha

function test_github_is_outcome() {
        local ec

        ec=0
        github_is_outcome || ec=$?
        assert_ec ${ec}

        github_is_outcome \
                "$(github_data)/jobs.json" \
                "build-linux (3.7)" \
                "Install dependencies" \
                "success" || \
                assert_fail

        ec=0
        github_is_outcome \
                "$(github_data)/jobs.json" \
                "build-linux (3.7)" \
                "Install dependencies" \
                "fail" || ec=$?
        assert_false ${ec}
}
readonly -f test_github_is_outcome

function test_github_create_pr() {
        local -r t="${1}"

        [ -z "${GITHUB_USER}" ] && $t skip "User not set."
        [ -z "${GITHUB_TOKEN}" ] && $t skip "Token not set."
        sys_has_connection || $t skip "No connection."

        github_create_pr && assert_fail

        # Disable the rest of this test.
        return 0

        local f=$(os_mktemp_file)
        github_create_pr "${GITHUB_USER}" \
                         "${GITHUB_TOKEN}" \
                         "${GITHUB_TEST_URL}" \
                         "${FUNCNAME}" \
                         "master" \
                         "testing" \
                         "testing" > "${f}" || \
                assert_fail

        local len
        len=$(jq 'length' "${f}") || assert_fail
        assert_ge "${len}" 48
}
readonly -f test_github_create_pr

function test_github_pr_add_comment() {
        local -r t="${1}"

        [ -z "${GITHUB_USER}" ] && $t skip "User not set."
        [ -z "${GITHUB_TOKEN}" ] && $t skip "Token not set."
        sys_has_connection || $t skip "No connection."

        github_pr_add_comment && assert_fail

        # Disable the rest of this test.
        return 0

        local f=$(os_mktemp_file)
        github_pr_add_comment "${GITHUB_USER}" \
                              "${GITHUB_TOKEN}" \
                              "${GITHUB_TEST_URL}" \
                              "3" \
                              "Adding a comment" > "${f}" || \
                assert_fail

        local len
        len=$(jq 'length' "${f}") || assert_fail
        assert_ge "${len}" "12"
}
readonly -f test_github_pr_add_comment

function test_github_pr_assign_reviewer() {
        local -r t="${1}"

        [ -z "${GITHUB_USER}" ] && $t skip "User not set."
        [ -z "${GITHUB_TOKEN}" ] && $t skip "Token not set."
        sys_has_connection || $t skip "No connection."

        github_pr_assign_reviewer && assert_fail

        # Disable the rest of this test.
        return 0

        github_pr_assign_reviewer "${GITHUB_USER}" \
                                  "${GITHUB_TOKEN}" \
                                  "${GITHUB_TEST_URL}" \
                                  "3" \
                                  "xxx" || \
                assert_fail
}
readonly -f test_github_pr_assign_reviewer

function test_github_commit_info() {
        local -r t="${1}"

        [ -z "${GITHUB_USER}" ] && $t skip "User not set."
        [ -z "${GITHUB_TOKEN}" ] && $t skip "Token not set."
        sys_has_connection || $t skip "No connection."

        github_commit_info && assert_fail

        local f=$(os_mktemp_file)
        github_commit_info "${GITHUB_USER}" \
                           "${GITHUB_TOKEN}" \
                           "${GITHUB_IT_URL}" \
                           "ef380ea" > "${f}" || \
                assert_fail
}
readonly -f test_github_commit_info

function test_github_commits() {
        local -r t="${1}"

        [ -z "${GITHUB_USER}" ] && $t skip "User not set."
        [ -z "${GITHUB_TOKEN}" ] && $t skip "Token not set."
        sys_has_connection || $t skip "No connection."

        github_commits && assert_fail

        local f=$(os_mktemp_file)
        github_commits "${GITHUB_USER}" \
                       "${GITHUB_TOKEN}" \
                       "${GITHUB_IT_URL}" \
                       "ef380ea" > "${f}" || \
                assert_fail

        local len
        len=$(jq -r '.[] | .sha' "${f}" | $X_WC -l | $X_SED 's/^[[:space:]]*//') || \
                assert_fail
        assert_eq 100 "${len}"
}
readonly -f test_github_commits
