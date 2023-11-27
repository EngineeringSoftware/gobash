#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Net package.

if [ -n "${NET_PACKAGE:-}" ]; then return 0; fi
readonly NET_PACKAGE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${NET_PACKAGE}/http.sh
. ${NET_PACKAGE}/request.sh
. ${NET_PACKAGE}/response.sh
