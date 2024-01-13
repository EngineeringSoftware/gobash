
Testing Package
===============

In this section, we describe the way to write and run tests.

Writing Tests
-------------

It is great having tests for each function. We keep test files in the
same package as the corresponding source files. Test files have to
have suffix `_test.sh`.

Each test is a function that starts with `function test_`. The outcome
of a test corresponds to the return code from the test function.

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

TODO: insert details about the testing package

.. toctree::
   :maxdepth: 2
