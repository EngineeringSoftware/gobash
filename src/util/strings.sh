#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Util string functions.

if [ -n "${STRINGS_MOD:-}" ]; then return 0; fi
readonly STRINGS_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${STRINGS_MOD}/../lang/p.sh


# ----------
# Functions.

function strings_len() {
        # Length of the given string.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        echo "${#str}"
}

function strings_count() {
        # Number of substrings in the given string.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        local -r subs="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${str}" ] && { ctx_wa $ctx "str"; return $EC; }
        [ -z "${subs}" ] && { ctx_wa $ctx "subs"; return $EC; }

        echo "${str}" | grep -o "${subs}" | $X_WC -l | $X_SED 's/^[[:space:]]*//'
}

function strings_repeat() {
        # Creat a string by repeating c char n times.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r c="${1}"
        local -r -i n="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${c}" ] && { ctx_wa $ctx "c"; return $EC; }
        [ -z "${n}" ] && { ctx_wa $ctx "n"; return $EC; }

        is_int "${n}" || { ctx_wa $ctx "n"; return $EC; }
        is_gt "${n}" 0 || { ctx_wa $ctx "n"; return $EC; }

        printf "${c}%.0s" $(seq 1 "${n}")
        printf "\n"
}

function strings_has() {
        # Return true if the str has the given substring.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        local -r subs="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        [[ "${str}" = *"${subs}"* ]]
}

function strings_has_prefix() {
        # Return true if str starts with prefix.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        local -r prefix="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${str}" ] && { ctx_wa $ctx "str"; return $EC; }
        [ -z "${prefix}" ] && { ctx_wa $ctx "prefix"; return $EC; }

        [[ "${str}" = "${prefix}"* ]]
}

function strings_has_suffix() {
        # Return true if str has suffix.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        local -r suffix="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${str}" ] && { ctx_wa $ctx "str"; return $EC; }
        [ -z "${suffix}" ] && { ctx_wa $ctx "suffix"; return $EC; }

        [[ "${str}" = *"${suffix}" ]]
}

function strings_remove_prefix() {
        # Return a string by removing prefix from str.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        local -r prefix="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${str}" ] && { ctx_wa $ctx "str"; return $EC; }
        [ -z "${prefix}" ] && { ctx_wa $ctx "prefix"; return $EC; }

        local news="${str#${prefix}}"
        echo "${news}"
}

function strings_sub() {
        # Return a substring between given indexes.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        local -r start="${2}"
        local -r len="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "${str}" ] && { ctx_wa $ctx "str"; return $EC; }
        [ -z "${start}" ] && { ctx_wa $ctx "start"; return $EC; }
        [ -z "${len}" ] && { ctx_wa $ctx "len"; return $EC; }

        echo "${str:${start}:${len}}"
}

function strings_remove_at() {
        # Return the given string without chart at the given index.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        local -r ix="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${str}" ] && { ctx_wa $ctx "str"; return $EC; }
        [ -z "${ix}" ] && { ctx_wa $ctx "ix"; return $EC; }
        [ ${ix} -lt 0 ] && { ctx_wa $ctx "ix"; return $EC; }
        [ ${ix} -ge "${#str}" ] && { ctx_wa $ctx "ix"; return $EC; }

        echo "${str:0:${ix}}${str:$(( ${ix} + 1 )):${#str}}"
}

function strings_cap() {
        # Captilize the given string.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        echo $(echo "${str:0:1}" | tr '[:lower:]' '[:upper:]')"${str:1}"
}
export -f strings_cap

function strings_pcap() {
        # Capitlize the given string (can be used in pipes).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local val
        read val

        strings_cap $ctx "${val}"
}
export -f strings_pcap

function strings_rev() {
        # Reverse the given string.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        echo "${str}" | rev
}

function strings_remove_spaces() {
        # Remove all spaces from the given string.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        echo "${str}" | $X_SED 's/ //g'
}

function strings_remove_char() {
        # Remove c from the string.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        local -r c="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        echo "${str}" | $X_SED 's/'"${c}"'//g'
}

function strings_lstrip() {
        # Return string without leading white chars.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        echo "${str}" | $X_SED 's/^[[:space:]]*//'
}

function strings_rstrip() {
        # Return string without trailing white chars.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        echo "${str}" | $X_SED 's/[[:space:]]*$//'
}

function strings_strip() {
        # Return string without leading and trailing white chars.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        echo "${str}" | $X_SED -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

function strings_single_space() {
        # Return string where multiple spaces are merged into one.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        echo "${str}" | $X_SED -E 's/[[:space:]][[:space:]]+/ /g'
}

function strings_escape_slash() {
        # Return string with escaped slash chars.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        str=${str//\//\\\/}
        echo "${str}"
}

function strings_to_lower() {
        # Return copy of the given string with all lower case letters.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        echo "${str}" | tr [:upper:] [:lower:]
}

function strings_to_upper() {
        # Return copy of the given string with all upper case letters.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        echo "${str}" | tr [:lower:] [:upper:]
}

function strings_swap_case() {
        # Return copy of the given string and swap case letters.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        echo "${str}" | tr "A-Za-z" "a-zA-Z"
}

function strings_index_of() {
        # Return index of the first sep instance or -1 if not present.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local str="${1}"
        local sep="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # No argument check needed.

        local ix
        # No expr on Mac.
        # ix=$(expr index "${str}" "${sep}")
        local rest=${str#*${sep}}
        ix=$(( ${#str} - ${#rest} - ${#sep} ))
        if [ ${ix} -lt 0 ]; then
                echo -1
        else
                echo "${ix}"
        fi
}

function strings_join() {
        # Join strings using the given separator.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -le 1 ] && { ctx_wn $ctx; return $EC; }
        local -r IFS="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        echo "$*"
}
