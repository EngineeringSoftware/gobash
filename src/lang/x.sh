#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# gobash dependencies.

if [ -n "${X_MOD:-}" ]; then return 0; fi
readonly X_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# echo - built-in
# printf - built-in

readonly X_PS="ps"
readonly X_GREP="grep"
readonly X_AWK="awk"
readonly X_BASH=$("$X_PS" aux | "$X_GREP" "$$" | "$X_GREP" 'bash' | "$X_AWK" '{ print $11 }')
readonly X_SED="sed"
readonly X_JQ="jq"
readonly X_CUT="cut"
readonly X_MD5=$(which md5 || which md5sum)
readonly X_SLEEP="sleep"

readonly X_DATE="date"
readonly X_CAT="cat"
readonly X_TAIL="tail"
readonly X_HEAD="head"
readonly X_MKTEMP="mktemp"
readonly X_WC="wc"
readonly X_CALLER="caller"
readonly X_PGREP="pgrep"
readonly X_XARGS="xargs"
readonly X_DOXYGEN="doxygen"


# ----------
# Functions.

function _x_check() {
        # Chck if the given command exists.
        local cmd="${1}"

        command -v "${cmd}" > /dev/null 2>&1 || \
                { echo "missing '${cmd}'"; return 1; }
}

function x_enabled() {
        # Check if this module is enabled (which is the case if all
        # dependencies are available).

        [ -z "${BASH}" ] && \
                { echo "this library only supports bash"; return 1; }

        command > /dev/null 2>&1 || \
                { echo "missing 'command'"; return 1; }

        _x_check "${X_PS}" || return 1
        _x_check "${X_GREP}" || return 1
        _x_check "${X_AWK}" || return 1
        _x_check "${X_BASH}" || return 1
        _x_check "${X_SED}" || return 1
        _x_check "${X_JQ}" || return 1
        _x_check "${X_CUT}" || return 1
        _x_check "${X_MD5}" || return 1
}

function x_bash_version() {
        # Print bash version.

        # Could/should use PIPESTATUS in version functions.

        "${X_BASH}" --version 2>&1 | head -n 1 || \
                "no version for ${X_BASH}"
}

function x_ps_version() {
        # Print ps version.

        "${X_PS}" --version 2>&1 | head -n 1 || \
                "no version for ${X_PS}"
}

function x_grep_version() {
        # Print grep version.

        "${X_GREP}" --version 2>&1 | head -n 1 || \
                "no version for ${X_GREP}"
}

function x_awk_version() {
        # Print awk version.

        "${X_AWK}" -W version 2>&1 | head -n 1 || \
                "no version for ${X_AWK}"
}

function x_sed_version() {
        # Print sed version.

        "${X_SED}" --version 2>&1 | head -n 1 || \
                "no version for ${X_SED}"
}

function x_jq_version() {
        # Print jq version.

        "${X_JQ}" --version 2>&1 | head -n 1 || \
                "no version for ${X_JQ}"
}

function x_cut_version() {
        # Print cut version.

        "${X_CUT}" --version 2>&1 | head -n 1 || \
                "no version for ${X_CUT}"
}

function x_config() {
        # Print system configuration.

        x_bash_version
        x_ps_version
        x_grep_version
        x_awk_version
        x_sed_version
        x_jq_version
        x_cut_version
}
