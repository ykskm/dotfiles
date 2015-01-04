#!/bin/sh

URL_PREFIX=https://github.com/vimpr/vimperator-plugins/raw/master
WGET_OPT="--no-check-certificate"
WGET_LOGFILE="wget_log"

OPT_OVERWRITE=0

proc_script() {
    SCRIPT_NAME=$1
    echo -n "> Update $SCRIPT_NAME ... "

    wget ${WGET_OPT} ${URL_PREFIX}/${SCRIPT_NAME} -o ${WGET_LOGFILE} -O ${SCRIPT_NAME}.tmp
    if [ $? -ne 0 ]; then
        echo ""
        echo "err: failed to get ${URL_PREFIX}/${SCRIPT_NAME}"
        return 1
    fi

    if [ ${OPT_OVERWRITE} -eq 0 ]; then
        mv ${SCRIPT_NAME} ${SCRIPT_NAME}.bak
    fi

    mv ${SCRIPT_NAME}.tmp ${SCRIPT_NAME}
    echo "done"
    return 0
}

while getopts "f" flag; do
    case $flag in
        f) OPT_OVERWRITE=1;;
    esac
done

shift $(($OPTIND - 1))

for script in $@
do
    proc_script $script
done

