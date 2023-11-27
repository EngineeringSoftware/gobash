#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Testing package.

if [ -n "${TESTING_PACKAGE:-}" ]; then return 0; fi
readonly TESTING_PACKAGE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${TESTING_PACKAGE}/bunit.sh
. ${TESTING_PACKAGE}/testt.sh
