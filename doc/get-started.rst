
Get Started
===========

It is trivial to get started using gobash, because it only adds to the
knowledge you already have about shell programming. Also, it does not
require any special setup, because everything is pure bash.

There are two modes in which gobash can be used: (a) as a library,
or (b) as a tool. Most of the examples below use gobash as a library
(i.e., source gobash into a script and use available functions). There
is a separate section to describe using gobash as a tool.

We will use several examples in this section to get you started.

Prepare Environment
-------------------

Create a space for trying gobash:

.. code-block:: bash

    mkdir space
    cd space

Clone the gobash repository:

.. code-block:: bash

    git clone git@github.com:EngineeringSoftware/gobash

Alternatively, you can avoid cloning the repo and directly source the
library in your bash script:

.. code-block:: bash

    source /dev/stdin <<< "$(curl https://raw.githubusercontent.com/EngineeringSoftware/gobash/master/hsabog 2>/dev/null)"

Now, we are ready to run some examples.

Collection Example
------------------

Write your first script (let's call it `s`) that uses gobash. The
example below "imports" the entire gobash library and uses the `List`
collection for storing values.

.. code-block:: bash

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

Struct Example
--------------

In the following example (`point.sh`), we introduce a `struct` for a
2D point, set/get values, and write a function to add two points.

.. code-block:: bash

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

Test Example
------------

This example illustrate a way to write tests using a testing package.
The tests can be executed with the gobash tool.

We will extend the previous example to add tests (`point_test.sh`) for
the function `point_add`.

.. code-block:: bash

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

Tests can be run with the following command:

.. code-block:: bash

    ./gobash test --paths point_test.sh --verbose

The output of this execution will be along these lines:

.. code-block:: bash

        test_point start
        test_point PASSED
      ./point_test.sh 1[sec]
    Tests run: 1, failed: 0, skipped: 0.
    Total time: 1[sec]

Further Reading
---------------

There are a number of other examples that illustrate gobash in the
`examples directory
<https://github.com/EngineeringSoftware/gobash/tree/main/examples/README.md>`_.
If you like learning by examples, that is the best place to go next.
If you prefer to read higher level doc, then check
:doc:`language`.

.. toctree::
   :maxdepth: 2
