#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# whiptail API support.

if [ -n "${WHIPTAIL_MOD:-}" ]; then return 0; fi
readonly WHIPTAIL_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${WHIPTAIL_MOD}/../lang/p.sh
. ${WHIPTAIL_MOD}/../util/p.sh
. ${WHIPTAIL_MOD}/ui.sh

readonly WHIPTAIL_HEIGHT=20
readonly WHIPTAIL_WIDTH=50


# ----------
# Functions.

function whiptail_doc() {
        # Module doc.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        cat << END
whiptail wrapper API. Convenient way to work with simple
boxes (info box, input box, checklist, radiolist).
END
}

function whiptail_enabled() {
        # Check if this module is enabled.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        ! is_exe $ctx "whiptail" && \
                { ctx_w $ctx "no whiptail"; return $FALSE; }

        return $TRUE
}

function WTMsgBox() {
        # whiptail message box.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r text="${1}"
        local -r height="${2:-$WHIPTAIL_HEIGHT}"
        local -r width="${3:-$WHIPTAIL_WIDTH}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${text}" ] && { ctx_w $ctx "no text"; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "_text" "${text}" \
              "_height" "${height}" \
              "_width" "${width}"
}

function WTMsgBox_show() {
        # Show the box.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r box="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        whiptail --msgbox \
                 "$($box $ctx _text)" \
                 "$($box $ctx _height)" \
                 "$($box $ctx _width)"
        # No other result to return.
}

function WTInputBox() {
        # whiptail input box.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        local -r text="${1:-Unknown}"
        local -r init="${2:-""}"
        local -r height="${3:-$WHIPTAIL_HEIGHT}"
        local -r width="${4:-$WHIPTAIL_WIDTH}"
        shift 0 || { ctx_wn $ctx; return $EC; }

        [ -z "${text}" ] && { ctx_w $ctx "no text"; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "_text" "${text}" \
              "_init" "${init}" \
              "_height" "${height}" \
              "_width" "${width}"
}

function WTInputBox_show() {
        # Show the box and store the input into the result.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r box="${1}"
        local -r res="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local tmpf=$(os_mktemp_file $ctx)
        exec 3> "${tmpf}"

        local ec=0
        whiptail --inputbox \
                 "$($box _text)" \
                 "$($box _height)" \
                 "$($box _width)" \
                 "$($box _init)" \
                 --output-fd 3 || ec=$?

        # Close fd.
        exec 3>&-

        if [ ${ec} -eq 1 ]; then
                $res $ctx _cancelled $TRUE
        elif [ ${ec} -eq 0 ]; then
                $res $ctx _val "$(cat ${tmpf})"
        fi

        return ${ec}
}

function WTMenu() {
        # whiptail menu.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 2 ] && { ctx_wn $ctx; return $EC; }
        local -r text="${1}"
        local -r lst="${2}"
        local -r height="${3:-$WHIPTAIL_HEIGHT}"
        local -r width="${4:-$WHIPTAIL_WIDTH}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${text}" ] && { ctx_w $ctx "no text"; return $EC; }
        ! is_instanceof $ctx "$lst" List && \
                { ctx_w $ctx "incorrect lst"; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "_text" "${text}" \
              "_lst" "${lst}" \
              "_height" "${height}" \
              "_width" "${width}"
}

function WTMenu_show() {
        # Show the box and store selected option into the result.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r box="${1}"
        local -r res="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local lst=$($box _lst)

        local items=()

        local -i i
        for (( i=0; i<$($lst $ctx len); i++ )); do
                local el=$($lst $ctx get "${i}")
                items+=( "${i}." )
                items+=( "${el}" )
        done

        local tmpf=$(os_mktemp_file $ctx)
        exec 3> "${tmpf}"

        local ec=0
        whiptail --menu \
                 "$($box _text)" \
                 "$($box _height)" \
                 "$($box _width)" \
                 "$($lst len)" \
                 "${items[@]}" \
                 --output-fd 3 || ec=$?

        # Close fd.
        exec 3>&-

        if [ ${ec} -eq 1 ]; then
                $res $ctx _cancelled $TRUE
        elif [ ${ec} -eq 0 ]; then
                local ix=$(cat ${tmpf} | $X_SED 's/\.//g')
                $res $ctx _val "$($lst $ctx get ${ix})"
        fi

        return ${ec}
}

function WTChecklist() {
        # whiptail checklist.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 2 ] && { ctx_wn $ctx; return $EC; }
        local -r text="${1}"
        local -r lst="${2}"
        local -r height="${3:-$WHIPTAIL_HEIGHT}"
        local -r width="${4:-$WHIPTAIL_WIDTH}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${text}" ] && { ctx_w $ctx "no text"; return $EC; }
        ! is_instanceof $ctx "$lst" List && \
                { ctx_w $ctx "incorrect lst"; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "_text" "${text}" \
              "_lst" "${lst}" \
              "_height" "${height}" \
              "_width" "${width}"
}

function WTChecklist_show() {
        # Show the box and store the checked value into the result.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r box="${1}"
        local -r res="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local lst=$($box $ctx _lst)

        local items=()

        local i
        for (( i=0; i<$($lst len); i++ )); do
                local el=$($lst $ctx get ${i})
                items+=( "${i}." )
                items+=( "${el}" )
                items+=( "off" )
        done

        local tmpf=$(os_mktemp_file $ctx)
        exec 3> "${tmpf}"

        local ec=0
        whiptail --checklist \
                 "$($box _text)" \
                 "$($box _height)" \
                 "$($box _width)" \
                 "$($lst len)" \
                 "${items[@]}" \
                 --output-fd 3 || ec=$?

        # Close fd.
        exec 3>&-

        if [ ${ec} -eq 1 ]; then
                $res $ctx _cancelled $TRUE
        elif [ ${ec} -eq 0 ]; then
                local nlst=$(List)
                $res $ctx _val "$nlst"
                local ix
                for ix in $(cat "${tmpf}" | $X_SED 's/\.//g' | $X_SED 's/"//g'); do
                        $nlst $ctx add "$($lst $ctx get ${ix})"
                done
        fi

        return ${ec}
}

function WTRadiolist() {
        # whiptail radiolist.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 2 ] && { ctx_wn $ctx; return $EC; }
        local -r text="${1}"
        local -r lst="${2}"
        local -r height="${3:-$WHIPTAIL_HEIGHT}"
        local -r width="${4:-$WHIPTAIL_WIDTH}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${text}" ] && { ctx_w $ctx "no text"; return $EC; }
        ! is_instanceof $ctx "${lst}" List && \
                { ctx_w $ctx "incorrect lst"; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "_text" "${text}" \
              "_lst" "${lst}" \
              "_height" "${height}" \
              "_width" "${width}"
}

function WTRadiolist_show() {
        # Show the box store the selected option into the result.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r box="${1}"
        local -r res="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local lst=$($box $ctx _lst)

        local items=()

        local i
        for (( i=0; i<$($lst $ctx len); i++ )); do
                local el=$($lst $ctx get ${i})
                items+=( "${i}." )
                items+=( "${el}" )
                if [ ${i} -eq 0 ]; then
                        items+=( "on" )
                else
                        items+=( "off" )
                fi
        done

        local tmpf=$(os_mktemp_file $ctx)
        exec 3> "${tmpf}"

        local ec=0
        whiptail --radiolist \
                 "$($box _text)" \
                 "$($box _height)" \
                 "$($box _width)" \
                 "$($lst len)" \
                 "${items[@]}" \
                 --output-fd 3 || ec=$?

        # Close fd.
        exec 3>&-

        if [ ${ec} -eq 1 ]; then
                $res $ctx _cancelled $TRUE
        elif [ ${ec} -eq 0 ]; then
                local ix=$(cat ${tmpf} | $X_SED 's/\.//g')
                $res $ctx _val "$($lst $ctx get ${ix})"
        fi

        return ${ec}
}
