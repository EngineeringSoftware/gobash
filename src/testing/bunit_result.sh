#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Test result related structs and functions.

if [ -n "${BUNIT_RESULT_MOD:-}" ]; then return 0; fi
readonly BUNIT_RESULT_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# ----------
# Functions.

function BUnitResult() {
        # Result of a test run.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "tests" "$(List $ctx)" \
              "timestamp" "$(time_now_iso8601)" \
              "btime" 0 \
              "etime" 0
}

function BUnitResult_add() {
        # Add a test result.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r testt="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        $($res $ctx tests) $ctx add "${testt}"
}

function BUnitResult_to_string() {
        # String version of the result.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r tests=$($res $ctx tests)
        local -r total=$($tests $ctx len)
        local -r failed=$($($tests $ctx filter TestT_failed) $ctx len)
        local -r skipped=$($($tests $ctx filter TestT_skipped) $ctx len)

        echo "Tests run: ${total}, failed: ${failed}, skipped: ${skipped}."
        echo "Total time: $(_bunit_format_duration $ctx $($res $ctx duration))"
}

function BUnitResult_duration() {
        # Duration of the total test run.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local duration=$(( $($res $ctx etime) - $($res $ctx btime) ))
        echo "${duration}"
}

function BUnitResult_total() {
        # Total number of tests.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $($res $ctx tests) $ctx len
}

function BUnitResult_failed() {
        # Failed number of tests.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r tests=$($res $ctx tests)
        local -r lst=$($tests $ctx filter TestT_failed)
        echo "${lst}"
}

function BUnitResult_exit_status() {
        # Overall exit status.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $($res $ctx tests) $ctx any_match TestT_failed && return $EC
        return 0
}

function BUnitResult_to_junitxml_echo() {
        # Generate junitxml format for the result.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        function to_sec() {
                echo "scale=3; $($1 duration) / 1000" | bc | $X_SED 's/^\.\(.*\)/0.\1/g'
        }

        echo '<?xml version="1.0" encoding="utf-8"?>'
        echo '<testsuites>'

        local -r tests=$($res $ctx tests)
        local -r -i total=$($tests $ctx len)
        local -r -i failed=$($($tests $ctx filter TestT_failed) $ctx len)
        local -r -i skipped=$($($tests $ctx filter TestT_skipped) $ctx len)

        echo '  <testsuite name="bunit"'
        echo '    errors="0"'
        echo "    failures=\"${failed}\""
        echo "    skipped=\"${skipped}\""
        echo "    tests=\"${total}\""
        echo "    time=\"$(to_sec "$res")\""
        echo "    timestamp=\"$($res timestamp)\""
        echo "    hostname=\"$(hostname)\">"

        local -i len
        len=$($tests $ctx len)

        local -i i
        for (( i=0; i<${len}; i++ )); do
                local testt=$($tests $ctx get ${i})
                echo "      <testcase classname=\"$($testt file)\""
                echo "        name=\"$($testt name)\""
                echo "        time=\"$(to_sec "$testt")\">"

                if $testt $ctx failed; then
                        echo "<failure message=\"$($testt msg)\">$($testt msg)</failure>"
                fi
                if $testt $ctx skipped; then
                        echo "<skipped type=\"bunit\" message=\"$($testt msg)\">$($testt msg)</skipped>"
                fi

                echo "      </testcase>"
        done

        echo '  </testsuite>'
        echo '</testsuites>'
}

function BUnitResult_to_junitxml() {
        # Generate junitxml format for the result.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r pathf="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        $res $ctx to_junitxml_echo > "${pathf}"
}
