#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Util assert functions.
#
# Assert functions exit using the `exit` function. This can have
# impact on execution when code is in subshells. We use assert
# functions extensively and exclusively in tests (which are
# running in subshells).

if [ -n "${ASSERT_MOD:-}" ]; then return 0; fi
readonly ASSERT_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${ASSERT_MOD}/bool.sh
. ${ASSERT_MOD}/core.sh
. ${ASSERT_MOD}/sys.sh


# ----------
# Functions.

function assert_fail() {
        # Fail (exit) with the given message.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; exit $EC; }
        local -r msg="${1}"
        shift 0 || { ctx_wn $ctx; exit $EC; }

        local text="ERROR"
        [ ! -z "${msg}" ] && text="${text}: (${msg})"

        echo "${text}" 1>&2
        sys_stack_trace $ctx 1>&2
        exit 1
}

function assert_ze() {
        # Check that the given value is zero; exit if not true.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; exit $EC; }
        local -r val="${1}"
        local -r msg="${2}"
        shift 1 || { ctx_wn $ctx; exit $EC; }

        local text="ERROR: Expected zero but was ${val}"
        [ ! -z "${msg}" ] && text="${text} (${msg})"

        if [ ${val} -ne 0 ]; then
                echo "${text}" 1>&2
                sys_stack_trace $ctx 1>&2
                exit 1
        fi
}

function assert_nz() {
        # Check that the given value is not zero; exit if not true.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; exit $EC; }
        local -r val="${1}"
        local -r msg="${2}"
        shift 1 || { ctx_wn $ctx; exit $EC; }

        local text="ERROR: Expected non-zero outcome but was zero"
        [ ! -z "${msg}" ] && text="${text} (${msg})"

        if [ ${val} -eq 0 ]; then
                echo "${text}" 1>&2
                sys_stack_trace $ctx 1>&2
                exit 1
        fi
}

function assert_eq() {
        # Check that two values are equal (lexical); exit if not true.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 2 ] && { ctx_wn $ctx; exit $EC; }
        local -r one="${1}"
        local -r two="${2}"
        local -r msg="${3}"
        shift 2 || { ctx_wn $ctx; exit $EC; }

        local text="ERROR: <${one}> not equal to <${two}>"
        [ ! -z "${msg}" ] && text="${text} (${msg})"

        if [ "${one}" != "${two}" ]; then
                echo "${text}" 1>&2
                sys_stack_trace $ctx 1>&2
                exit 1
        fi
}

function assert_ne() {
        # Check that two values are not equal (lexical); exit if yes.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 2 ] && { ctx_wn $ctx; exit $EC; }
        local -r one="${1}"
        local -r two="${2}"
        local -r msg="${3}"
        shift 2 || { ctx_wn $ctx; exit $EC; }

        if [ "${one}" == "${two}" ]; then
                echo "ERROR: <${one}> equal to <${two}> (${msg})" 1>&2
                sys_stack_trace $ctx 1>&2
                exit 1
        fi
}

function assert_gt() {
        # Exit if the first arg is less or equal to the second (ints).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 2 ] && { ctx_wn $ctx; exit $EC; }
        local -r one="${1}"
        local -r two="${2}"
        local -r msg="${3}"
        shift 2 || { ctx_wn $ctx; exit $EC; }

        if [ "${one}" -le "${two}" ]; then
                echo "ERROR: <${one}> not greater than <${two}> (${msg})" 1>&2
                sys_stack_trace $ctx 1>&2
                exit 1
        fi
}

function assert_ge() {
        # Exit if the first arg is less than the second (ints).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 2 ] && { ctx_wn $ctx; exit $EC; }
        local -r one="${1}"
        local -r two="${2}"
        local -r msg="${3}"
        shift 2 || { ctx_wn $ctx; exit $EC; }

        if [ "${one}" -lt "${two}" ]; then
                echo "ERROR: <${one}> not greater than <${two}> (${msg})" 1>&2
                sys_stack_trace $ctx 1>&2
                exit 1
        fi
}

function assert_lt() {
        # Exit if the first arg is greater or equal to second (ints).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 2 ] && { ctx_wn $ctx; exit $EC; }
        local -r one="${1}"
        local -r two="${2}"
        local -r msg="${3}"
        shift 2 || { ctx_wn $ctx; exit $EC; }

        if [ "${one}" -ge "${two}" ]; then
                echo "ERROR: <${one}> not less than <${two}> (${msg})" 1>&2
                sys_stack_trace $ctx 1>&2
                exit 1
        fi
}

function assert_bw() {
        # Exit if the first arg is not between the next two exclusive
        # (ints).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 3 ] && { ctx_wn $ctx; exit $EC; }
        local -r val="${1}"
        local -r min="${2}"
        local -r max="${3}"
        local -r msg="${4}"
        shift 3 || { ctx_wn $ctx; exit $EC; }

        if [ "${val}" -lt "${min}" -o "${val}" -gt "${max}" ]; then
                echo "ERROR: <${val}> not between <${min}> and <${max}>." 1>&2
                sys_stack_trace $ctx 1>&2
                exit 1
        fi
}

function assert_dir_exists() {
        # Exit if directory does not exist.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; exit $EC; }
        local -r dir="${1}"
        local -r msg="${2:-}"
        shift 1 || { ctx_wn $ctx; exit $EC; }

        if [ ! -d "${dir}" ]; then
                echo "ERROR: Directory ${dir} does not exist (${msg})." 1>&2
                sys_stack_trace $ctx 1>&2
                exit 1
        fi
}

function assert_file_exists() {
        # Exit if file does not exit.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; exit $EC; }
        local -r f="${1}"
        local -r msg="${2:-}"
        shift 1 || { ctx_wn $ctx; exit $EC; }

        if [ ! -f "${f}" ]; then
                echo "ERROR: File ${f} does not exist (${msg})" 1>&2
                sys_stack_trace $ctx 1>&2
                exit 1
        fi
}

function assert_has_prefix() {
        # Exit if the value does ont have the given prefix.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; exit $EC; }
        local -r val="${1}"
        local -r prefix="${2}"
        shift 2 || { ctx_wn $ctx; exit $EC; }

        if [[ "${val}" != "${prefix}"* ]]; then
                echo "ERROR: <${val}> does not start with <${prefix}>"
                sys_stack_trace $ctx 1>&2
                exit 1
        fi
}

function assert_exe_exists() {
        # Exit if the executable does not exit.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; exit $EC; }
        local -r exe="${1}"
        local msg="${2:-}"
        shift 1 || { ctx_wn $ctx; exit $EC; }

        ! is_exe $ctx "${exe}" && assert_fail $ctx "${msg}"

        return 0
}

function assert_port_free() {
        # Exit if the given port is not free.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; exit $EC; }
        local -r port="${1}"
        shift 1 || { ctx_wn $ctx; exit $EC; }

        [ -z "${port}" ] && assert_fail $ctx "Port number is required."

        if lsof -i:${port}; then
                echo "ERROR: Some processes are listening on ${port}." 1>&2
                sys_stack_trace $ctx 1>&2
                exit 1
        fi
}

function assert_user() {
        # Exit if the given name does not match the current user.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; exit $EC; }
        local -r expected="${1}"
        local -r msg="${2}"
        shift 1 || { ctx_wn $ctx; exit $EC; }

        assert_eq $ctx "$(whoami)" "${expected}" "${msg}"
}

function assert_user_starts_with() {
        # Exit if the given name is not a prefix of the current user.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; exit $EC; }
        local -r str="${1}"
        local -r msg="${2}"
        shift 1 || { ctx_wn $ctx; exit $EC; }

        [[ $(whoami) == ${str}* ]] || assert_fail $ctx "${msg}"
}

function assert_function_exists() {
        # Exit if the given name is not a function.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; exit $EC; }
        local -r func="${1}"
        local -r msg="${2}"
        shift 1 || { ctx_wn $ctx; exit $EC; }

        local name
        name=$(type -t "${func}") || assert_fail $ctx "Missing ${func}"
        assert_eq $ctx "${name}" "function"
}

function assert_false() {
        # Exit if the given value is not false.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; exit $EC; }
        local -r val="${1}"
        local -r msg="${2}"
        shift 1 || { ctx_wn $ctx; exit $EC; }

        is_false $ctx "${val}" || assert_fail $ctx "${msg}"
}

function assert_ec() {
        # Exit if the value is not an error as defined by this lib.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; exit $EC; }
        local -r val="${1}"
        local -r msg="${2}"
        shift 1 || { ctx_wn $ctx; exit $EC; }

        [ ${val} -eq $EC ] || assert_fail $ctx "${msg}"
}
