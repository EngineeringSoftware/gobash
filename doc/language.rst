
Language Features
=================

gobash introduces several programming language constructs via bash
functions.  It does not modify bash itself in any way.

As the result of the `gobash` design, you can introduce it step by
step, as you do not need to modify any of the existing code you have.

Basic Terminology
-----------------

A `package` corresponds to a single directory and a `module`
corresponds to a single `.sh` file.

Thus, we define a `program` as a set of packages with one or more
modules each.

Reserved Words
--------------

gobash is a set of functions and a few global variables.

There are several `keywords`, which means a set of functions that a
user should avoid redefining. Below is the current list of keywords;
to get the list of all functions in `gobash` you can run `./gobash
func sys_functions` (or use `grep` over the repository).

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

Finally, gobash uses the file descriptor `3` in some functions.

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

You can think of the `Person` function as both defining a struct and
providing a constructor (although it is more the latter). Note that
the constructor function can perform any other work, e.g., check the
validity of arguments.

The first argument to `make_` provides the name of the struct. While
one can play with generating these names (or replacing with some other
structs), in the most common scenarios, the first argument we set to
be the name of the constructor (i.e., `$FUNCNAME`).

.. toctree::
   :maxdepth: 2
