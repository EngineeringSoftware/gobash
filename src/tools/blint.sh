#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Lint tool.

if [ -n "${BLINT_MOD:-}" ]; then return 0; fi
readonly BLINT_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${BLINT_MOD}/../lang/p.sh
. ${BLINT_MOD}/../util/p.sh
. ${BLINT_MOD}/../testing/p.sh


# ----------
# Functions.

function BLintResult() {
        # Lint result.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "nfailing" 0
}

function BLintResult_inc_failing() {
        # Increment number of failing cases.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $res $ctx nfailing $(( $($res $ctx nfailing) + 1 ))
}

function BLintResult_has_failing() {
        # Return true if there is any failing case.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ $($res $ctx nfailing) -gt 0 ]
}

function _blint_check_she_bang() {
        # Check that each script starts with #!/bin/bash.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r pathf="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        head -n 1 "${pathf}" | grep '^#!/bin/bash$' > /dev/null || \
                { ctx_w $ctx "script has to start with #!/bin/bash (${pathf})";
                  $res $ctx inc_failing; }
}

function _blint_check_tabs() {
        # Check there are no tabs.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r pathf="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -r nlines=$(cat "${pathf}" | $X_AWK '/\t/' | $X_WC -l | $X_SED 's/^[[:space:]]*//')
        if [ ${nlines} -gt 0 ]; then
                echo "Tabs in ${pathf}."
                $res $ctx inc_failing
        fi
}

function _blint_check_function_signature() {
        # Check a single function signature.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r pathf="${1}"
        local -r func="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # () { has to be on the same line.
        grep "^function ${func}" "${pathf}" | \
                grep '() {' > /dev/null || return $FALSE

        # Do not check test files below.
        [[ ${pathf} = *"_test.sh" ]] && return 0

        # Function doc has to be present.
        grep -A 1 "^function ${func}" "${pathf}" | \
                tail -n 1 | \
                grep '^[[:space:]]*# ' > /dev/null || return $FALSE

        # Skip over the doc lines.
        local n=2
        while :; do
                grep -A ${n} "^function ${func}" "${pathf}" | \
                        tail -n 1 | \
                        grep '^[[:space:]]*#' > /dev/null || break
                n=$(( ${n} + 1 ))
        done

        # Ignore files that do not have to follow the rules.
        if [[ "${pathf}" = *"x.sh" || "${pathf}" || *"core.sh" || "${pathf}" != *"make.sh" ]]; then
                return 0
        fi

        # Check the context line.
        grep -A "${n}" "^function ${func}" "${pathf}" | \
                tail -n 1 | \
                grep 'local ctx; is_ctx "${1}" && ctx="${1}" && shift' > /dev/null || return $FALSE
        n=$(( ${n} + 1 ))

        # Ensure there is a check for the num of args.
        grep -A "${n}" "^function ${func}" "${pathf}" | \
                tail -n 1 | \
                grep '^[[:space:]]*\[ $# -' | \
                grep '$EC' > /dev/null || return $FALSE

        local nargs=$(grep -A ${n} "^function ${func}" "${pathf}" | \
                              tail -n 1 | \
                              $X_SED 's/.*\[ \$# -.. \(.*\) \].*/\1/g')
        n=$(( ${n} + 1 ))

        # Ensure arguments are correct.
        local nlocal=0
        while :; do
                # TODO: pick argument names (and check).
                # TODO: check argument values $1, ...

                # Skip comment (single line at most).
                grep -A ${n} "^function ${func}" "${pathf}" | \
                        tail -n 1 | \
                        grep '^[[:space:]]*# ' > /dev/null && \ {
                                { n=$(( ${n} + 1 )); }

                grep -A ${n} "^function ${func}" "${pathf}" | \
                        tail -n 1 | \
                        grep '^[[:space:]]*local ' > /dev/null || break
                n=$(( ${n} + 1 ))
                nlocal=$(( ${nlocal} + 1 ))
        done
        # Number of local has to be more or equal to expected args.
        [ ${nlocal} -lt ${nargs} ] && return $FALSE

        # Command shift present (with return $EC or exit $EC).
        # TODO: check return $EC OR exit $EC
        grep -A ${n} "^function ${func}" "${pathf}" | \
                tail -n 1 | \
                grep '^[[:space:]]*shift '"${nargs}"'' > /dev/null || return $FALSE
        n=$(( ${n} + 1 ))

        # Empty line has to be present.
        grep -A "${n}" "^function ${func}" "${pathf}" | \
                tail -n 1 | \
                grep '^$' > /dev/null || return $FALSE

        return 0
}

function _blint_check_signature() {
        # Check that each function has "() {".
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r pathf="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local func
        for func in $(sys_functions_in_file $ctx "${pathf}"); do
                _blint_check_function_signature $ctx "${pathf}" "${func}" || \
                        { echo "Incorrect function signature ${func} in ${pathf}.";
                          $res $ctx inc_failing; }
        done
}

function _blint_check_brief_doc() {
        # Check that each file has a license and documentation.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r pathf="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local nl=$(grep -A 5 '#!/bin/bash' "${pathf}" | grep '^#' | $X_WC -l | $X_SED 's/^[[:space:]]*//')
        if [ ${nl} -lt 5 ]; then
                echo "Brief documentation for ${pathf} is not properly formatted."
                $res $ctx inc_failing
        fi
}

function _blint_check_readonly_tests() {
        # Check that each test function is declared readonly.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r pathf="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        #[[ "${pathf}" != *"_test.sh" ]] && return 0

        local tmpf=$(os_mktemp_file $ctx)
        bunit_test_functions $ctx "${pathf}" | \
                $X_SED 's/^\(.*\)/^readonly -f \1$/g' > "${tmpf}"

        local expected=$(cat "${tmpf}" | $X_WC -l | $X_SED 's/^[[:space:]]*//')
        local actual=$(grep -f "${tmpf}" "${pathf}" | $X_WC -l | $X_SED 's/^[[:space:]]*//')
        if [ ${expected} -ne ${actual} ]; then
                echo "There are tests that are not declared as readonly in ${pathf}."
                $res $ctx inc_failing
        fi
}

function _blint_check_gobash_constants() {
        # Check that file name is in the name of the dir at the
        # beginning of the file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r pathf="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local expect
        if [[ "${pathf}" = *"/p.sh" ]]; then
                local d=$(dirname "${pathf}")
                d=$(cd "${d}"; pwd)
                d=$(basename "${d}")

                if [ "${d}" = "gobash" ]; then
                        expect="GOBASH_MOD"
                else
                        expect="${d}_PACKAGE"
                fi
        else
                local name=$(basename "${pathf}" ".sh")
                expect="${name}"
        fi
        expect=$(strings_to_upper $ctx "${expect}")

        local n=$(grep "${expect}" "${pathf}" | $X_WC -l | $X_SED 's/^[[:space:]]*//')
        if [ ${n} -lt 2 ]; then
                echo "Not a proper directory name in ${pathf}."
                $res $ctx inc_failing
        fi
}

function _blint_check_end_of_line_spaces() {
        # Check spaces at the end of each line in a file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r pathf="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        grep '\s$' "${pathf}" > /dev/null && \
                { echo "Spaces at the end of line in ${pathf}.";
                  grep -n '\s$' "${pathf}";
                  $res $ctx inc_failing; }
}

function _blint_check_if_then() {
        # Check that each 'if' has 'then' on the same line.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r pathf="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        grep 'if \[' "${pathf}" | grep -v ']; then' && \
                { echo "Each 'if' needs to have 'then' on the same line in ${pathf}.";
                  $res $ctx inc_failing; }
}

function _blint_check_spaces_between_words() {
        # Check more than one space in between words.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r pathf="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        grep -E '[[:alnum:]][[:space:]][[:space:]]+[[:alnum:]]' "${pathf}" > /dev/null && \
                { echo "Spaces in the middle ${pathf}.";
                  $res $ctx inc_failing; }
}

function _blint_check_file() {
        # Check one file at a time.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r pathf="${2}"
        local -r funs="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        local -i i
        for (( i=0; i<$($funs len); i++ )); do
                local fun=$($funs get ${i})
                is_function $ctx "${fun}" || \
                        { ctx_w $ctx "incorrect function '${fun}'"; return $EC; }
                ${fun} $ctx "${res}" "${pathf}"
        done
}

function _blint_check_dir() {
        # Check .sh files that can be found from the given path.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r pathd="${2}"
        local -r funs="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        local pathf
        for pathf in $(find "${pathd}" -name "*.sh"); do
                _blint_check_file $ctx "${res}" "${pathf}" "${funs}"
        done
}

function _blint_parse_flags() {
        # Parse flags and check values.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r args="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r flags=$(Flags $ctx "Linting package.")
        $flags $ctx add "$(Flag $ctx paths ${STRING} 'Name pattern for finding files to lint.')"

        $flags $ctx parse "${args}" "$@" || \
                { ctx_show $ctx; $flags $ctx help; return $EC; }

        if is_empty $ctx "$($args paths)"; then
                ctx_w $ctx "paths cannot be empty"
                $flags $ctx help
                return $EC
        fi

        return 0
}

# TODO: avoid duplicate code in tools.
function blint_main() {
        # Linter entry point.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local -r args=$(Args $ctx)
        _blint_parse_flags $ctx "${args}" "$@" || \
                { ctx_w $ctx "cannot parse flags"; return $EC; }

        local res=$(BLintResult $ctx)

        local checks=$(List $ctx)
        $checks $ctx add _blint_check_she_bang
        $checks $ctx add _blint_check_tabs
        $checks $ctx add _blint_check_brief_doc
        $checks $ctx add _blint_check_readonly_tests
        $checks $ctx add _blint_check_gobash_constants
        $checks $ctx add _blint_check_signature

        #$checks add _blint_check_end_of_line_spaces
        #$checks add _blint_check_if_then
        #$checks add _blint_check_spaces_between_words

        local -r btime=$(time_now_millis $ctx)
        local path=$($args $ctx paths)
        if [ -f "${path}" ]; then
                _blint_check_file $ctx "${res}" "${path}" "${checks}"
        elif [ -d "${path}" ]; then
                _blint_check_dir $ctx "${res}" "${path}" "${checks}"
        else
                echo "Could not find path: ${path}"
        fi
        local -r etime=$(time_now_millis $ctx)

        local -r duration=$(( ${etime} - ${btime} ))
        ! $res $ctx has_failing
}

if [[ "${0}" = *"blint.sh" ]]; then
        blint_main "$@" || exit $?
fi
