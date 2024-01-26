#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the file module.

if [ -n "${FILE_TEST_MOD:-}" ]; then return 0; fi
readonly FILE_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${FILE_TEST_MOD}/file.sh
. ${FILE_TEST_MOD}/os.sh
. ${FILE_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_file_newlines() {
        local tmpf
        tmpf=$(os_mktemp_file) || \
                assert_fail
        echo "something" > "${tmpf}"

        assert_eq 1 $(file_newlines "${tmpf}")
}
readonly -f test_file_newlines

function test_file_append_newline() {
        local tmpf=$(os_mktemp_file)
        echo -n "some text" > "${tmpf}"
        assert_eq 0 $(file_newlines "${tmpf}")

        file_append_newline "${tmpf}" || \
                assert_fail
        assert_eq 1 $(file_newlines "${tmpf}")
}
readonly -f test_file_append_newline

function test_file_at() {
        local tmpf=$(os_mktemp_file)
        echo "one" > "${tmpf}"
        echo "two" >> "${tmpf}"
        echo "three" >> "${tmpf}"

        local res
        res=$(file_at "${tmpf}" 2) || \
                assert_fail
        assert_eq "two" "${res}"

        local ctx

        ctx=$(ctx_make)
        res=$(file_at $ctx "${tmpf}" 0) && \
                assert_fail
        ctx_show $ctx | grep 'ix' || \
                assert_fail

        ctx=$(ctx_make)
        res=$(file_at $ctx "${tmpf}" 100) && \
                assert_fail
        ctx_show $ctx | grep 'ix' || \
                assert_fail

        res=$(file_at "${tmpf}" 3) || \
                assert_fail
        assert_eq "three" "${res}"
}
readonly -f test_file_at

function test_file_insert_at() {
        local tmpf=$(os_mktemp_file)
        echo "something" > "${tmpf}"

        file_insert_at "${tmpf}" 1 "new line" || \
                assert_fail

        grep -n 'new line' "${tmpf}" | grep '1:' > /dev/null || \
                assert_fail

        file_insert_at "${tmpf}" 3 "outside" && \
                assert_fail

        return 0
}
readonly -f test_file_insert_at

function test_file_remove_at() {
        local tmpf=$(os_mktemp_file)
        echo "one" > "${tmpf}"
        echo "two" >> "${tmpf}"

        local ctx

        ctx=$(ctx_make)
        file_remove_at $ctx "${tmpf}" 0 && \
                assert_fail
        ctx_show $ctx | grep 'ix' || \
                assert_fail

        ctx=$(ctx_make)
        file_remove_at $ctx "${tmpf}" 100 && \
                assert_fail
        ctx_show $ctx | grep 'ix' || \
                assert_fail

        file_remove_at "${tmpf}" 1 || \
                assert_fail
        grep 'two' "${tmpf}" > /dev/null || \
                assert_fail

        file_remove_at "${tmpf}" 1 || \
                assert_fail
}
readonly -f test_file_remove_at

function test_file_remove_empty_lines() {
        local tmpf=$(os_mktemp_file)

        cat << END > "${tmpf}"
one

two
    
three
END

        file_remove_empty_lines "${tmpf}" || \
                assert_fail
        assert_eq 3 $(file_newlines "${tmpf}")
}
readonly -f test_file_remove_empty_lines

function test_file_remove_matching_lines() {
        local tmpf=$(os_mktemp_file)

        cat << END > "${tmpf}"
one
two
andone
three
END

        file_remove_matching_lines "${tmpf}" "one*" || \
                assert_fail
        grep 'one' "${tmpf}" > /dev/null && \
                assert_fail

        return 0
}
readonly -f test_file_remove_matching_lines

function test_file_squeeze_blank_lines() {
        local tmpf=$(os_mktemp_file)

        cat << END > "${tmpf}"
one



two


three
   
 
done
END

        file_squeeze_blank_lines "${tmpf}" || \
                assert_fail
        assert_eq 8 $(file_newlines "${tmpf}")

        local ctx

        ctx=$(ctx_make)
        file_squeeze_blank_lines $ctx "randomfilename" && \
                assert_fail
        ctx_show $ctx | grep 'path' || \
                assert_fail
}
readonly -f test_file_squeeze_blank_lines

function test_file_prefix_each_line() {
        local tmpf=$(os_mktemp_file)

        cat << END > "${tmpf}"
one
two

three
END
        file_prefix_each_line "${tmpf}" "abc"

        local n=$(grep '^abc' "${tmpf}" | wc -l)
        [ "${n}" -ne 4 ] && return $EC
        return 0
}
readonly -f test_file_prefix_each_line
