## Examples

We provide a number of examples in bash that use `gobash`, as well as
an intro tour into shell scripting if you have no prior experience.

### `gobash`

Each of the following examples uses some features/functions from
`gobash`. The examples are sorted such that each might build on an
earlier example. Checking them in order is the recommended, but
depending on your interest that might not be the case.

* [`hello_world_ex`](hello_world_ex) - Iterates over some key points related to the library
* [`structs_ex`](structs_ex) - Introduces structs and constructors
* [`anonymous_struct_ex`](anonymous_struct_ex) - Introduces anonymous structs
* [`methods_ex`](methods_ex) - Introduces methods
* [`error_ex`](error_ex) - Introduces `ctx` used to write and print error messages
* [`result_ex`](result_ex) - Introduces `Result` struct that can be used to return a value from a function / method
* [`to_string_ex`](to_string_ex) - Illustrates the default `to_string` method and overriding
* [`to_json_ex`](to_json_ex) - Illustrates the default `to_json` method and overriding
* [`list_ex`](list_ex) - Introduces `List` data structures
* [`map_ex`](map_ex) - Introduces `Map` data structure
* [`shapes_ex`](shapes_ex) - Combines structs, methods, and data structures
* [`linked_list_ex`](linked_list_ex) - Revisits structs and methods with a random example
* [`regexp_ex`](regexp_ex) - Illustrates use of the regular expression API
* [`flags_ex`](flags_ex) - Illustrates parsing of command line flags
* [`flags_details_ex`](flags_details_ex) - Illustrates command line parsing with a more concrete example
* [`strings_ex`](strings_ex) - Illustrates the `string` API
* [`file_ex`](file_ex) - Illustrates the `file` API
* [`mutex_counter_ex`](mutex_counter_ex) - Shows a way to use the `Mutex` struct for synchronization
* [`wait_group_ex`](wait_group_ex) - Shows a way to use `WaitGroup` struct to wait for sub processes
* [`chan_ex`](chan_ex) - Introduces the `Chan` struct for process communication
* [`binary_trees_ex`](binary_trees_ex) - Demos tree walk using the `Chan` struct
* [`web_server_ex`](web_server_ex) - Illustrates a simple web server implementation
* [`log_ex`](log_ex) - Illustrates log API
* [`text_menu_ex`](text_menu_ex) - Demos text-based menu
* [`text_spinner_ex`](text_spinner_ex) - Demos text-based spinner
* [`text_progress_ex`](text_progress_ex) - Demos text-based progress bar
* [`whiptail_ex`](whiptail_ex) - Demos the approach to use `whiptail` windows/UI
* [`user_ex`](user_ex) - Illustrates API for accessing user info
* [`visitor_ex`](visitor_ex) - Demos the accept / visit pattern
* [`template_ex`](template_ex) - Demos recommended (but not required) workflow

### Playground

Below is the list of examples matching those available in the Go
playground. Note that not each example uses/needs `gobash`.

* [`hellow_world_ex`](/examples/playground/hellow_world_ex)
* [`clear_screen_ex`](/examples/playground/clear_screen_ex)
* [`http_server_ex`](/examples/playground/http_server_ex)
* [`sleep_ex`](/examples/playground/sleep_ex)
* [`test_function_ex`](/examples/playground/test_function_ex)
* [`concurrent_pi_ex`](/examples/playground/concurrent_pi_ex)
* [`ring_do_ex`](/examples/playground/ring_do_ex)
* [`ring_len_ex`](/examples/playground/ring_len_ex)
* [`ring_link_ex`](/examples/playground/ring_link_ex)
* [`ring_move_ex`](/examples/playground/ring_move_ex)
* [`ring_next_ex`](/examples/playground/ring_next_ex)
* [`ring_prev_ex`](/examples/playground/ring_prev_ex)
* [`ring_unlink_ex`](/examples/playground/ring_unlink_ex)

### Rewrites

We wrote a couple of existing scripts using bash with the `gobash`
library. Some are included below.

* [`jattack_ex`](/examples/rewrites/jattack_ex)
* [`flink_data_generator_ex`](/examples/rewrites/flink_data_generator_ex)

### A Tour of Shell Scripting

A tour of shell scripting. These examples do not necessarily use
`gobash`. A few examples are inspired by the sequence in the Go
playground (in which case we provide the link to the original example
inside the file).

* [`welcome`](/examples/tour/welcome_ex)
* [`rand_ex`](/examples/tour/rand_ex)
* [`variables_ex`](/examples/tour/variables_ex)
* [`variables_details_ex`](/examples/tour/variables_details_ex)
* [`func_ex`](/examples/tour/func_ex)
* [`test_cmd_ex`](/examples/tour/test_cmd_ex)
* [`if_ex`](/examples/tour/if_ex)
* [`if_else_ex`](/examples/tour/if_else_ex)
* [`for_ex`](/examples/tour/for_ex)
* [`while_ex`](/examples/tour/while_ex)
* [`until_ex`](/examples/tour/while_ex)
* [`infinite_ex`](/examples/tour/infinite_ex)
* [`loops_funcs_ex`](/examples/tour/loops_funcs_ex)
* [`fact_ex`](/examples/tour/fact_ex)
* [`case_ex`](/examples/tour/case_ex)
* [`case_details_ex`](/examples/tour/case_details_ex)
* [`select_ex`](/examples/tour/case_ex)
* [`select_details_ex`](/examples/tour/case_details_ex)
