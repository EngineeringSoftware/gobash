
Interactive Mode
================

gobash nicely inter-operates with interactive mode, i.e.,
terminal. Namely, one can import gobash into interactive terminal and
use all functions and features available. In other words you get REPL
for free.

In the example below, open your terminal and execute some commands.

.. code-block:: bash

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

One of the implications is that you can now write scripts that accept
objects, and those scripts can be invoked from your terminal with
objects made in the terminal process.

Consider the script below (`ai`). (This is the same example we used in
an earlier section to illustrate inter-process communication.)

.. code-block:: bash

    #!/bin/bash
    . gobash/gobash

    ai="${1}"
    ( $ai inc ) &
    ( $ai inc ) &
    ( $ai inc ) &
    wait
    $ai val

Now in a terminal execute the following sequence.

.. code-block:: bash

    $ obj=$(AtomicInt 6)
    $ ./ai "$obj"
    # 9

.. toctree::
   :maxdepth: 2
