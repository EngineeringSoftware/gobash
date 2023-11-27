### Style

This page is only relevant to people that are considering to
contribute to `gobash`.

Rules that we follow:
* Use 8 spaces (no tabs) to indent code
* Each function definition starts with `function`
* Function name is prefixed is the name of the file (i.e., module)
* Each function should return proper exit code
* All functions in `gobash` accept context as the first argument
* Each function should have at least one test


### Variables

Below are the most common rules that we follow:

* Variable names should be short
* Use snake_case

Below is the list of names that we like to reserve for specific purposes:

```
ec - exit code from a function
```

Any global variable name should be prefixed by the name of the module.
We like to avoid use global variables other than constants.
