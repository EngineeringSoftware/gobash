
Language Features
=================

gobash introduces several programming language constructs via bash
functions and wrapping existing binaries (e.g., ``jq``).  It does not
modify bash itself.

As a result of the gobash design, you can introduce it step by step,
as you do not need to modify any of the existing code you have.

Basic Terminology
-----------------

A `package` corresponds to a single directory and a `module`
corresponds to a single ``.sh`` file.

Thus, we define a `program` as a set of packages with one or more
modules each.

Reserved Words
--------------

gobash is a set of functions and a few global variables.

There are several `keywords`, which means a set of functions that a
user should avoid redefining. Below is the current list of keywords;
to get the list of all functions in gobash you can run ``./gobash func
sys_functions`` (or use ``grep`` over the repository).

.. code-block:: bash

    make_ # allocates an object (and introduces a struct at the same time)
    amake_ # allocates an object (which is an instance of an anonymous struct)

gobash also uses several (readonly) global variables that a user
should be aware of:

.. code-block:: bash

    EC # error code returned from library functions if something goes wrong
    NULL # null value to be used to set non-primitive fields
    TRUE # true boolean value
    FALSE # false boolean value

    BOOL # boolean type used in some APIs
    INT # int type used in some APIs
    FLOAT # float type used in some APIs
    STRING # string type used in some APIs

Finally, gobash uses the file descriptor ``3`` in some functions.

Structs
-------

Similar to structs/records in other programming languages, you can
create complex data types with gobash. Unlike in other languages, in
gobash you only need to implement a `constructor`.  The name of the
constructor is automatically the name of the `struct` as well.

.. code-block:: bash

    function Person() {
            make_ $FUNCNAME \
                  "name" "$1" \
                  "age" "$2"
    }

You can think of the ``Person`` function as both defining a struct and
providing a constructor (although it is more the latter). Note that
the constructor function can perform any other work, e.g., check the
validity of arguments.

The first argument to ``make_`` provides the name of the struct. While
one can play with generating these names (or replacing with some other
structs), in the most common scenarios, the first argument we set to
be the name of the constructor (i.e., ``$FUNCNAME``).

Objects
-------

Once a struct is defined, it can be used to create objects and set/get
the fields.

.. code-block:: bash

    p=$(Person "Jessy" 10)
    $p age 20 # set the field value
    $p age # get the field value

.. note::

    When an object is passed to a function as an argument, it has to
    be quoted.

.. code-block:: bash

    function person_print() {
            local -r p="${1}"
            $p to_string
    }

    person_print "$p" # valid
    # person_print $p # not valid

Anonymous Structs
-----------------

It is sometimes convenient to create an anonymous struct to carry
several values to a function or group some relevant data within a
single function.  Anonymous structs are a good choice in that case.

In the example below, we create an anonymous struct that keeps values
for a 2D point.

.. code-block:: bash

    #!/bin/bash
    . gobash/gobash

    function print() {
            local -r p="${1}"
            $p to_string
    }

    function make_and_print() {
            # the line below creates an instance of anonymous struct
            local -r p=$(amake_ "x" 3 "y" 5)
            print "$p"
    }

    make_and_print
    # Output
    # {
    #   "x": "3",
    #   "y": "5"
    # }

Methods
-------

Adding a method to a struct is done by implementing a function that is
prefixed by the struct name followed by ``_`` followed by the method
name. For example, if we have a struct ``Str``, we can add a method
``compute`` by writing a function ``Str_compute``.

The first argument of each method is the object on which the method is
called (this is similar to ``this`` and ``self`` in other programming
languages).

In the example below, we introduce a new struct (``Circle``) and add a
method that computes its total area.

.. code-block:: bash

    function Circle() {
            [ $# -ne 1 ] && return $EC
            local -r r="${1}"

            make_ $FUNCNAME \
                "r" "${r}"
    }

    function Circle_area() {
            local -r c="${1}"

            echo "$MATH_PI * $($c r) * $($c r)" | bc
    }

Invoking a method is similar to other programming languages. Below, we
create an instance of a ``Circle`` and compute the total area.

.. code-block:: bash

    c=$(Circle 20)
    $c area

To String
---------

gobash provides a default ``to_string`` method for each struct. The
default implementation outputs the object in the json format. One can
decide to override the default behavior by implementing ``to_string``
method for a specific struct.

The example below shows the default ``to_string`` output for the
``Person`` struct (introduced earlier in this document) and then
implements a more specific ``to_string`` method.

In the snippet below, we construct one object and use the default
``to_string`` method.

.. code-block:: bash

    p=$(Person "Jessy" 10)
    $p to_string

As a result we get output in the json format, which can be convenient
for further processing (e.g., using ``jq``).

.. code-block:: json

    {
        "name": "Jessy",
        "age": "10"
    }

In the snippet below, we implement a ``to_string`` method for the
``Person`` struct. Specifically, we output a simple string that prints
only the name of the person.

.. code-block:: bash

    function Person_to_string() {
            local -r p="${1}"
            echo "I am $($p name)."
    }
    p=$(Person "Jessy" 10)
    $p to_string
    # Output
    # I am Jessy.

Return Value
------------

This section is about returning data from a function to its caller.
(The next section talks about error handling and the ``return``
statement.)

gobash uses primarily three approaches to return data from a function.

First, simple functions use ``echo`` to return desired value or an
object. In the next code snippet, we return a point that has values of
coordinates double of the given point.

.. code-block:: bash

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

Second, we use "out" argument that is populated inside the function
body. In the next code snippet, we write the same function as above,
but this time we pass the object, which we set inside the body.

.. code-block:: bash

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

Third, we use an instance of the ``Result`` struct as an out argument,
which can carry a value (``val``). Basically, this is a specialized
form of the second case.

.. code-block:: bash

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

Error Handling
--------------

Each function should return exit code: zero if the execution went well
and non-zero if there was an issue detected. (While ``return $?`` in
many cases at the end of a function is not needed, we sometimes use
them explicitly.) gobash uses ``return $EC`` for indicating an issue
inside functions from the library. Any function invocation should
ideally check for errors. An example below shows a basic case of
checking argument types and returning and error in case of an
incorrect type.

.. code-block:: bash

    function Point() {
            local -r x="${1}"
            local -r y="${2}"
    
            ! is_int "${x}" && return $EC
            ! is_int "${y}" && return $EC
    
            make_ $FUNCNAME \
                  "x" "${x}" \
                  "y" "${y}"
    }

Now a caller can check for an error.

.. code-block:: bash

    p=$(Point 3 4) || echo "error"

One exception to the rule above (when it comes to zero/non-zero
values) is that functions that return boolean values return ``$TRUE``
(0) and ``$FALSE`` (1). Check the function in `bool.sh
<https://github.com/EngineeringSoftware/gobash/blob/main/src/lang/bool.sh>`_.

Sometimes a more descriptive error message is more appropriate. In
those cases, we use `context` arguments.  A context argument is used
to store and carry information about errors and stacktrace (at the
time of an error).  Each function in gobash accepts context (``ctx``)
as the first argument; if one is not given, then the global context is
used to store errors and stacktraces. In the example below, we use the
global context. (We provide more examples with context in the examples
directory.)

.. code-block:: bash

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

.. toctree::
   :maxdepth: 2
