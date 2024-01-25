#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Document generation tool.

if [ -n "${BDOC_MOD:-}" ]; then return 0; fi
readonly BDOC_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${BDOC_MOD}/../lang/p.sh
. ${BDOC_MOD}/../util/p.sh


# ----------
# Functions.

function bdoc_enabled() {
        # Check if this module is enabled.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        ! is_exe $ctx "doxygen" && return $FALSE

        return $TRUE
}

function _bdoc_file() {
        # Generate doc for a single file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r pathf="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local brief=$(head -n 5 "${pathf}" | \
                              tail -n 1 | \
                              $X_SED 's/.*#\(.*\)/\1/g')
        brief=$(strings_strip "${brief}")

        local path=${pathf#"$(sys_repo_path)/src/"*}
        local n=$(strings_len "${path}")
        local assigns=$(strings_repeat "=" "${n}")

        cat << END
${path}
${assigns}

${brief}

END

        local fun
        for fun in $(sys_functions_in_file "${pathf}"); do
                [[ "${fun}" = "_"* ]] && continue
                echo ".. py:function:: ${fun}"
                echo
                echo $(sys_function_doc "${pathf}" "${fun}")
                echo
                # TODO: add return and types.
                #:return: ...
                #:rtype: ...
        done
}

function bdoc_main() {
        # Generate documentation for gobash in the Sphinx format.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local -r docd="$(sys_repo_path)/doc"
        [ ! -d "${docd}" ] && \
                { ctx_w $ctx "doc dir does not exist"; return $EC; }

        local apid
        apid=$(os_remake_dir "${docd}/apis") || return $EC

        local content=""
        local f
        # TODO: pick files from flags.
        for f in $(find "$(sys_repo_path)/src" -name "*.sh" | grep -v '_test.sh'); do
                local package_file=${f#"$(sys_repo_path)/src/"*}
                local package="${package_file%/*}"
                local file=$(echo "${package_file}" | awk -F"/" '{print $NF}')
                [ "${file}" = "p.sh" ] && continue

                local name=$(basename "${file}" .sh)
                local rstf="${package//\//_}_${name}.rst"

                _bdoc_file "${f}" > "${apid}/${rstf}" || return $EC
                content+=$'\n'"   apis/${rstf}"
        done

        # Make api.rst file.
        cat << END > "${docd}/api.rst"
API
===

.. toctree::
   :maxdepth: 2
   :caption: Packages:

   ${content}

END
}
