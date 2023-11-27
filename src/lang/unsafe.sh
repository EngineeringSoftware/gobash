#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Low level object manipulation.

if [ -n "${UNSAFE_MOD:-}" ]; then return 0; fi
readonly UNSAFE_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${UNSAFE_MOD}/core.sh
. ${UNSAFE_MOD}/os.sh
. ${UNSAFE_MOD}/jqmem.sh

readonly __store="$(core_obj_dir)"
mkdir -p "${__store}"
# mkdir /dev/shm/gobash
# ln -s /dev/shm/gobash ${__store}


# ----------
# Functions.

function _unsafe_type() {
        # Return (object type, 0). If error, return (, $EC).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r uid=$(_unsafe_object_uid $ctx "${obj}")
        echo "${uid%@*}"
}

function _unsafe_object_uid() {
        # Get object (uid, 0).  If there is an error, return (, $EC).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        echo "${obj#_make_access }"
}

function _unsafe_object_file() {
        # File for the object with the given uid.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r uid="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        echo "${__store}/${uid}.json"
}

function unsafe_is_instanceof() {
        # Return true if object is instance of the given type.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        local -r type="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -r actual=$(_unsafe_type $ctx "${obj}")
        [ "${actual}" = "${type}" ]
}

function unsafe_is_object() {
        # Return true if it is a valid object.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${obj}" ] && return $FALSE

        [[ "${obj}" != _make_access* ]] && return $FALSE

        local -r uid=$(_unsafe_object_uid $ctx "${obj}")
        local -r objf=$(_unsafe_object_file $ctx "${uid}")
        [ ! -f "${objf}" ] && return $FALSE

        return $TRUE
}

function unsafe_object_make() {
        # Return new object (uid, 0). If error, return (_, $EC).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r type="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local f
        f=$(os_mktemp $ctx "${__store}" "${type}@XXXX" ".json") || \
                { ctx_w $ctx "cannot alloc object"; return $EC; }
        
        echo "{}" > "${f}"
        basename "${f}" ".json"
}

function unsafe_flds() {
        # Return a list of fields of the given object.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r uid=$(_unsafe_object_uid $ctx "${obj}")
        local -r objf=$(_unsafe_object_file $ctx "${uid}")
        jq '.' "${objf}" | jq 'keys_unsorted'
}

function unsafe_keys() {
        # Return a list of keys in the same order as in the map.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local kid
        kid=$(unsafe_object_make $ctx "List")

        local keysf
        keysf=$(_unsafe_object_file $ctx "${kid}")

        unsafe_flds $ctx "${obj}" > "${keysf}" || \
                { ctx_w $ctx "cannot get keys"; return $EC; }

        echo "_make_access ${kid}"
}

function unsafe_has_fld() {
        # Return true if the given object/uid has the given field.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        local -r fld="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # It is either object or uid.
        local uid="${obj}"
        if unsafe_is_object $ctx "${obj}"; then
                uid=$(_unsafe_object_uid $ctx "${obj}")
        fi

        local -r objf=$(_unsafe_object_file $ctx "${uid}")
        json_has $ctx "${objf}" "${fld}"
}

function unsafe_set_fld() {
        # Set a field for object/uid.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        local -r fld="${2}"
        local -r val="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        # It is either object or uid.
        local uid="${obj}"
        if unsafe_is_object $ctx "${obj}"; then
                uid=$(_unsafe_object_uid $ctx "${obj}")
        fi

        local -r objf=$(_unsafe_object_file $ctx "${uid}")
        json_set $ctx "${objf}" "${fld}" "${val}"
}

function unsafe_get_fld() {
        # Get a field for object/uid.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        local -r fld="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        ! unsafe_has_fld $ctx "${obj}" "${fld}" && \
                { echo "${NULL}"; return $FALSE; }

        # It is either object or uid.
        local uid="${obj}"
        if unsafe_is_object $ctx "${obj}"; then
                uid=$(_unsafe_object_uid $ctx "${obj}")
        fi

        local -r objf=$(_unsafe_object_file $ctx "${uid}")
        json_get $ctx "${objf}" "${fld}"
}

function unsafe_list_make() {
        # Make a list and return (uid, 0). If error, return (_, $EC).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local uid
        uid=$(unsafe_object_make $ctx "List")

        local objf
        objf=$(_unsafe_object_file $ctx "${uid}")
        echo "[]" > "${objf}"

        echo "_make_access ${uid}"
}

function unsafe_list_clear() {
        # Clean a list and return (_, 0). If error, return (_, $EC).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local uid
        uid=$(_unsafe_object_uid $ctx "${lst}")

        local objf
        objf=$(_unsafe_object_file $ctx "${uid}")
        echo "[]" > "${objf}"
}

function unsafe_list_add() {
        # Add an element into a list and return (_, 0). If error,
        # return (_, $EC).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local val="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        #val=$(echo "${val}" | jq -R)
        val="\"${val//\"/\\\"}\""

        local -r uid=$(_unsafe_object_uid $ctx "${lst}")
        local -r objf=$(_unsafe_object_file $ctx "${uid}")

        local -r tmpf=$(os_mktemp $ctx "$(core_tmp_dir)" "tmp.XXXX" ".json")
        cat "${objf}" | \
                jq --argjson val "${val}" '. += [$val]' > "${tmpf}" || \
                { ctx_w $ctx "cannot add val into list"; return $EC; }
        mv "${tmpf}" "${objf}"
}

function unsafe_list_get() {
        # Get an element from a list (val, 0). If error, return (_,
        # $EC).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local ix="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${lst}" ] && { ctx_w $ctx "no lst"; return $EC; }
        [ -z "${ix}" ] && { ctx_w $ctx "no ix"; return $EC; }
        [ ${ix} -lt 0 ] && { ctx_w $ctx "ix below zero"; return $EC; }
        [ ${ix} -ge $(List_len "${lst}") ] && \
                { ctx_w $ctx "ix bigger than len"; return $EC; }

        local -r uid=$(_unsafe_object_uid $ctx "${lst}")
        local -r objf=$(_unsafe_object_file $ctx "${uid}")

        jq -r '.['"${ix}"']' "${objf}" || \
                { ctx_w $ctx "cannot get list el"; return $EC; }
}

function unsafe_list_delete() {
        # Delete an element and return (_, 0). If element not present,
        # return (_, 1). If error, return (_, $EC).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local -r ix="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${lst}" ] && { ctx_w $ctx "no lst"; return $EC; }
        [ -z "${ix}" ] && { ctx_w $ctx "no ix"; return $EC; }
        [ ${ix} -lt 0 ] && { ctx_w $ctx "ix below zero"; return $EC; }
        [ ${ix} -gt $(List_len $ctx "${lst}") ] && \
                { ctx_w $ctx "ix greater than len"; return $EC; }

        local -r uid=$(_unsafe_object_uid $ctx "${lst}")
        local -r objf=$(_unsafe_object_file $ctx "${uid}")

        local tmpf=$(os_mktemp_file $ctx)
        jq -r 'del(.['"${ix}"'])' "${objf}" > "${tmpf}" || \
                { ctx_w $ctx "cannot delete an el"; return $EC; }

        # If files are the same.
        diff "${objf}" "${tmpf}" > /dev/null && return $FALSE

        mv "${tmpf}" "${objf}"
        return $TRUE
}

function unsafe_list_eq() {
        # Return (_, 0) if two lists are the same (comparing elements
        # as references). Return (_, 1) if they are diff. Return (_,
        # $EC) if there is an error.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local -r other="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ "${lst}" = "${other}" ] && return $TRUE

        local -r obj_id=$(_unsafe_object_uid $ctx "${lst}")
        local -r objf=$(_unsafe_object_file $ctx "${obj_id}")

        local -r other_id=$(_unsafe_object_uid $ctx "${other}")
        local -r otherf=$(_unsafe_object_file $ctx "${other_id}")

        local ec=0
        diff <(jq '.[]' "${objf}" | sort) <(jq '.[]' "${otherf}" | sort) > /dev/null || \
                { ec=$?; [ ${ec} -eq 2 ] && { ctx_w $ctx "diff trouble"; return $EC; }; }

        return ${ec}
}

function unsafe_len() {
        # Get (length, 0) of the underlying object/uid. If error,
        # return (_, $EC).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # It is either object or uid.
        local uid="${obj}"
        if unsafe_is_object $ctx "${obj}"; then
                uid=$(_unsafe_object_uid $ctx "${obj}")
        fi

        local -r objf=$(_unsafe_object_file $ctx "${uid}")
        jq 'length' "${objf}" || \
                { ctx_w $ctx "cannot get len"; return $EC; }
}

function unsafe_copy() {
        # Copy content of src to dst without changing dst name.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r dst="${1}"
        local -r src="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -r dstid=$(_unsafe_object_uid $ctx "${dst}")
        local -r dstf=$(_unsafe_object_file $ctx "${dstid}")

        local -r srcid=$(_unsafe_object_uid $ctx "${src}")
        local -r srcf=$(_unsafe_object_file $ctx "${srcid}")

        cp "${srcf}" "${dstf}"
}

# @deprecated(needs to be revised)
function unsafe_from_json() {
        # Create an object from a json file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r type="${1}"
        local -r f="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${type}" ] && { ctx_w $ctx "no type"; return $EC; }
        [ -z "${f}" ] && { ctx_w $ctx "no f"; return $EC; }

        local next=$(_next)
        local obj="${type}@${next}"
        cp "${f}" "${__store}/${obj}.json"

        echo "_make_access ${obj}"
}

function unsafe_clone() {
        # Shallow clone.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${obj}" ] && return $EC

        local -r type=$(_unsafe_type $ctx "${obj}")
        local -r cid=$(unsafe_object_make $ctx "${type}")
        local -r clonef=$(_unsafe_object_file $ctx "${cid}")

        local -r uid=$(_unsafe_object_uid $ctx "${obj}")
        local -r objf=$(_unsafe_object_file $ctx "${uid}")

        cp "${objf}" "${clonef}"

        echo "_make_access ${cid}"
}

function unsafe_zero() {
        # Zero value for the given type.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r type="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        case "${type}" in
        $BOOL) echo "$FALSE"; return 0;;
        $INT) echo 0; return 0;;
        $FLOAT) echo 0.0; return 0;;
        $STRING) echo ""; return 0;;
        *) { ctx_w $ctx "no such type"; return $EC; };;
        esac
}

function unsafe_to_json() {
        # Output json representation of the object.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r uid="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${uid}" ] && { ctx_w $ctx "incorrect id"; return $EC; }

        local -r objf=$(_unsafe_object_file $ctx "${uid}")
        [ ! -f "${objf}" ] && { ctx_w $ctx "no objf"; return $EC; }

        cat "${objf}"
}

function unsafe_to_string() {
        # Output string representation of the object.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r uid="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        unsafe_to_json $ctx "${uid}"
}

function unsafe_gc() {
        # Clean. Should be used carefully.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        rm -rf "${__store}" || \
                { ctx_w $ctx "cannot gc"; return $EC; }

        mkdir -p "${__store}" || \
                { ctx_w $ctx "cannot gc"; return $EC; }
}
