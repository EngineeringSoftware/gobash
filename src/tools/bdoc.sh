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
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r pathf="${1}"
        local -r name="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -r brief=$(head -n 5 "${pathf}" | \
                                 tail -n 1 | \
                                 $X_SED 's/.*#\(.*\)/\1/g')

        cat << END
/**
 * @file ${name}.h
 * @brief${brief}
 */

END
}

function bdoc_main() {
        # Generate documentation for a directory using doxygen.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local -r d=$(os_mktemp_dir)
        echo ${d}
        for f in $(find "$(sys_repo_path)" -name "*.sh" | grep -v '_test.sh'); do
                local name=$(basename "${f}" .sh)
                _bdoc_file "${f}" "${name}" > "${d}/${name}.h"
        done

        cp "${BDOC_MOD}/../../README.md" "${d}"
        ( cd "${d}"
          # Generate a template config file.
          doxygen -g

          # Set project name.
          $X_SED -i 's/PROJECT_NAME.*=.*/PROJECT_NAME = "gobash"/g' Doxyfile

          # Include README file.
          # $X_SED -i 's/USE_MDFILE_AS_MAINPAGE =.*/INPUT += README.md\nUSE_MDFILE_AS_MAINPAGE = README.md/g' Doxyfile

          # Do not generate latex.
          $X_SED -i 's/GENERATE_LATEX.*= YES/GENERATE_LATEX = NO/g' Doxyfile

          # Generate doc.
          doxygen )
}
