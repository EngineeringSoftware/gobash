#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# UI Text support (e.g., text menus).

if [ -n "${TEXTUI_MOD:-}" ]; then return 0; fi
readonly TEXTUI_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${TEXTUI_MOD}/../lang/p.sh
. ${TEXTUI_MOD}/../util/p.sh
. ${TEXTUI_MOD}/ui.sh


# ----------
# Functions.

function textui_enabled() {
        # Return true if this module is enabled.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        ! is_exe $ctx "local" && return $FALSE
        ! is_exe $ctx "shift" && return $FALSE
        ! is_exe $ctx "echo" && return $FALSE
        ! is_exe $ctx "read" && return $FALSE
        ! is_exe $ctx "sleep" && return $FALSE
        ! is_exe $ctx "wait" && return $FALSE
        ! is_exe $ctx "disown" && return $FALSE

        return 0
}

function TextMenu() {
        # Text-based menu.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r text="${1}"
        local -r lst="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "_text" "${text}" \
              "_lst" "${lst}"
}

function TextMenu_show() {
        # Show the menu and return selected value.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r tm="${1}"
        local -r res="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local lst=$($tm $ctx _lst)
        local -i len=$($lst $ctx len)

        local -i i
        echo "$($tm $ctx _text)"
        for (( i=0; i<${len}; i++ )); do
                local el=$($lst $ctx get "${i}")
                echo "${i}. ${el}"
        done

        local ix
        read -s ix || return $EC
        [ ${ix} -lt 0 -o ${ix} -ge ${len} ] && return $EC

        $res $ctx _val "$($lst get ${ix})"
}

function TextSpinner() {
        # Text-based spinner.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "ix" "0" \
              "pid" "${NULL}"
}

function TextSpinner_start() {
        # Start spinning at regular intervals (should be stopped by
        # invoking stop).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r ts="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local chars=( "|" "/" "-" "\\" "|" "/" "-" "\\" )
        ( while :; do
                  local c
                  for c in ${chars[@]}; do
                          printf "\r${c}"
                          sleep 0.1
                  done
          done
        ) &
        $ts $ctx pid $!
}

function TextSpinner_stop() {
        # Stop spinning.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r ts="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r pid=$($ts $ctx pid)
        printf "\r"
        disown "${pid}"
        os_kill $ctx "${pid}"
        wait "${pid}"
}

function TextProgress() {
        # Text-based progress bar.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        local -r max="${1:-100}"
        shift 0 || { ctx_wn $ctx; return $EC; }

        [ -z "${max}" ] && { ctx_w $ctx "no max"; return $EC; }
        [ ${max} -le 0 ] && { ctx_w $ctx "incorrect max"; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "val" "0" \
              "max" "${max}" \
              "pid" "${NULL}"
}

function TextProgress_print() {
        # Start the progress bar (in background).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r bar="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local width=30
        local p
        local w

        p=$(math_n_percent_n $ctx "$($bar val)" "$($bar max)")
        p=$(math_floor $ctx "${p}")
        w=$(math_percent_of $ctx "${p}" "${width}" )
        w=$(math_floor $ctx "${w}")
        printf "\r$(strings_repeat $ctx '#' ${w})$(strings_repeat $ctx ' ' $(( ${width} - ${w} ))) (${p}%%)"
}

function TextProgress_start() {
        # Start the progress bar (in background).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r bar="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        ( while :; do
                  TextProgress_print $ctx "$bar"
          done
        ) &
        $bar $ctx pid $!
}

function TextProgress_stop() {
        # Stop the progress bar. If already stopped, do nothing.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r bar="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r pid=$($bar $ctx pid)
        disown "${pid}"
        os_kill $ctx "${pid}" 2>/dev/null
        wait "${pid}"

        TextProgress_print $ctx "$bar"
        printf "\n"
}

function TextProgress_set() {
        # Set the new value.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r bar="${1}"
        local -r nval="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -r val=$($bar val)
        local -r max=$($bar max)

        [ -z "${nval}" ] && { ctx_w $ctx "no val"; return $EC; }
        [ ${nval} -lt ${val} -o ${nval} -gt ${max} ] && \
                { ctx_w $ctx "incorrect val"; return $EC; }

        # Set new value.
        $bar $ctx val "${nval}"

        # Code below could be used if we do not want to go async.
        # local -r width=30
        # local p=$(math_n_percent_n $ctx "${nval}" "${max}")
        # p=$(math_floor $ctx "${p}")

        # local w=$(math_percent_of $ctx "${p}" "${width}" )
        # w=$(math_floor $ctx "${w}")

        # printf "\r$(strings_repeat $ctx '#' ${w})$(strings_repeat $ctx ' ' $(( ${width} - ${w} ))) (${p}%%)"
        # [ ${p} -eq 100 ] && printf "\n"
}

function TextProgress_inc() {
        # Increment value by 1.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r bar="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local val=$($bar $ctx val)
        val=$(( ${val} + 1 ))
        TextProgress_set $ctx "${bar}" "${val}"
}
