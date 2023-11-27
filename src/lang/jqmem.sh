#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Util functions to manipulate json files.

if [ -n "${JQMEM_MOD:-}" ]; then return 0; fi
readonly JQMEM_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${JQMEM_MOD}/core.sh
. ${JQMEM_MOD}/os.sh


# ----------
# Functions.

function json_set() {
        # Set a field.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r f="${1}"
        local -r fld="${2}"
        local val="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        [ -z "${f}" ] && { ctx_w $ctx "no f"; return $EC; }
        [ -z "${fld}" ] && { ctx_w $ctx "no fld"; return $EC; }

        local -r tmpf=$(os_mktemp_file $ctx)

        if [ "${val}" != "null" -a \
                      "${val}" != "true" -a \
                      "${val}" != "false" -a \
                      "${val}" != "[]" -a \
                      "${val}" != "{}" ]; then
                # TODO(milos): numbers diff.
                # val=$(echo "${val}" | jq -R)
                val="\"${val//\"/\\\"}\""
        fi

        jq --indent 4 --argjson "${fld}" "${val}" \
           '. += $ARGS.named' "${f}" > "${tmpf}" 2>/dev/null || \
                { ctx_w $ctx "cannot set ${fld} using jq"; return $EC; }

        mv "${tmpf}" "${f}"
}

function json_get() {
        # Get a field.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r f="${1}"
        local -r fld="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        [ -z "${f}" ] && { ctx_w $ctx "no f"; return $EC; }
        [ -z "${fld}" ] && { ctx_w $ctx "no fld"; return $EC; }

        jq -r '. | .'"${fld}"'' "${f}"
}

function json_has() {
        # Return true if it has a field.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r f="${1}"
        local -r fld="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        [ -z "${f}" ] && { ctx_w $ctx "no f"; return $EC; }
        [ -z "${fld}" ] && { ctx_w $ctx "no fld"; return $EC; }

        grep --quiet '^    "'"${fld}"'":' "${f}" > /dev/null 2>&1

        #local res
        #res=$(jq 'has("'"${fld}"'")' "${f}")
        #[ "${res}" = "true" ]
}
