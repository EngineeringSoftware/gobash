#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# User info access.

if [ -n "${USER_MOD:-}" ]; then return 0; fi
readonly USER_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${USER_MOD}/../lang/p.sh


# ----------
# Functions.

function UserGroup() {
        # Group struct.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "name" "${NULL}" \
              "gid" "${NULL}"
}

function user_group_lookup() {
        # Find group by name.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r name="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local info
        # No getent on Mac.
        # info=$(getent group "${name}") || \
                #         { ctx_w $ctx "no such group"; return $EC; }
        info=$($X_GREP "^${name}:" "/etc/group") || \
                { ctx_w $ctx "no such group"; return $EC; }

        local g
        g=$(UserGroup $ctx) || \
                { ctx_w $ctx "could not make UserGroup"; return $EC; }

        $g $ctx name "$(echo ${info} | $X_CUT -f1 -d':')" || \
                { ctx_w $ctx "cannot set name"; return $EC; }

        $g $ctx gid "$(echo ${info} | $X_CUT -f3 -d':')" || \
                { ctx_w $ctx "cannot set gid"; return $EC; }

        echo "${g}"
}

function user_group_lookup_id() {
        # Find group by gid.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r gid="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # No arguments to check here (see invoked function).

        local name=$($X_GREP ":${gid}:" "/etc/group" | awk -F: '{print $1}')
        user_group_lookup $ctx "${name}"
}

function User() {
        # User struct.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "username" "${NULL}" \
              "home" "${NULL}" \
              "uid" "${NULL}" \
              "gid" "${NULL}"
}

function User_group_ids() {
        # Return (list, 0) of group ids for this user. If error,
        # return (_, $EC).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r u="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r username=$($u $ctx username)
        local lst
        lst=$(List $ctx $(id -G "${username}")) || \
                { ctx_w $ctx "could not make a List"; return $EC; }

        echo "${lst}"
}

function user_lookup() {
        # Get user info for the given username.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r username="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        id "${username}" 2>&1 > /dev/null || \
                { ctx_w $ctx "no such user"; return $EC; }
        ! is_file "/etc/passwd" && \
                { ctx_w $ctx "there is no /etc/passwd"; return $EC; }

        local u
        u=$(User $ctx) || \
                { ctx_w $ctx "cannot make a user"; return $EC; }

        $u $ctx username "${username}" || \
                { ctx_w $ctx "cannot set username"; return $EC; }

        local home
        home=$(cat "/etc/passwd" | grep "^${username}:" | $X_CUT -f6 -d':') || \
                { ctx_w $ctx "cannot get home"; return $EC; }

        $u $ctx home "${home}" || \
                { ctx_w $ctx "cannot set home to ${home}"; return $EC; }

        $u $ctx uid "$(id -u ${username})" || \
                { ctx_w $ctx "cannot set uid"; return $EC; }

        $u $ctx gid "$(id -g ${username})" || \
                { ctx_w $ctx "cannot set gid"; return $EC; }

        echo "${u}"
}

function user_lookup_id() {
        # Get user info for the given uid.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r uid="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        id -nu "${uid}" 2>&1 > /dev/null || \
                { ctx_w $ctx "no such id"; return $EC; }

        local -r username=$(id -nu "${uid}")
        user_lookup $ctx "${username}"
}

function user_current() {
        # Get info for the current user.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # No arguments to check.

        user_lookup $ctx "$(whoami)"
}
