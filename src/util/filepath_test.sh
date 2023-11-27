#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the filepath module.

if [ -n "${FILEPATH_TEST_MOD:-}" ]; then return 0; fi
readonly FILEPATH_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${FILEPATH_TEST_MOD}/filepath.sh
. ${FILEPATH_TEST_MOD}/os.sh
. ${FILEPATH_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_filepath_base() {
        assert_eq "baz.js" $(filepath_base "/foo/bar/baz.js")
        assert_eq "baz" $(filepath_base "/foo/bar/baz")
        assert_eq "baz" $(filepath_base "/foo/bar/baz/")
        assert_eq "dev.txt" $(filepath_base "dev.txt")
        assert_eq "todo.txt" $(filepath_base "../todo.txt")
        assert_eq ".." $(filepath_base "..")
        assert_eq "." $(filepath_base ".")
        assert_eq "/" $(filepath_base "/")
        assert_eq "." $(filepath_base "")
        assert_eq "/" $(filepath_base "/////")
}
readonly -f test_filepath_base

function test_filepath_ext() {
        assert_eq "" "$(filepath_ext 'index')"
        assert_eq "" "$(filepath_ext '')"
        assert_eq ".js" $(filepath_ext "index.js")
        assert_eq ".js" $(filepath_ext "main.test.js")
        assert_eq ".js" $(filepath_ext "something/main.test.js")
        assert_eq ".js" $(filepath_ext "/something/main.test.js")
}
readonly -f test_filepath_ext

function test_filepath_dir() {
        assert_eq "/foo/bar" $(filepath_dir "/foo/bar/baz.js")
        assert_eq "/foo/bar" $(filepath_dir "/foo/bar/baz")
        assert_eq "/foo/bar" $(filepath_dir "/foo/bar/baz/")
        assert_eq "/dirty" $(filepath_dir "/dirty//path///")
        assert_eq "." $(filepath_dir "dev.txt")
        assert_eq ".." $(filepath_dir "../todo.txt")
        assert_eq "." $(filepath_dir "..")
        assert_eq "." $(filepath_dir ".")
        assert_eq "/" $(filepath_dir "/")
        assert_eq "/" $(filepath_dir "////")
        assert_eq "." "$(filepath_dir '')"
}
readonly -f test_filepath_dir

function test_filepath_is_abs() {
        local ec

        filepath_is_abs "${HOME}" || assert_fail

        ec=0
        filepath_is_abs ".bashrc" || ec=$?
        assert_false ${ec}

        ec=0
        filepath_is_abs ".." || ec=$?
        assert_false ${ec}

        ec=0
        filepath_is_abs "." || ec=$?
        assert_false ${ec}

        filepath_is_abs "/" || assert_fail

        ec=0
        filepath_is_abs "" || ec=$?
        assert_false ${ec}
}
readonly -f test_filepath_is_abs
