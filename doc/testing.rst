
Testing Package
===============

Testing package provides features similar to xUnit frameworks
available in other languages (`testing` package in Go, `pyunit` for
Python, `JUnit` for Java, etc.).

Writing Tests
-------------

It is great having tests for each function. We keep test files in the
same package as the corresponding source files. Test files have to
have suffix `_test.sh`.  Although not required, it is expected that
for every file, e.g., `matrix.sh`, there would be a corresponding test
file, e.g., `matrix_test.sh`.

Each test is a function that starts with `function test_`.  These
functions have to be at the beginning of lines.

.. code-block:: bash

    function test_strings_cap() { # Valid test signature.
    
      function test_strings_cap() { # NOT a valid test signature (not at the beginning of a line).
    
    function strings_cap_test() { # NOT a valid test signature (does not start with test).
    
    test_strings_cap() { # NOT a valid test signature (no function keyword).
    
    function test_strings_cap()    { # NOT a valid test signature (spaces after ()).
    
    function test_strings_cap   () { # NOT a valid test signature (spaces after the identifier).
    
    function test_strings_cap()
    { # NOT a valid test signature ({ not on the same line).

Test function names in the gobash repository are formed with the
following convention:

* `function test_` at the beginning (required)
* name of the module being tested (e.g., `strings`)
* name of the function being tested OR meaningful description if more than a single function is targeted

Below are some examples from this repo.

.. code-block:: bash

    #strings_test.sh - test for strings.sh module.
    function test_strings_len() { ...

.. code-block:: bash

    # complex_test.sh - test for complex.sh module.
    function test_complex_plus() { ...

Test Outcome
------------

The outcome of a test corresponds to the return code from the test
function.

Here is an example of a trivial passing test.

.. code-block:: bash

    function test_passing() {
            return 0
    }

Here is an example of a trivial failing test.

.. code-block:: bash

    function test_failing() {
            return 1 # or any other non-zero value
    }

Accessing Test Metadata
-----------------------

The first (and only) argument passed to each test function (test for
short) is an object (an instance of the `TestT` struct), which carries
metadata about the test itself and can be used by the developers to
set test status (more on this in later sections).

.. code-block:: bash

    function test_first_arg() {
            local -r t="${1}"
            # You can access info about the test via t.
    }

Skipping Tests
--------------

Using a test metadata object, one can skip a test by invoking the
`skip` method. An optional message can be given as well, which will be
shown during test result reporting.

In the example below, we show a test that is skipped in case
dependencies for the library being tested are not
available. Specifically, when testing the `whiptail` package, we check
that dependencies for that package are available (by invoking
`whiptail_enabled`). If dependencies are not available, we skip the
test.

.. code-block:: bash

    function test_whiptail_msg_box() {
            local -r t="${1}"
            ! whiptail_enabled && $t skip "No deps."
    
            local box
            # ...
    }

.. note::

    If a test fails and the skip flag is set to true, the test will be
    counted as failing (and not as skipped).

Asserting Results
-----------------

gobash includes a number of assertion functions
([assert.sh](/src/lang/assert.sh)) that can be conveniently used in
tests. If an assertion fails, a stack trace is printed, and `exit 1`
is executed. (Note that a failing assertion stops only the current
test, and not the entire test run, because each test is run in a
subshell.) In the library itself, we do not use `assert` functions to
ensure compatibility with `set -e` option in bash.

.. code-block:: bash

    #!/bin/bash
    . gobash/gobash
    
    function test_with_assertion() {
            assert_eq 3 5 "3 and 5 are not equal"
    }
    # Output
    # ERROR: <3> not equal to <5> (3 and 5 are not equal)
    # 67 assert_eq $HOME/projects/gobash/src/lang/assert.sh
    # 6 test_with_assertion ./demo_test.sh
    #   ./demo_test.sh 708[ms]
    # Tests run: 1, failed: 1, skipped: 0.
    # Total time: 834[ms]

Mocking Functions
-----------------

Mocking in gobash is done on a function level. There is nothing
specific to gobash, as we simply rely on bash dynamic nature and
ability to replace any function (in a specific scope).

Below is an example of mocking that we use during testing of the
`whiptail` API. To avoid opening any window during testing (and
invoking `whiptail`), we implement a mock function that will be
invoked from `show`. The mock function simply returns a result that we
desire.

.. code-block:: bash

    function test_whiptail_input_box() {
            local -r t="${1}"
            ! whiptail_enabled && $t skip "No deps."
    
            local box
            box=$(WTInputBox "Text")
            assert_ze $?
    
            # Mocking whiptail command.
            function whiptail() {
                    echo "Result" >&3
                    return 0
            }
            local -r res=$(WTResult)
            $box show "$res"
            assert_eq $($res val) "Result"
    }
    readonly -f test_whiptail_input_box

Running Tests
-------------

`gobash test` command can be used for running tests.

.. code-block:: bash

    ./gobash test # arguments as you wish

Below is the help message for `gobash test`, which is printed when
running the framework without any arguments.  (While we strive to keep
this doc up-to-date, the latest help message is best obtained by
running `gobash test`.)

.. code-block:: bash

    Testing package.
      --paths (string) - Name pattern for finding files with tests.
      --tests (string) - Regular expression for test functions to run.
      --verbose (bool) - Enables verbose output.
      --quiet (bool) - Disable any output.
      --junitxml (string) - File name for a report in the JUnit xml format.
      --max_secs (int) - Max seconds per test.
      --stdout (bool) - Enable stdout from tests.

Run all tests available in files in the current directory and any sub
directory.

.. code-block:: bash

    $ gobash test --paths .

.. note::

   Given value to `paths` is used as a name pattern of a `find`
   command to find files with tests.

Run all available in the given file (the file does not need to be in
the current working directory.):

.. code-block:: bash

    $ gobash test --paths src/util/strings_test.sh
      ./src/util/strings_test.sh 8[sec]
    Tests run: 23, failed: 0, skipped: 0.
    Total time: 8[sec]

Run selected tests available in the given file:

.. code-block:: bash

    $ gobash test --paths strings_test.sh --tests test_strings_len
    ./src/util/strings_test.sh 783[ms]
    Tests run: 1, failed: 0, skipped: 0.
    Total time: 852[ms]

.. note::

   Given value to `tests` is used as a value for a `grep` command to
   filter tests of interest to run.

.. toctree::
   :maxdepth: 2
