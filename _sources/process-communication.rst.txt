
Inter-process Communication
===========================

Starting a new process or a sub process is trivial in shell. The
design of gobash enables easy sharing of objects and process
communication. An object can be used in a sub shell or it can be
passed to a different process. We illustrate the former case below.

.. code-block:: bash

    #!/bin/bash
    . gobash/gobash

    ai=$(AtomicInt 0)
    ( $ai inc ) &
    ( $ai inc ) &
    ( $ai inc ) &
    wait
    $ai val

In this example, we create an object (``AtomicInt``) that is used in
three sub shells. Once all sub shells finish their work, we print the
final value.

.. toctree::
   :maxdepth: 2
