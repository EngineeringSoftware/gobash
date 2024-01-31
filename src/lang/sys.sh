#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Util functions closer to the system.

if [ -n "${SYS_MOD:-}" ]; then return 0; fi
readonly SYS_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${SYS_MOD}/core.sh

readonly SYS_NAME="gobash"
readonly SYS_MAJOR="1"
readonly SYS_MINOR="0"
readonly SYS_PATCH="1"
readonly SYS_SUFFIX="-dev"


# ----------
# Functions.

function sys_version() {
        # Return gobash version.
        # 
        # :return: gobash version.
        # :rtype: string
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        echo "${SYS_MAJOR}.${SYS_MINOR}.${SYS_PATCH}${SYS_SUFFIX}"
}

function sys_repo_path() {
        # Root dir for this repo.
        # 
        # :return: root directory for this repository.
        # :rtype: string
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        echo "${SYS_MOD}/../.."
}

function sys_stack_trace() {
        # Print stack trace.
        # 
        # :return: stack trace.
        # :rtype: strings
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local -i i=0
        while :; do
                caller ${i} || break
                i=$(( ${i} + 1 ))
        done

        return 0
}

function sys_is_on_stack() {
        # Check if the function name is on stack.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r name="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        sys_stack_trace $ctx | grep "${name}"
}

function sys_bash_files() {
        # List all files in this library that start with #!/bin/bash.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local f
        for f in $(find "$(sys_repo_path)" -name "*" -type f | grep -v '.git'); do
                if head -n 1 "${f}" | grep '^#!/bin/bash' > /dev/null; then
                        echo "${f}"
                fi
        done | sort -u
}

function sys_functions() {
        # List all functions in this library (excluding test files).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        for f in $(find "${SYS_MOD}/.." -name "*.sh" | grep -v '_test.sh'); do
                grep '^function ' "${f}" | $X_SED 's/function \(.*\)().*/\1/g'
        done | sort
}

function sys_functions_in_file() {
        # List all functions in the given file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r pathf="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        ! is_file $ctx "${pathf}" && { ctx_w $ctx "no path"; return $EC; }

        grep '^function ' "${pathf}" | $X_SED 's/function \(.*\)().*/\1/g' | sort
}

function sys_function_doc_lines() {
        # Compute number of doc lines for the given function.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r pathf="${1}"
        local -r func="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        ! is_file "${pathf}" && { ctx_w $ctx "no path"; return $EC; }

        local nl=1
        while :; do
                grep -A ${nl} "^function ${func}()" "${pathf}" | \
                        tail -n 1 | \
                        grep '^[[:space:]]*#' > /dev/null || break
                nl=$(( ${nl} + 1 ))
        done
        nl=$(( ${nl} - 1 ))

        echo "${nl}"
}

function sys_function_doc() {
        # Extract documentation for the given function.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r pathf="${1}"
        local -r func="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        ! is_file "${pathf}" && return $EC

        local nl
        nl=$(sys_function_doc_lines $ctx "${pathf}" "${func}") || \
                { ctx_w $ctx "no doc lines"; return $EC; }

        grep -A ${nl} "^function ${func}()" "${pathf}" | \
                tail -n +2 | \
                $X_SED 's/[[:space:]]*# \(.*\)/\1/g'
}

function sys_line_num() {
        # Return line number from which this func was called.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        caller | $X_CUT -f1 -d' '
}

function sys_line_prev() {
        # Return content of the line before the one from which this
        # function is invoked.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local f=$(caller | $X_CUT -f2 -d' ')
        local l=$(caller | $X_CUT -f1 -d' ')
        l=$(( ${l} - 1 ))

        $X_SED "${l}!d" "${f}"
}

function sys_line_next() {
        # Return content of the line after the one from which this
        # function is invoked.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local f=$(caller | $X_CUT -f2 -d' ')
        local l=$(caller | $X_CUT -f1 -d' ')
        l=$(( ${l} + 1 ))

        $X_SED "${l}!d" "${f}"
}

function sys_has_connection() {
        # Return 0 if there is connection to the web; 1 otherwise.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        wget --quiet --spider http://google.com
}

function sys_gc() {
        # Clean things allocated by this library instance.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        unsafe_gc
}
