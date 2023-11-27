#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Test object (one object given as the first argument to test.)

if [ -n "${TESTT_MOD:-}" ]; then return 0; fi
readonly TESTT_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# ----------
# Functions.

function TestT() {
        # Test object (one object given as an argument to each test).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r file="${1}"
        local -r name="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "_name" "${name}" \
              "_file" "${file}" \
              "_skip" "$FALSE" \
              "_failed" "$FALSE" \
              "_msg" "" \
              "_btime" 0 \
              "_etime" 0
}

function TestT_file() {
        # Return test script name.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r testt="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $testt $ctx _file
}

function TestT_msg() {
        # Return message stored in this object.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r testt="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $testt $ctx _msg
}

function TestT_name() {
        # Return test name.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r testt="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $testt $ctx _name
}

function TestT_skip() {
        # Skip the test (and store the message).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r testt="${1}"
        local -r msg="${2}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $testt $ctx _msg "${msg}"
        $testt $ctx skip_now
}

function TestT_skip_now() {
        # Skip the test and stop its execution by calling exit 0
        # (which will not stop any sub process that was started).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r testt="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $testt $ctx _skip $TRUE
        exit 0
}

function TestT_fail() {
        # Mark the test as failing and continue the execution.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r testt="${1}"
        local -r msg="${2}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $testt $ctx _failed $TRUE
        $testt $ctx _msg "${msg}"
}

function TestT_fail_now() {
        # Mark the test as failing and exit 1 (which will not stop any
        # sub process that was started).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r testt="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $testt $ctx _failed $TRUE
        exit 1
}

function TestT_timeout() {
        # Mark the test as timeout.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r testt="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $testt $ctx _failed $TRUE
        $testt $ctx _msg "Timeout."
}

function TestT_skipped() {
        # Check if test is skipped.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r testt="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # If failed, then not counted as skipped.
        $testt $ctx failed && return $FALSE

        is_true $ctx $($testt $ctx _skip)
}

function TestT_failed() {
        # Check if test failed.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r testt="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        is_true $ctx $($testt $ctx _failed)
}

function TestT_duration() {
        # Return duration of the test (ms).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r testt="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local duration=$(( $($testt $ctx _etime) - $($testt $ctx _btime) ))
        echo "${duration}"
}

function TestT_to_string() {
        # String representation of this test.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r testt="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local outcome
        if $testt $ctx failed; then
                outcome="FAILED"
        elif $testt $ctx skipped; then
                outcome="SKIPPED"
        else
                outcome="PASSED"
        fi

        echo "$($testt $ctx _name) ${outcome}"
}
