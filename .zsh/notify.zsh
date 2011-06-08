local CURRENT_COMMAND="dummy"
local CURRENT_COMMAND_START_TIME=0
function notify_precmd {
    if [ "$CURRENT_COMMAND" != "dummy" ] ; then
        local d=`date +%s`
        d=`expr $d - ${CURRENT_COMMAND_START_TIME}`
        if [ "$d" -ge "5" ] ; then
            notify-send "process done" "${CURRENT_COMMAND}"
        fi
        CURRENT_COMMAND="dummy"
        CURRENT_COMMAND_START_TIME=0
    fi
}

function notify_preexec {
    CURRENT_COMMAND="${1}"
    CURRENT_COMMAND_START_TIME=`date +%s`
}

precmd_functions=($precmd_functions notify_precmd)
preexec_functions=($preexec_functions notify_preexec)

