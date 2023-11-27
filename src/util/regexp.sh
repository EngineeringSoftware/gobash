#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Util for regular expression.
#
# bash uses Extended Regular Expressions
# (https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html#tag_09_04).

if [ -n "${REGEXP_MOD:-}" ]; then return 0; fi
readonly REGEXP_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${REGEXP_MOD}/../lang/p.sh
. ${REGEXP_MOD}/list.sh


# ----------
# Functions.

function RegExp() {
        # Regular expression.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r re="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "re" "${re}"
}

function RegExp_match_string() {
        # Return true if string matches this regexp.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r regexp="${1}"
        local -r str="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        regexp_match_string $ctx "$($regexp $ctx re)" "${str}"
}

function RegExp_find_string() {
        # Return a string of the leftmost match; empty otherwise.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r regexp="${1}"
        local -r str="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local re="$($regexp re)"
        local ec=0
        [[ "${str}" =~ ${re} ]] || \
                { ec=$?; [ ${ec} -eq 2 ] && { ctx_w $ctx 'incorrect re'; return $EC; }; }

        echo "${BASH_REMATCH}"
        # Should be true or false.
        return ${ec}
}

function RegExp_find_string_index() {
        # Return list with two elements (start and end loc of string).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r regexp="${1}"
        local -r str="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local match
        local ec=0
        match=$(RegExp_find_string $ctx "$regexp" "${str}") || \
                { ec=$?; [ ${ec} -gt 1 ] && { ctx_w $ctx "re error"; return ${ec}; }; }

        is_false ${ec} && echo "${NULL}" && return $FALSE

        local rest=${str#*${match}}
        local start=$(( ${#str} - ${#rest} - ${#match} ))
        local lst=$(List $ctx "${start}" "${#match}")
        echo "${lst}"
}

function RegExp_to_string() {
        # Original regular expression string.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r regexp="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        echo "$($regexp re)"
}

function RegExp_find_string_submatch() {
        # Match and group matches.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r regexp="${1}"
        local -r str="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local re="$($regexp re)"
        local ec=0
        [[ "${str}" =~ ${re} ]] || \
                { ec=$?; [ ${ec} -eq 2 ] && { ctx_w $ctx 'incorrect re'; return $EC; }; }

        [ ${ec} -eq 1 ] && echo "${NULL}" && return 0

        local lst=$(List $ctx)
        local -i i
        for (( i=0; i<${#BASH_REMATCH[@]}; i++ )); do
                $lst $ctx add "${BASH_REMATCH[${i}]}"
        done

        echo "${lst}"
        return 0
}

function regexp_match_string() {
        # Return true if string contains any match for re.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r re="${1}"
        local -r str="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local ec=0
        [[ "${str}" =~ ${re} ]] || \
                { ec=$?; [ ${ec} -eq 2 ] && { ctx_w $ctx 'incorrect re'; return $EC; }; }

        # Should be true or false.
        return ${ec}
}

function regexp_compile() {
        # Save regular expression.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r re="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # Check if correct re.
        local ec=0
        [[ "" =~ ${re} ]] || \
                { ec=$?; [ ${ec} -eq 2 ] && { ctx_w $ctx 'incorrect re'; return $EC; }; }

        RegExp $ctx "${re}"
}
