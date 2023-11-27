#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Database package.

if [ -n "${DATABASE_PACKAGE:-}" ]; then return 0; fi
readonly DATABASE_PACKAGE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${DATABASE_PACKAGE}/sql.sh
