
Command Line Flags
==================

gobash can simplify parsing command line flags. In the next example,
we illustrate parsing using the ``flags`` package. Specifically, we
create ``Flags`` with desired documentation and add two flags. Each
flag has to include name, type (int, bool, float, or string), and
documentation.

.. code-block:: bash

    #!/bin/bash
    . gobash/gobash
    
    min=$(Flag "x" "int" "Min value.")
    max=$(Flag "y" "int" "Max value.")
    
    flags=$(Flags "Flags to demo flag parsing.")
    $flags add "$min"
    $flags add "$max"

Once we build the flags, we can print a help message simply like this:

.. code-block:: bash

    $flags help

Parsing flags is then done in a few steps:

.. code-block:: bash

    args=$(Args) # an object that will keep parsed values
    ctx=$(ctx_make) # context will store an issue is encountered during parsing
    $flags $ctx parse "$args" "$@" || \
        { ctx_show $ctx; exit 1; } # checking for errors
    
    $args x # print the parsed x value
    $args y # print the parsed y value

.. toctree::
   :maxdepth: 2
