#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the http module.

if [ -n "${HTTP_TEST_MOD:-}" ]; then return 0; fi
readonly HTTP_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${HTTP_TEST_MOD}/http.sh
. ${HTTP_TEST_MOD}/../util/math.sh
. ${HTTP_TEST_MOD}/../testing/bunit.sh

readonly HTTP_SCRIPT="${HTTP_TEST_MOD}/$(basename ${BASH_SOURCE})"


# ----------
# Functions.

# Handles have to be defined in the global scope.
function handle_whoami() {
        local -r res="${1}"
        local -r req="${2}"

        $res write "$(whoami)"
}

# Handles have to be defined in the global scope.
function handle_date() {
        local -r res="${1}"
        local -r req="${2}"

        $res write "Server date: $($X_DATE)"
}

function handle_with_error() {
        return $EC
}

function test_http_handle_func() {
        local -r address="127.0.0.1"
        local -r port=9002

        local http
        http=$(Http "${address}" "${port}") || \
                assert_fail

        $http handle_func && \
                assert_fail

        $http handle_func "/whoami" && \
                assert_fail

        $http handle_func "/whoami" "${HTTP_SCRIPT}" handle_whoami || \
                assert_fail

        $http handle_func "/whoami" "${HTTP_SCRIPT}" this_is_definitely_not_a_function && \
                assert_fail

        return 0
}
readonly -f test_http_handle_func

function test_http_ok() {
        local -r t="${1}"
        ! http_enabled && $t skip "Not enabled."

        local -r address="127.0.0.1"
        local -r port=9002

        local http
        http=$(Http "${address}" "${port}") || \
                assert_fail

        $http handle_func "/whoami" "${HTTP_SCRIPT}" handle_whoami || \
                assert_fail
        $http handle_func "/date" "${HTTP_SCRIPT}" handle_date || \
                assert_fail
        assert_eq $($($http handlers) len) 2

        $http listen_and_serve
        # TODO(milos): detach from sleep.
        sleep 1

        local ec=0

        local -r tmpf=$(os_mktemp_file)
        curl "http://${address}:${port}/whoami" > "${tmpf}" 2>&1 || ec=$?
        grep "$(whoami)" "${tmpf}" > /dev/null || ec=$?

        curl "http://${address}:${port}/date" > "${tmpf}" 2>&1 || ec=$?
        grep 'Server date' "${tmpf}" > /dev/null || ec=$?

        # Kill before assert.
        $http kill_and_wait || assert_fail
        
        assert_ze ${ec}
}
readonly -f test_http_ok

function test_http_not_found() {
        local -r t="${1}"
        ! http_enabled && $t skip "Not enabled."

        local -r address="127.0.0.1"
        local -r port=9002
        
        local http
        http=$(Http "${address}" "${port}") || \
                assert_fail

        $http listen_and_serve
        # TODO(milos): detach from sleep.
        sleep 1

        local ec=0

        local -r tmpf=$(os_mktemp_file)
        curl -v "http://${address}:${port}/whoami" > "${tmpf}" 2>&1 || ec=$?
        grep 'Not Found' "${tmpf}" > /dev/null || ec=$?

        $http kill_and_wait

        assert_ze ${ec}
}
readonly -f test_http_not_found

function test_http_bad_request() {
        local -r t="${1}"
        ! http_enabled && $t skip "Not enabled."

        local -r address="127.0.0.1"
        local -r port=9002
        
        local http
        http=$(Http "${address}" "${port}") || \
                assert_fail

        $http listen_and_serve
        # TODO(milos): detach from sleep.
        sleep 1

        local ec=0

        local -r tmpf=$(os_mktemp_file)
        curl -v -X ZZZ "http://${address}:${port}/whoami" > "${tmpf}" 2>&1 || ec=$?
        grep '400 Bad Request' "${tmpf}" > /dev/null || ec=$?

        $http kill_and_wait

        assert_ze ${ec}
}
readonly -f test_http_bad_request

function test_http_internal_server_error() {
        local -r t="${1}"
        ! http_enabled && $t skip "Not enabled."

        local -r address="127.0.0.1"
        local -r port=9002
        
        local http
        http=$(Http "${address}" "${port}") || \
                assert_fail

        $http handle_func "/info" "${HTTP_SCRIPT}" handle_with_error || \
                assert_fail

        $http listen_and_serve
        # TODO(milos): detach from sleep.
        sleep 1

        local ec=0

        local -r tmpf=$(os_mktemp_file)
        curl -v "http://${address}:${port}/info" > "${tmpf}" 2>&1 || ec=$?
        grep '500 Internal Server Error' "${tmpf}" > /dev/null || ec=$?

        $http kill_and_wait

        assert_ze ${ec}
}
readonly -f test_http_internal_server_error
