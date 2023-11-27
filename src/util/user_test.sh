#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the user module.

if [ -n "${USER_TEST_MOD:-}" ]; then return 0; fi
readonly USER_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${USER_TEST_MOD}/user.sh
. ${USER_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_user_current() {
        local ec

        local u
        u=$(user_current) || \
                assert_fail "cannot get current user"

        ec=0
        is_null "$($u username)" || ec=$?
        assert_false ${ec}

        ec=0
        is_null "$($u home)" || ec=$?
        assert_false ${ec}

        ec=0
        is_null "$($u uid)" || ec=$?
        assert_false ${ec}

        ec=0
        is_null "$($u gid)" || ec=$?
        assert_false ${ec}
}
readonly -f test_user_current

function test_user_lookup() {
        local u
        local ec

        u=$(user_lookup "$(whoami)") || \
                assert_fail

        ec=0
        is_null "$($u username)" || ec=$?
        assert_false ${ec}

        ec=0
        is_null "$($u home)" || ec=$?
        assert_false ${ec}

        ec=0
        is_null "$($u uid)" || ec=$?
        assert_false ${ec}

        ec=0
        is_null "$($u gid)" || ec=$?
        assert_false ${ec}

        local ctx

        ctx=$(ctx_make)
        ec=0
        u=$(user_lookup $ctx "nobodyhasthisusername") || ec=$?
        assert_ec ${ec}
        ctx_show $ctx | grep 'no such user' || \
                assert_fail
}
readonly -f test_user_lookup

function test_user_lookup_id() {
        local -r username=$(whoami)
        local -r uid=$(id -u "${username}")
        local u
        local ec

        u=$(user_lookup_id "${uid}") || \
                assert_fail

        assert_eq "${username}" "$($u username)"
        assert_eq "${uid}" "$($u uid)"

        ec=0
        is_null "$($u home)" || ec=$?
        assert_false ${ec}

        ec=0
        is_null "$($u gid)" || ec=$?
        assert_false ${ec}

        local ctx

        ctx=$(ctx_make)
        u=$(user_lookup_id $ctx 33553432877777) &&
                assert_fail
        ctx_show $ctx | grep 'no such id' || \
                assert_fail
}
readonly -f test_user_lookup_id

function test_user_group_ids() {
        local -r u=$(user_current)

        local lst
        lst=$($u group_ids) || \
                assert_fail

        local gid
        for gid in $(id -G "$(whoami)"); do
                $lst contains "${gid}" || \
                        assert_fail
        done
}
readonly -f test_user_group_ids

function test_user_group_lookup() {
        local g
        g=$(user_group_lookup "daemon") || \
                assert_fail

        assert_eq "daemon" "$($g name)"
        assert_eq "$($X_GREP "^daemon:" /etc/group | $X_CUT -f3 -d':')" "$($g gid)"

        local ctx

        ctx=$(ctx_make)
        g=$(user_group_lookup $ctx "blahblahblah") && \
                assert_fail
        ctx_show $ctx | grep 'no such group' || \
                assert_fail
}
readonly -f test_user_group_lookup

function test_user_group_lookup_id() {
        local gid=$($X_GREP "^daemon:" "/etc/group" | $X_CUT -f3 -d':')

        local g
        g=$(user_group_lookup_id "${gid}") || \
                assert_fail

        assert_eq "daemon" "$($g name)"
        assert_eq "${gid}" "$($g gid)"

        local ctx

        ctx=$(ctx_make)
        g=$(user_group_lookup_id $ctx "877773999288383") && \
                assert_fail
        ctx_show $ctx | grep 'no such group' || \
                assert_fail
}
readonly -f test_user_group_lookup_id
