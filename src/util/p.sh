#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Util package.

if [ -n "${UTIL_PACKAGE:-}" ]; then return 0; fi
readonly UTIL_PACKAGE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${UTIL_PACKAGE}/file.sh
. ${UTIL_PACKAGE}/filepath.sh
. ${UTIL_PACKAGE}/os.sh
. ${UTIL_PACKAGE}/time.sh
. ${UTIL_PACKAGE}/math.sh
. ${UTIL_PACKAGE}/rand.sh
. ${UTIL_PACKAGE}/strings.sh
. ${UTIL_PACKAGE}/regexp.sh
. ${UTIL_PACKAGE}/flags.sh
. ${UTIL_PACKAGE}/complex.sh
. ${UTIL_PACKAGE}/user.sh
. ${UTIL_PACKAGE}/pair.sh