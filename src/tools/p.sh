#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Tools package.

if [ -n "${TOOLS_PACKAGE:-}" ]; then return 0; fi
readonly TOOLS_PACKAGE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${TOOLS_PACKAGE}/blint.sh
. ${TOOLS_PACKAGE}/bdoc.sh
