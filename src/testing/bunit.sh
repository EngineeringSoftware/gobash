#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# xUnit runner tool for bash.

if [ -n "${BUNIT_MOD:-}" ]; then return 0; fi
readonly BUNIT_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${BUNIT_MOD}/../lang/p.sh
. ${BUNIT_MOD}/../util/flags.sh
. ${BUNIT_MOD}/../util/time.sh
. ${BUNIT_MOD}/testt.sh
. ${BUNIT_MOD}/bunit_result.sh


# ----------
# Variables.

# @mutable
BUNIT_TEST_LINE_RE="^function test_"


# ----------
# Functions.

function bunit_doc() {
        # Module doc.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        cat << END
bunit is an xUnit framework for bash.

bunit enables selecting tests, setting timeout, skipping tests,
generating JUnit xml report, etc.
END
}

function bunit_enabled() {
        # Return true if this module is enabled.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        return $TRUE
}

function _bunit_test_function_signatures() {
        # Return test function signatures in the given file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r pathf="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        grep "${BUNIT_TEST_LINE_RE}" "${pathf}"
}

function bunit_test_functions() {
        # Return test function names in the given file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r pathf="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        _bunit_test_function_signatures $ctx "${pathf}" | \
                $X_SED 's/function \(.*\)[[:space:]]*()[[:space:]]*{.*/\1/g'
}

function _bunit_echo() {
        # Echo that is quiet if directed.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r quiet="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        if is_false $ctx "${quiet}"; then
                echo -e "$@"
        fi
}

function _bunit_format_duration() {
        # Format duration from ms to seconds.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -i millis="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        if [ ${millis} -le 1000 ]; then
                echo "${millis}[ms]"
        else
                local secs=$(time_millis_to_seconds $ctx "${millis}")
                echo "${secs}[sec]"
        fi
}

function _bunit_run_file() {
        # Runs all tests in a single file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r args="${1}"
        local -r res="${2}"
        local -r pathf="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        local -r verbose=$($args $ctx verbose)
        local -r quiet=$($args $ctx quiet)
        local -r retest=$($args $ctx tests)
        local -r max_secs=$($args $ctx max_secs)
        local -r stdout=$($args $ctx stdout)

        local -r btime=$(time_now_millis $ctx)
        # Run one test at a time.
        local func
        for func in $(bunit_test_functions $ctx "${pathf}"); do
                # Filter tests based on a user given argument.
                echo "${func}" | grep "${retest}" > /dev/null || continue

                # Make test functions available and run.
                if is_true $ctx "${verbose}"; then
                        _bunit_echo $ctx "${quiet}" "    ${func} start"
                fi

                local t=$(TestT $ctx "${pathf}" "${func}")
                $res $ctx add "$t"

                $t $ctx _btime $(time_now_millis $ctx)

                # Not using timeout (as not available on Mac).
                #timeout "${max_secs}s" \
                        #"${X_BASH}" -c ". ${pathf}; ${func} \"$t\"" || ec=$?

                # Run each test in a subshell, so we do not exit on error.
                local ec=0
                if is_true $ctx "${stdout}"; then
                        ( . ${pathf}; ${func} "$t" ) &
                        os_wait $! "${max_secs}" || ec=$?
                else
                        ( . ${pathf}; ${func} "$t" 1>/dev/null ) &
                        os_wait $! "${max_secs}" || ec=$?
                fi
                $t $ctx _etime $(time_now_millis $ctx)

                # Save the outcome.
                if [ ${ec} -eq 124 ]; then
                        # We never return this code at the moment.
                        $t $ctx timeout
                elif [ ${ec} -ne 0 ]; then
                        $t $ctx fail
                fi

                if is_true $ctx "${verbose}"; then
                        _bunit_echo $ctx "${quiet}" "    $($t to_string)"
                fi
        done
        local -r etime=$(time_now_millis $ctx)

        local -r duration=$(( ${etime} - ${btime} ))
        _bunit_echo $ctx \
                    "${quiet}" \
                    "  ${pathf} $(_bunit_format_duration $ctx ${duration})"
}

function _bunit_run_dir() {
        # Runs test files in the given directory.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r args="${1}"
        local -r res="${2}"
        local -r pathd="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        local testf
        for testf in $(find "${pathd}" -name "*_test.sh"); do
                _bunit_run_file $ctx "${args}" "${res}" "${testf}"
        done
}

function _bunit_check() {
        # Check arguments for the tool.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r args="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "$($args $ctx paths)" ] && \
                { ctx_w $ctx "'paths' has to be provided."; return $EC; }

        if is_true $ctx "$($args verbose)" && is_true $ctx "$($args quiet)"; then
                echo "'verbose' and 'quiet' cannot be set at the same time."
                return $EC
        fi

        return $TRUE
}

function _bunit_main() {
        # Runs tests based on the given options.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r flags=$(Flags $ctx "Testing package.")
        local flag

        flag=$(Flag $ctx paths string 'Name pattern for finding files with tests.')
        $flags $ctx add "${flag}"

        flag=$(Flag $ctx tests string 'Regular expression for test functions to run.')
        $flags $ctx add "${flag}"

        flag=$(Flag $ctx verbose bool 'Enables verbose output.')
        $flags $ctx add "${flag}"

        flag=$(Flag $ctx quiet bool 'Disable any output.')
        $flags $ctx add "${flag}"

        flag=$(Flag $ctx junitxml string 'File name for a report in the JUnit xml format.')
        $flags $ctx add "${flag}"

        flag=$(Flag $ctx max_secs int 'Max seconds per test.')
        $flags $ctx add "${flag}"

        flag=$(Flag $ctx stdout bool 'Enable stdout from tests.')
        $flags $ctx add "${flag}"

        local -r args=$(Args $ctx)
        $flags $ctx parse "${args}" "$@" || \
                { ctx_w $ctx "cannot parse"; $flags $ctx help; return $EC; }

        _bunit_check $ctx "${args}" || \
                { ctx_w $ctx "arguments do not pass check"; $flags $ctx help; return $EC; }

        local -r quiet=$($args quiet)

        # Iterate over all paths that are given.
        $res $ctx btime $(time_now_millis $ctx)
        local path=$($args $ctx paths)
        if [ -f "${path}" ]; then
                _bunit_run_file $ctx "${args}" "${res}" "${path}"
        elif [ -d "${path}" ]; then
                _bunit_run_dir $ctx "${args}" "${res}" "${path}"
        else
                echo "Could not find path: ${path}"
        fi
        $res $ctx etime $(time_now_millis $ctx)

        if is_false $ctx "${quiet}"; then
                $res $ctx to_string
        fi

        if is_set $ctx "$($args $ctx junitxml)"; then
                $res $ctx to_junitxml "$($args $ctx junitxml)"
        fi

        $res $ctx exit_status
}

function bunit_main() {
        # Main entry into the tool.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # Make a context if one is not given.
        [ -z "${ctx}" ] && ctx=$(ctx_make)

        local -r res=$(BUnitResult $ctx)
        local ec=0
        _bunit_main $ctx "${res}" "$@" || ec=$EC

        # Show if there are errors.
        # ctx_show $ctx

        return ${ec}
}
