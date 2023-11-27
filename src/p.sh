#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Root package.

if [ -n "${SRC_PACKAGE:-}" ]; then return 0; fi
readonly SRC_PACKAGE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Language.
. ${SRC_PACKAGE}/lang/p.sh

# API.
. ${SRC_PACKAGE}/util/p.sh
. ${SRC_PACKAGE}/ui/p.sh
. ${SRC_PACKAGE}/net/p.sh
. ${SRC_PACKAGE}/sync/p.sh
. ${SRC_PACKAGE}/container/p.sh

# Testing.
. ${SRC_PACKAGE}/testing/p.sh

# Tools.
. ${SRC_PACKAGE}/tools/p.sh

# Database.
. ${SRC_PACKAGE}/database/p.sh
