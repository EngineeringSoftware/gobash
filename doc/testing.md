## Testing Package

Testing package provides features similar to xUnit frameworks
available in other languages (`testing` package in Go, `pyunit` for
Python, `JUnit` for Java, etc.).

Below is the help message for `gobash test`, which is printed when
running the framework without any arguments.  (While we strive to keep
this doc up-to-date, the latest help message is best obtained by
running `gobash test`.)

```
Testing package.
  --paths (string) - Name pattern for finding files with tests.
  --tests (string) - Regular expression for test functions to run.
  --verbose (bool) - Enables verbose output.
  --quiet (bool) - Disable any output.
  --junitxml (string) - File name for a report in the JUnit xml format.
  --max_secs (int) - Max seconds per test.
  --stdout (bool) - Enable stdout from tests.
```

### Test File Naming

Test functions should be written in files with the `_test.sh`
extension.  Although not required, it is expected that for every file,
e.g., `matrix.sh`, there would be a corresponding test file, e.g.,
`matrix_test.sh`.

### Test Function Naming

Each test function has to start with `function test_`.  These
functions have to be at the beginning of lines.

```
function test_strings_cap() { # Valid test signature.

  function test_strings_cap() { # NOT a valid test signature (not at the beginning of a line).

function strings_cap_test() { # NOT a valid test signature (does not start with test).

test_strings_cap() { # NOT a valid test signature (no function keyword).

function test_strings_cap()    { # NOT a valid test signature (spaces after ()).

function test_strings_cap   () { # NOT a valid test signature (spaces after the identifier).

function test_strings_cap()
{ # NOT a valid test signature ({ not on the same line).
```

Test function names in this repo are formed with the following
convention:

  * `function test_` at the beginning (required)
  * name of the module being tested (e.g., `strings`)
  * name of the function being tested OR meaningful description if more than a single function is targeted

Below are some examples from this repo.

```
# strings_test.sh - test for strings.sh module.

function test_strings_len() { ...
```

```
# complex_test.sh - test for complex.sh module.

function test_complex_plus() { ...
```

### Running Tests

Run all tests available in files in the current directory and any sub
directory.

```
$ gobash test --paths .
```

NOTE: Given value to `--paths` is used as a name pattern of a `find`
command to find files with tests.

Run all available in the given file (the file does not need to be in
the current working directory.):

```
$ gobash test --paths src/util/strings_test.sh
  ./src/util/strings_test.sh 8[sec]
Tests run: 23, failed: 0, skipped: 0.
Total time: 8[sec]
```

Run selected tests available in the given file:

```
$ gobash test --paths strings_test.sh --tests test_strings_len
./src/util/strings_test.sh 783[ms]
Tests run: 1, failed: 0, skipped: 0.
Total time: 852[ms]
```

NOTE: Given value to `--tests` is used as a value for a `grep` command
to filter tests of interest to run.
