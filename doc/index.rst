
Welcome to gobash
=================

gobash is a set of bash functions that improve programming experience
in bash (by providing collections, languages features, APIs, testing
package, command line flag parsing, etc.) without modifying the shell
interpreter(s). It works with any bash version (on Linux and
Mac). Parts of the API are matching those in Go.

gobash is publicly available on `GitHub
<https://github.com/EngineeringSoftware/gobash>`_ under the `BSD 3
license
<https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE>`_.

Here is a quick example that uses gobash (but check later sections for
a lot more):

.. code-block:: bash

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

If you love learning by example, take a look at the `examples page
<https://github.com/EngineeringSoftware/gobash/tree/main/examples/README.md>`_.
A quick demo of the very basic concepts using a toy example is
available `here
<https://github.com/EngineeringSoftware/gobash/blob/main/doc/gobash.gif>`_.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   motivation
   design
   get-started
   language
   collections
   process-communication
   interactive-mode
   testing
   command-line-flags
   next

Indices and tables
==================

* :ref:`genindex`
* :ref:`search`
