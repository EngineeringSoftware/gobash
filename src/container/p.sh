#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Container package.

if [ -n "${CONTAINER_PACKAGE:-}" ]; then return 0; fi
readonly CONTAINER_PACKAGE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${CONTAINER_PACKAGE}/ring.sh
