
Motivation
==========

bash is a nice scripting language (especially considering its age).
Close integration of interpreters with operating systems and a ton of
available binaries on these systems (e.g., `awk`, `sed`, `jq`) make it
a great choice for quick and concise scripting.  In recent years, some
of the scripting has moved over to Python (and a few other languages)
due to availability of (standard) libraries and testing support.
However, seeing `import subprocess; subprocess.run(["ls", "-l"])` or
similar code in Python, and then using replacements for `awk`, `sed`,
`grep`, `git` commands (and awkwardly processing their outputs)
suggests that developers may use bash more if it had better libraries
and testing support.

Key motivation points:

* Provide a "standard" library for bash
* Provide missing language features (without designing a new language or changing interpreters)
* Enable using the same set of functions across various operating systems
* Enable using different interpreters (and their versions) by hiding details behind APIs

Finally, in recent years, we had a feeling that programming in bash
can be similar to programming in Go (e.g., an easy way to run things
in parallel `()&` vs. `go`, dealing with errors via exit codes,
keeping API naming alike). Definitely not saying you should program in
gobash instead of Go, but if you do end up writing a few lines in
`bash` then they could look similar or give a similar feel like those
you write in Go.

.. toctree::
   :maxdepth: 2
