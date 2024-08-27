
Collections
===========

gobash introduces two key collections: ``List`` and ``Map``. Both
collections include a number of methods that can be convenient for
everyday development.

In the example below, we use an instance of a ``List`` to keep URLs of
several GitHub projects and then close each of those projects in a
loop.

.. code-block:: bash

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

.. note::

   Equality in gobash is done based on object identity. Future changes
   could consider using ``eq`` methods to check for equality (similar
   to other programming languages).

.. toctree::
   :maxdepth: 2
