#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Lang package.

if [ -n "${LANG_PACKAGE:-}" ]; then return 0; fi
readonly LANG_PACKAGE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${LANG_PACKAGE}/core.sh
. ${LANG_PACKAGE}/unsafe.sh
. ${LANG_PACKAGE}/os.sh
. ${LANG_PACKAGE}/sys.sh
. ${LANG_PACKAGE}/make.sh
. ${LANG_PACKAGE}/log.sh
. ${LANG_PACKAGE}/result.sh
. ${LANG_PACKAGE}/pipe.sh
. ${LANG_PACKAGE}/bash.sh

. ${LANG_PACKAGE}/bool.sh
. ${LANG_PACKAGE}/int.sh

. ${LANG_PACKAGE}/assert.sh
