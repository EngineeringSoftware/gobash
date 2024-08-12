## gobash

[![test (bash 3)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-bash3.yml/badge.svg)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-bash3.yml)
[![test (bash 4)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-bash4.yml/badge.svg)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-bash4.yml)
[![test (bash 5)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-bash5.yml/badge.svg)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-bash5.yml)
[![test (mac)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-mac.yml/badge.svg)](https://github.com/EngineeringSoftware/gobash/actions/workflows/test-mac.yml)
[![lint](https://github.com/EngineeringSoftware/gobash/actions/workflows/lint.yml/badge.svg)](https://github.com/EngineeringSoftware/gobash/actions/workflows/lint.yml)

`gobash` is a set of functions that improve programming experience in
`bash` (by providing collections, languages features, APIs, testing
package, command line flag parsing, etc.)  without modifying the shell
interpreter(s).  It works with any bash version (on Linux and Mac).
Parts of the API are matching those in Go.

For more information about gobash, see the main documentation page:
http://gobash.org.

API documentation is available
[here](https://engineeringsoftware.github.io/gobash/api.html).

If you love learning by example, take a look at the [examples
page](/examples/README.md).  A quick demo of the very basic concepts
using a toy example is available [here](/doc/gobash.gif).


## Key Features

We focused on a design that enables the following key features
(discussed in more detail at gobash.org):

* **Programming language features** - `gobash` enables (via functions and files) defining `structs` and `methods` and instantiating "objects", e.g., [example](/examples/methods_ex)
* **Arguments and return values** - `gobash` supports passing "objects" as arguments to functions and returning them as "out" arguments, e.g., [example](/examples/result_ex)
* **Collections** - `gobash` (using `structs`) provides a flexible collections: `List`s and `Map`s (thus avoiding built-in structures when they are not sufficiently flexible or they are not available in old versions), e.g., [example](/examples/list_ex)
* **Command line flag parsing** - `gobash` introduces a set of functions for parsing command line flags (similar to those in other programming languages), e.g., [example](/examples/flags_ex)
* **Testing** - `gobash` comes with a testing package, e.g., [example](/examples/playground/test_function_ex)
* **API** - `gobash` provides a set of functions to support common tasks and abstractions, such as strings, `Mutex`, `Chan`, e.g., [example](/examples/binary_trees_ex)


## A Quick Example

```bash
#!/bin/bash

# Import the library.
source /dev/stdin <<< "$(curl https://raw.githubusercontent.com/EngineeringSoftware/gobash/main/hsabog 2>/dev/null)"

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


## Dependencies

`gobash` uses several bash builtins, GNU coreutils, and binaries
widely available on Unix. Although the repository keep changing, the
list probably includes `jq`, `sed`, `grep`, `awk`, `date`.


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
