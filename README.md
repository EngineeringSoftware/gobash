## gobash

[![test (bash 3)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-bash3.yml/badge.svg)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-bash3.yml)
[![test (bash 4)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-bash4.yml/badge.svg)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-bash4.yml)
[![test (bash 5)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-bash5.yml/badge.svg)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-bash5.yml)
[![test (mac)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-mac.yml/badge.svg)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-mac.yml)
[![lint](https://github.com/EngineeringSoftware/gobash/actions/workflows/lint.yml/badge.svg)](https://github.com/EngineeringSoftware/gobash/actions/workflows/lint.yml)

`gobash` library is a set of functions that improve programming
experience in `bash` (by providing collections, languages features,
APIs, testing package, command line flag parsing, etc.)  without
modifying the shell interpreter(s).  It works with any bash version
(on Linux and Mac).  Parts of the API are matching those in Go.

If you cannot wait to see code, here is a quick example (but check
later sections for a lot more):

```
#!/bin/bash

# Import the library.
source /dev/stdin <<< "$(curl https://raw.githubusercontent.com/EngineeringSoftware/gobash/master/hsabog 2>/dev/null)"

# Create a communication channel.
ch=$(Chan)
# Send a message (blocking call) in a sub process.
( lst=$(List 2 3 5); $ch send "$lst" ) & 

# Receive the message (blocking call) in the main process.
lst=$($ch recv)

$lst to_string
# Output:
# [
#   "2",
#   "3",
#   "5"
# ]
```

If you love learning by example, take a look at the [examples
page](/examples/README.md).  A quick demo of the very basic concepts
using a toy example is available [here](/doc/gobash.gif).


## Key Features

We focused on a design that enables the following key features
(discussed in more detail in later sections):

* **Programming language features** - `gobash` enables (via functions and files) defining `structs` and `methods` and instantiating "objects", e.g., [example](/examples/methods_ex)
* **Arguments and return values** - `gobash` supports passing "objects" as arguments to functions and returning them as "out" arguments, e.g., [example](/examples/result_ex)
* **Collections** - `gobash` (using `structs`) provides a flexible collections: `List`s and `Map`s (thus avoiding built-in structures when they are not sufficiently flexible or they are not available in old versions), e.g., [example](/examples/list_ex)
* **Command line flag parsing** - `gobash` introduces a set of functions for parsing command line flags (similar to those in other programming languages), e.g., [example](/examples/flags_ex)
* **Testing** - `gobash` comes with a testing package, e.g., [example](/examples/playground/test_function_ex)
* **API** - `gobash` provides a set of functions to support common tasks and abstractions, such as strings, `Mutex`, `Chan`, e.g., [example](/examples/binary_trees_ex)


## Table of Content

* [Overview](#overview)
    * [Motivation](#motivation)
    * [Design](#design)
* [Get Started](#get-started)
    * [Prepare Environment](#prepare-environment)
    * [List Collection Example](#list-collection-example)
    * [Struct Example](#struct-example)
    * [Test Example](#test-example)
    * [Next Step](#next-step)
* [Features](#features)
    * [Basic Terminology](#basic-terminology)
    * [Reserved Words](#reserved-words)
    * [Structs](#structs)
    * [Objects](#objects)
    * [Anonymous Structs](#anonymous-structs)
    * [Methods](#methods)
    * [To String](#to-string)
    * [Return Value](#return-value)
    * [Error Handling](#error-handling)
    * [Collections](#collections)
    * [Inter-process Communication](#inter-process-communication)
* [Interactive Mode](#interactive-mode)
* [Testing](#testing)
    * [Writing Tests](#writing-tests)
    * [Accessing Test Metadata](#accessing-test-metadata)
    * [Skipping Tests](#skipping-tests)
    * [Asserting Results](#asserting-results)
    * [Mocking Functions](#mocking-functions)
    * [Running Tests](#running-tests)
* [Command Line Flags](#command-line-flags)
* [Dependencies](#dependencies)
* [Versioning](#versioning)
* [Acknowledgments](#acknowledgments)
* [License](#license)
* [Contact](#contact)


## Overview

A brief motivation and design decisions.

### Motivation

`shell` is a nice scripting language (especially considering its age).
Close integration of interpreters with operating systems and a ton of
available binaries on these systems (e.g., `awk`, `sed`, `jq`) make it
a great choice for quick and concise scripting.  In recent years, some
of the scripting has moved over to Python (and a few other languages)
due to availability of (standard) libraries and testing support.
However, seeing `import subprocess; subprocess.run(["ls", "-l"])` or
similar code in Python, and then using replacements for `awk`, `sed`,
`grep`, `git` commands (and awkwardly processing their outputs) never
looks very exciting.

Key motivation points:

* Provide a "standard" library for bash
* Provide missing language features (but do not design new language or change interpreters)
* Enable using the same set of functions across various operating systems
* Enable using different interpreters (and their versions) by hiding details behind APIs

Finally, in recent years, we had a feeling that programming in bash
can be similar to programming in Go (e.g., an easy way to run things
in parallel `()&` vs. `go`, dealing with errors via exit codes,
keeping API naming alike). Definitely not saying you should program in
`gobash` instead of Go, but if you do end up writing a few lines in
`bash` then they could look similar or give a similar feel like those
you write in Go. We will see how much that holds.

### Design

Key design goal: Implement everything using functions and files (i.e.,
there is no need to change existing shells or existing user code).

As the result, a user can adopt `gobash` as needed without being
forced to rewrite any of their code, but can benefit by using some/all
of `gobash` features, which can be introduced gradually.
Additionally, `gobash` should work with any `bash` version and OS that
runs `bash`.


## Get Started

It is trivial to get started using `gobash`, because it only adds to
the knowledge you already have about shell programming.

There are two modes in which `gobash` can be used: (a) as a library,
or (b) as a tool. Most of the examples below use `gobash` as a library
(i.e., source `gobash` into a script and use available functions). The
section on testing introduces `gobash` as a tool (which offers more
than just the testing features).

### Prepare Environment

Create a space for trying `gobash`:

```
mkdir space
cd space
```

Clone this repo:

```
git clone git@github.com:EngineeringSoftware/gobash
```

You can also avoid cloning the repo and directly source the library in
your bash script:
```
source /dev/stdin <<< "$(curl https://raw.githubusercontent.com/EngineeringSoftware/gobash/master/hsabog 2>/dev/null)"
```

### List Collection Example

Write your first script (let's call it `s`) that uses `gobash`. The
example below "imports" the entire library and uses the `List`
collection for storing values.

```
#!/bin/bash
. gobash/gobash

# Instantiate a list and add two elements.
lst=$(List)
$lst add 55
$lst add 100

# Get the length of the list.
$lst len
# Output: 2

# Print the list (default print is in the json format).
$lst to_string
# Output:
# [
#   "55",
#   "100"
# ]
```

### Struct Example

In the following example (`point.sh`), we introduce a `struct` for a
2D point, set/get values, and write a function to add two points.

```
#!/bin/bash
. gobash/gobash

function Point() {
        make_ $FUNCNAME \
              "x" "$1" \
              "y" "$2"
}

function point_add() {
        local p1="${1}"
        local p2="${2}"

        local x=$(( $($p1 x) + $($p2 x) ))
        local y=$(( $($p1 y) + $($p2 y) ))
        local p3=$(Point "${x}" "${y}")
        echo "$p3"
}

p1=$(Point 3 4)
p2=$(Point 8 9)
p3=$(point_add "$p1" "$p2")
$p3 to_string
# Output:
# {
#   "x": "11",
#   "y": "13"
# }
```

### Test Example

This example illustrate a way to write tests using a testing package.
The tests can be executed with the `gobash` tool.

We will extend the previous example to add tests (`point_test.sh`) for
the function `point_add`.

```
#!/bin/bash

. point.sh

function test_point() {
        p1=$(Point 3 4)
        p2=$(Point 8 9)
        p3=$(point_add "$p1" "$p2")
        assert_ze $?
        assert_eq 11 $($p3 x)
        assert_eq 13 $($p3 y)
}
```

Tests can be run with the following command:

```
./gobash test --paths point_test.sh --verbose
```

The output of this execution:

```
    test_point start
    test_point PASSED
  ./point_test.sh 1[sec]
Tests run: 1, failed: 0, skipped: 0.
Total time: 1[sec]
```

### Next Step

There are a number of other examples that illustrate `gobash` in the
[examples](/examples) directory.  If you like learning by examples,
that is the best place to go next.  If you prefer to read higher level
doc, then the next section is a good step forward.


## Features

We use available constructs and binaries (e.g., functions, `sed`,
`grep`) to introduce new features to improve `shell` programming
experience.

As the result of the `gobash` design, you can introduce it step by
step, as you do not need to modify any of the existing code you have.

### Basic Terminology

A `package` corresponds to a single directory and a `module`
corresponds to a single `.sh` file.

Thus, a "script program" consists of one or more packages with one or
more modules in those packages.


### Reserved Words

`gobash` is a set of functions and a few global variables.

There are several "keywords", which means a set of functions that a
user should avoid replacing. Below is the current list of "keywords";
to get the list of all functions in `gobash` you can run `./gobash
func sys_functions` (or use `grep` over this repository).

```
make_ - allocates an object (and introduces a struct at the same time)
amake_ - allocates an object (which is an instance of an anonymous struct)
```

`gobash` also uses several (readonly) global variables that a user
should be aware of:

```
EC - error code returned from library functions if something goes wrong
NULL - null value to be used to set non-primitive fields
TRUE - true boolean value
FALSE - false boolean value

BOOL - boolean type used in some APIs
INT - int type used in some APIs
FLOAT - float type used in some APIs
STRING - string type used in some APIs
```

Finally, `gobash` uses the file descriptor `3` in some functions.

### Structs

Similar to structs/records in other programming languages, you can
create complex data types with `gobash`. Unlike in other languages,
in `gobash` you only need to implement a `constructor`.  The name of
the constructor is automatically the name of the `struct` as well.

```
function Person() {
        make_ $FUNCNAME \
              "name" "$1" \
              "age" "$2"
}
```

You can think of the `Person` function as both defining a struct and
providing a constructor (although it is more the latter). Note that
the constructor function can perform any other work, e.g., check the
validity of arguments.

The first argument to `make_` provides the name of the struct. While
one can play with generating these names (or replacing with some other
structs), in the most common scenarios, the first argument we set to
be the name of the constructor (i.e., `$FUNCNAME`).

### Objects

Once a struct is defined, it can be used to create objects and set/get
the fields.

```
p=$(Person "Jessy" 10)
$p age 20 # set the field value
$p age # get the field value
```

NOTE: When an object is passed to a function as an argument, it has to
be quoted.

```
function person_print() {
        local -r p="${1}"
        $p to_string
}

person_print "$p" # valid
# person_print $p # not valid
```

### Anonymous Structs

It is sometimes convenient to create an anonymous struct to carry
several values to a function or group some relevant data within a
single function.  Anonymous structs are a good choice in that case.

In the example below, we create an anonymous struct that keeps values
for a 2D point.

```
#!/bin/bash
. gobash/gobash

function print() {
        local -r p="${1}"
        $p to_string
}

function make_and_print() {
        local -r p=$(amake_ "x" 3 "y" 5) # this line creates an instance of anonymous struct
        print "$p"
}

make_and_print
# Output
# {
#   "x": "3",
#   "y": "5"
# }
```

### Methods

Adding a method to a struct is done by implementing a function that is
prefixed by the struct name followed by `_` followed by the method
name. For example, if we have a struct `Str`, we can add a method
`compute` by writing a function `Str_compute`.

The first argument of each method is the object on which the method is
called (this is similar to `this` and `self` in other programming
languages).

In the example below, we introduce a new struct (`Circle`) and add a
method that computes its total area.

```
function Circle() {
        [ $# -ne 1 ] && return $EC
        local -r r="${1}"

        make_ $FUNCNAME \
              "r" "${r}"
        return $?
}

function Circle_area() {
        local -r obj="${1}"

        echo "$MATH_PI * $($obj r) * $($obj r)" | bc
        return 0
}
```

Invoking a method is similar to other programming languages. Below, we
create an instance of a `Circle` and compute the total area.

```
c=$(Circle 20)
$c area
```

### To String

`gobash` provides a default `to_string` method for each struct. The
default implementation outputs the object in the json format. One can
decide to override the default behavior by implementing `to_string`
method for a specific struct.

The example below shows the default `to_string` output for the
`Person` struct (introduced earlier in this document) and then
implements a more specific `to_string` method.

In the snippet below, we construct one object and use the default
`to_string` method.

```
p=$(Person "Jessy" 10)
$p to_string
```

As the result we get output in the json format, which can be
convenient for further processing (e.g., using `jq`).

```
{
  "name": "Jessy",
  "age": "10"
}
```

In the snippet below, we implement a `to_string` method for the
`Person` struct. Specifically, we output a simple string that prints
only the name of the person.

```
function Person_to_string() {
        local -r obj="${1}"
        echo "I am $($obj name)."
}
p=$(Person "Jessy" 10)
$p to_string
# Output
# I am Jessy.
```

### Return Value

This section is about returning data from a function to its caller.
(The next section talks about error handling and the `return`
statement.)

`gobash` uses primarily three approaches to return data from a
function.

First, simple functions use `echo` to return desired value or an
object. In the next code snippet, we return a point that has values of
coordinates double of the given point.

```
#!/bin/bash
. gobash/gobash

function Point() {
        make_ $FUNCNAME \
              "x" "$1" \
              "y" "$2"
}

function point_double() {
        local -r p="${1}"

        local x=$(( $($p x) * $($p x) ))
        local y=$(( $($p y) * $($p y) ))
        local -r d=$(Point ${x} ${y})

        # Return newly created point. Do not forget that you need quotes.
        echo "$d"
}

p=$(Point 3 4)
d=$(point_double "$p")
$d to_string
```

Second, we use "out" argument that is populated inside the function
body. In the next code snippet, we write the same function as above,
but this time we pass the object, which we set inside the body.

```
#!/bin/bash
. gobash/gobash

function Point() {
        make_ $FUNCNAME \
              "x" "$1" \
              "y" "$2"
}

function point_double() {
        # We prefer to have out arguments first.
        local -r d="${1}"
        local -r p="${2}"

        local x=$(( $($p x) * $($p x) ))
        local y=$(( $($p y) * $($p y) ))
        $d x ${x}
        $d y ${y}
}

p=$(Point 3 4)
d=$(Point 0 0)
point_double "$d" "$p"
$d to_string
```

Third, we use an instance of the `Result` struct as an out argument,
which can carry a value (`val`). Basically, this is a specialized form
of the second case.

```
#!/bin/bash
. gobash/gobash

function Point() {
        make_ $FUNCNAME \
              "x" "$1" \
              "y" "$2"
}

function point_double() {
        local -r res="${1}"
        local -r p="${2}"

        local x=$(( $($p x) * $($p x) ))
        local y=$(( $($p y) * $($p y) ))
        local -r d=$(Point ${x} ${y})
        $res val "$d"
}

p=$(Point 3 4)
res=$(Result)
point_double "$res" "$p"
$($res val) to_string
```

### Error Handling

Each function should return exit code: zero if the execution went well
and non-zero if there was an issue detected. (While `return $?` in
many cases at the end of a function is not needed, we sometimes use
them explicitly.) `gobash` uses `return $EC` for indicating an issue
inside functions from the library. Any function invocation should
ideally check for errors. An example below shows a basic case of
checking argument types and returning and error in case of an
incorrect type.

```
function Point() {
        local -r x="${1}"
        local -r y="${2}"

        ! is_int "${x}" && return $EC
        ! is_int "${y}" && return $EC

        make_ $FUNCNAME \
              "x" "${x}" \
              "y" "${y}"
}
```

Now a caller can check for an error.

```
p=$(Point 3 4) || echo "error"
```

One exception to the rule above (when it comes to zero/non-zero
values) is that functions that return boolean values return `$TRUE`
(0) and `$FALSE` (1). Check the function in
[bool.sh](/src/lang/bool.sh) for several examples.

Sometimes a more descriptive error message is more appropriate. In
those cases, we use `context` arguments.  A context argument is used
to store and carry information about errors and stacktrace (at the
time of an error).  Each function in `gobash` accepts context (`ctx`)
as the first argument; if one is not given, then the global context is
used to store errors and stacktraces. In the example below, we use the
global context. (We provide more examples with context in the examples
directory.)

```
#!/bin/bash
. gobash/gobash

function Point() {
        make_ "$FUNCNAME" \
              "x" "$1" \
              "y" "$2"
}

function point_double() {
        local -r p="${1}"

        is_null $($p x) && ctx_w "'x' is incorrect" && return $EC
        is_null $($p y) && ctx_w "'y' is incorrect" && return $EC

        local x=$(( $($p x) * $($p x) ))
        local y=$(( $($p y) * $($p y) ))
        local -r d=$(Point ${x} ${y})
        $res val "$d"
}

ctx_clear # clear the global context (as it is stored across runs)
p=$(Point 3 10)
$p x $NULL
point_double "$p" || \
        { ctx_show; ctx_stack; } # show the error and stacktrace.
```

### Collections

Two key collections are `List` and `Map`. They come with a number
of methods that can be convenient in everyday development.

In the example below, we use a list to keep URLs of several projects
available on GitHub and then clone those projects in a loop.

```
#!/bin/bash
. gobash/gobash

lst=$(List)
$lst add "https://github.com/apache/commons-math"
$lst add "https://github.com/apache/commons-io"

# Print length.
$lst len

# Clone each repo.
for (( i=0; i<$($lst len); i++)); do
        git clone $($lst get $i)
done

# Print the list.
$lst to_string
```

NOTE: Equality in `gobash` is done based on object identity. Future
changes could consider using `eq` methods to check for equality (like
in other programming languages).

### Inter-process Communication

Starting a new process or a sub process is trivial in `shell`.  The
design of `gobash` enables easy sharing of objects and process
communication. An object can be used in a sub shell or it can be
passed to a different process. We illustrate the former case below.

```
#!/bin/bash
. gobash/gobash

ai=$(AtomicInt 0)
( $ai inc ) &
( $ai inc ) &
( $ai inc ) &
wait
$ai val
```

In this example, we create an object (`AtomicInt`) that is used in
three sub shells. Once all sub shells finish their work, we print the
final value.


## Interactive Mode

`gobash` nicely inter-operates with interactive mode, i.e.,
terminal. Namely, one can import `gobash` into interactive terminal
and use all functions and features available. In other words you get
REPL for free.

In the example below, open your terminal and execute some commands.

```
$ . gobash/gobash
$ lst=$(List)
$ $lst len
# 0
$ $lst add $RANDOM
$ $lst to_string
# [
#   "16748"
# ]
$ p=$(struct "x" 3 "y" 55)
$ $p to_string
# {
#   "x": "3",
#   "y": "55"
# }
```

One of the (obvious) implications is that you can now write scripts
that accept objects, and those scripts can be invoked from your
terminal with objects made in the terminal process.

Consider the script below (`ai`). (This is the same example we used
in an earlier section to illustrate inter-process communication.)

```
#!/bin/bash
. gobash/gobash

ai="${1}"
( $ai inc ) &
( $ai inc ) &
( $ai inc ) &
wait
$ai val
```

Now in a terminal execute the following sequence.

```
$ obj=$(AtomicInt 6)
$ ./ai "$obj"
# 9
```


## Testing

In this section, we describe the way to write tests.  We discuss the
testing package on a [separate page](/doc/testing.md).


### Writing Tests

It is great having tests for each function. We keep test files in the
same package as the corresponding source files. Test files have to
have suffix `_test.sh`.

Each test is a function that starts with `function test_`. The outcome of a
test corresponds to the return code from the test function.

Here is an example of a trivially passing test.

```
function test_passing() {
        return 0
}
```

Here is an example of a trivially failing test.

```
function test_failing() {
        return 1 # or any other non-zero value
}
```

### Accessing Test Metadata

The first (and only) argument passed to each test function (test for
short) is an object (an instance of the `TestT` struct), which carries
metadata about the test itself and can be used by the developers to
set test status (more on this in later sections).

```
function test_first_arg() {
        local -r t="${1}"
        # You can access info about the test via t.
}
```

### Skipping Tests

Using a test metadata object, one can skip a test by invoking the
`skip` method. An optional message can be given as well, which will be
shown during test result reporting.

In the example below, we show a test that is skipped in case
dependencies for the library being tested are not
available. Specifically, when testing the `whiptail` package, we check
that dependencies for that package are available (by invoking
`whiptail_enabled`). If dependencies are not available, we skip the
test.

```
function test_whiptail_msg_box() {
        local -r t="${1}"
        ! whiptail_enabled && $t skip "No deps."

        local box
        # ...
}
```

NOTE: If a test fails and the skip flag is set to true, the test will
be counted as failing (and not as skipped).


### Asserting Results

`gobash` includes a number of assertion functions
([assert.sh](/src/lang/assert.sh)) that can be conveniently used in
tests. If an assertion fails, a stack trace is printed, and `exit 1`
is executed. (Note that a failing assertion stops only the current
test, and not the entire test run, because each test is run in a
subshell.) In the library itself, we do not use `assert` functions to
ensure compatibility with `set -e` option in bash.

```
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
```

### Mocking Functions

Mocking in `gobash` is done on a function level. There is nothing
specific to `gobash`, as we simply rely on bash dynamic nature and
ability to replace any function (in a specific scope).

Below is an example of mocking that we use during testing of the
`whiptail` API. To avoid opening any window during testing (and
invoking `whiptail`), we implement a mock function that will be
invoked from `show`. The mock function simply returns a result that we
desire.

```
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
```

### Running Tests

`gobash test` command can be used for running tests

```
./gobash test # arguments as you wish
```

More details about the [`testing package`](/doc/testing.md) on a
separate page.


## Command Line Flags

`gobash` can simplify parsing command line flags. In the next example,
we illustrate parsing using the `flags` package. Specifically, we
create `Flags` with desired documentation and add two flags. Each flag
has to include name, type (int, bool, float, or string), and
documentation.

```
#!/bin/bash
. gobash/gobash

min=$(Flag "x" "int" "Min value.")
max=$(Flag "y" "int" "Max value.")

flags=$(Flags "Flags to demo flag parsing.")
$flags add "$min"
$flags add "$max"
```

We can print help message simply like this:

```
$flags help
```

Parsing flags is then done in a few steps:

```
args=$(Args) # an object that will keep parsed values
ctx=$(ctx_make) # context will store an issue is encountered during parsing
$flags $ctx parse "$args" "$@" || \
    { ctx_show $ctx; exit 1; } # checking for errors

$args x # print the parsed x value
$args y # print the parsed y value
```


## Next

If you are looking for further reading, the best next place is the
[examples page](/examples/README.md).

Regarding the features in `gobash`, there is a lot of potential future
work: improving flag parsing, documentation, API extensions, etc.
Regardless what path this repo takes next, it should always keep
programming abstractions simple (e.g., no hiding anything behind
annotations).

Performance is the current biggest issue. We do have several ideas on
improving the performance, but we might wait for a couple of users.


## Dependencies

`gobash` uses several binaries widely avaialble on Unix. Although
things keep changing, the list likely includes `jq`, `sed`, `grep`,
`awk`, `date`.


## Versioning

`gobash` was tested on Linux with the following bash versions:

| gobash    | bash 3 | bash 4 | bash 5 |
| ----------|--------|--------|------- |
| 1.0.1-dev | 3.2.57 | 4.4.18 | 5.0.17 |

We also test on Mac.  Please see the CI runs for details and
up-to-date information.

(gobash versions prior to 1 were internal releases. Once we stabilize
API or someone starts using the library, we will make public
releases.)


## Acknowledgments

I would like to thank Ahmet Celik, Owolabi Legunsen, Darko Marinov,
Pengyu Nie, and Aditya Thimmaiah for years of joint fun with bash.
Also, I would like to thank Aleksandar Milicevic for his feedback on
this project.


## License

[BSD-3-Clause license](LICENSE).


## Contact

Feel free to get in touch if you have any comments: Milos Gligoric
`<milos.gligoric@gmail.com>`.
