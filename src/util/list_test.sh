#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the list module.

if [ -n "${LIST_TEST_MOD:-}" ]; then return 0; fi
readonly LIST_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${LIST_TEST_MOD}/list.sh
. ${LIST_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_list() {
        local lst
        lst=$(List) || \
                assert_fail
}
readonly -f test_list

function test_list_len() {
        local lst
        lst=$(List) || \
                assert_fail

        local len
        len=$($lst len) || \
                assert_fail
        assert_eq 0 "${len}"
}
readonly -f test_list_len

function test_list_add() {
        local lst
        lst=$(List) || \
                assert_fail

        $lst add 5 || \
                assert_fail
        $lst add 77 || \
                assert_fail

        local len
        len=$($lst len) || \
                assert_fail
        assert_eq 2 "${len}"
}
readonly -f test_list_add

function test_list_add_str() {
        local lst
        lst=$(List) || \
                assert_fail

        $lst add "abc" || \
                assert_fail
        $lst add "def" || \
                assert_fail

        local len
        len=$($lst len) || \
                assert_fail
        assert_eq 2 "${len}"
}
readonly -f test_list_add_str

function test_list_get() {
        local lst
        lst=$(List) || \
                assert_fail

        $lst add 77 || \
                assert_fail
        $lst add 5 || \
                assert_fail

        local el

        el=$($lst get 0) || \
                assert_fail
        assert_eq 77 "${el}"

        el=$($lst get 1) || \
                assert_fail
        assert_eq 5 "${el}"

        local ec=0
        el=$($lst get 2) || ec=$?
        assert_ec ${ec}
}
readonly -f test_list_get

function test_list_delete() {
        local lst
        lst=$(List) || \
                assert_fail

        $lst add 77 || \
                assert_fail
        $lst add 5 || \
                assert_fail
        $lst add 10 || \
                assert_fail

        $lst delete 1 || \
                assert_fail
        assert_eq 2 "$($lst len)"

        $lst contains 77 || \
                assert_fail

        $lst contains 10 || \
                assert_fail

        $lst delete 500 && \
                assert_fail

        return 0
}
readonly -f test_list_delete

function test_list_sum() {
        local lst
        lst=$(List) || \
                assert_fail

        $lst add 5 || \
                assert_fail
        $lst add 10 || \
                assert_fail

        local sum
        sum=$($lst sum) || \
                assert_fail
        assert_eq 15 "${sum}"
}
readonly -f test_list_sum

function test_list_min() {
        local lst
        lst=$(List) || \
                assert_fail

        $lst add 5
        $lst add 10
        $lst add 1
        $lst add 33

        local min
        min=$($lst min) || \
                assert_fail
        assert_eq 1 "${min}"
}
readonly -f test_list_min

function test_list_min_empty_list() {
        local lst
        lst=$(List) || \
                assert_fail

        $lst min && \
                assert_fail

        return 0
}
readonly -f test_list_min_empty_list

function test_list_is_empty() {
        local lst
        lst=$(List) || \
                assert_fail

        $lst is_empty || \
                assert_fail

        $lst add 5 || \
                assert_fail

        local ec=0
        $lst is_empty || ec=$?
        assert_false ${ec}
}
readonly -f test_list_is_empty

function test_list_contains() {
        local lst
        lst=$(List) || \
                assert_fail

        $lst add 5
        $lst add 10

        $lst contains 5 || \
                assert_fail

        $lst contains 10 || \
                assert_fail

        local ec=0
        $lst contains 11 || ec=$?
        assert_false ${ec}
}
readonly -f test_list_contains

function test_list_clear() {
        local lst
        lst=$(List) || \
                assert_fail

        $lst add 5
        $lst add 10

        local len
        len=$($lst len) || \
                assert_fail
        assert_eq 2 "${len}"

        $lst clear || \
                assert_fail
        len=$($lst len) || \
                assert_fail
        assert_eq 0 "${len}"
}
readonly -f test_list_clear

function test_list_eq() {
        local lst1=$(List)
        local lst2=$(List)
        local lst3=$(List)

        # Make lists.

        $lst1 add "one"
        $lst1 add "two"

        $lst2 add "two"
        $lst2 add "one"

        $lst3 add "three"

        # Check.

        $lst1 eq "${lst2}" || \
                assert_fail

        $lst2 eq "${lst1}" || \
                assert_fail

        $lst1 eq "${lst1}" || \
                assert_fail

        $lst2 eq "${lst2}" || \
                assert_fail

        $lst1 eq "${lst3}" && \
                assert_fail

        $lst2 eq "${lst3}" && \
                assert_fail

        return 0
}
readonly -f test_list_eq

function test_list_filter() {
        local lst=$(List)

        $lst add 1
        $lst add 11
        $lst add 30

        function lt10() {
                local el="${1}"
                [ ${el} -lt 10 ]
        }

        local nlst
        nlst=$($lst filter lt10) || \
                assert_fail

        assert_eq 1 "$($nlst len)"

        $nlst contains 1 || \
                assert_fail
}
readonly -f test_list_filter

function test_list_map() {
        local lst=$(List)

        $lst add 10
        $lst add 20
        $lst add 40

        function x2() {
                local el="${1}"
                echo "${el} * 2" | bc
        }

        local nlst
        nlst=$($lst map "x2") || \
                assert_fail
        assert_eq $($nlst len) 3

        $nlst contains 20 || \
                assert_fail
        $nlst contains 40 || \
                assert_fail
        $nlst contains 80 || \
                assert_fail
}
readonly -f test_list_map

function test_list_reduce() {
        local lst=$(List)

        $lst add 10
        $lst add 20
        $lst add 40

        function sum() {
                local t="${1}"
                local u="${2}"

                echo "${t} + ${u}" | bc
        }

        local res
        res=$($lst reduce 0 sum) || \
                assert_fail
        assert_eq 70 "${res}"
}
readonly -f test_list_reduce

function test_list_any_match() {
        local lst=$(List)

        $lst add 10
        $lst add 20
        $lst add 100

        function gt20() {
                [ "${1}" -gt 20 ]
        }
        $lst any_match "gt20" || \
                assert_fail

        function gt100() {
                [ "${1}" -gt 100 ]
        }
        $lst any_match "gt100" && \
                assert_fail

        return 0
}
readonly -f test_list_any_match

function test_list_all_match() {
        local lst=$(List)

        $lst add 10
        $lst add 20
        $lst add 100

        function gt9() {
                [ "${1}" -gt 9 ]
        }
        $lst all_match "gt9" || \
                assert_fail

        function gt20() {
                [ "${1}" -gt 20 ]
        }
        $lst all_match "gt20" && \
                assert_fail

        return 0
}
readonly -f test_list_all_match

function test_list_make() {
        local lst

        lst=$(List 1 2 3) || \
                assert_fail
        assert_eq 3 "$($lst len)"

        $lst clear || \
                assert_fail
        assert_eq 0 "$($lst len)"

        lst=$(List "a b c" "d") || \
                assert_fail
        assert_eq 2 "$($lst len)"

        $lst clear || \
                assert_fail

        local x=$(amake_ "x" 3)
        local y=$(amake_ "x" 3)
        lst=$(List "$x" "$y") || \
                assert_fail
        assert_eq 2 "$($lst len)"
}
readonly -f test_list_make

function test_list_to_string() {
        local lst=$(List 1 2)
        $lst to_string > /dev/null || \
                assert_fail
}
readonly -f test_list_to_string

function test_list_first() {
        local lst
        local val

        lst=$(List 1 2 3) || \
                assert_fail
        val=$($lst first) || \
                assert_fail
        assert_eq 1 "${val}"

        lst=$(List 3 2 1) || \
                assert_fail
        val=$($lst first) || \
                assert_fail
        assert_eq 3 "${val}"

        lst=$(List) || \
                assert_fail
        val=$($lst first) && \
                assert_fail

        return 0
}
readonly -f test_list_first

function test_list_second() {
        local lst
        local val

        lst=$(List 1 2 3) || \
                assert_fail
        val=$($lst second) || \
                assert_fail
        assert_eq 2 "${val}"

        lst=$(List) || \
                assert_fail
        val=$($lst second) && \
                assert_fail

        return 0
}
readonly -f test_list_second

function test_list_last() {
        local lst
        local val

        lst=$(List 1 2 3) || \
                assert_fail
        val=$($lst last) || \
                assert_fail
        assert_eq 3 "${val}"

        lst=$(List) || \
                assert_fail
        val=$($lst last) && \
                assert_fail

        return 0
}
readonly -f test_list_last

function test_list_ctx() {
        function predx() {
                return 22
        }

        local lst=$(List)
        $lst add 55 || \
                assert_fail

        local ctx=$(ctx_make)
        $lst $ctx filter predx || \
                { ctx_show $ctx | grep 'predicate error' || assert_fail; }
}
readonly -f test_list_ctx
