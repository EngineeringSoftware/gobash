#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Sync package.

if [ -n "${SYNC_PACKAGE:-}" ]; then return 0; fi
readonly SYNC_PACKAGE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${SYNC_PACKAGE}/mutex.sh
. ${SYNC_PACKAGE}/atomic_int.sh
. ${SYNC_PACKAGE}/chan.sh
. ${SYNC_PACKAGE}/wait_group.sh
