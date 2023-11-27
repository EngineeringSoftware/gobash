#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# UI package.

if [ -n "${UI_PACKAGE:-}" ]; then return 0; fi
readonly UI_PACKAGE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${UI_PACKAGE}/ui.sh
. ${UI_PACKAGE}/whiptail.sh
. ${UI_PACKAGE}/textui.sh
