#!/bin/bash

LOGPATH="$1" 

pushd "${LOGPATH}" || exit 1 > /dev/null

for FILENAME in $(find syslog* | sort -V -r) ; do
    
    [[ -e "$FILENAME" ]] || break

    FIRSTMONTH=$(awk 'NR==1 {print $1; exit}' "${FILENAME}")
    FIRSTDAY=$(awk 'NR==1 {print $2; exit}' "${FILENAME}")

    LASTMONTH=$(tail -n 1 "${FILENAME}" | awk '{print $1}')
    LASTDAY=$(tail -n 1 "${FILENAME}" | awk '{print $2}')

    if [ "${FIRSTMONTH}" == "${LASTMONTH}" ]; then
        for NUM in $(seq "${FIRSTDAY}" "${LASTDAY}"); do
            if [ "${NUM}" -lt 10 ] ; then 
                grep "${FIRSTMONTH}  ${NUM}" "${FILENAME}" >> "${LOGPATH}${FIRSTMONTH}-${NUM}.log"
            else
                grep "${FIRSTMONTH} ${NUM}" "${FILENAME}" >> "${LOGPATH}${FIRSTMONTH}-${NUM}.log"
            fi
        done
    else
        for EOM_NUM in $(seq "${FIRSTDAY}" 31); do
            if [ "${EOM_NUM}" -lt 10 ] ; then 
                grep "${FIRSTMONTH}  ${EOM_NUM}" "${FILENAME}" >> "${LOGPATH}${FIRSTMONTH}-${EOM_NUM}.log"
            else
                grep "${FIRSTMONTH} ${EOM_NUM}" "${FILENAME}" >> "${LOGPATH}${FIRSTMONTH}-${EOM_NUM}.log"
            fi
        done
        for BOM_NUM in $(seq 1 "${LASTDAY}"); do
            if [ "${BOM_NUM}" -lt 10 ] ; then
                grep "${LASTMONTH}  ${BOM_NUM}" "${FILENAME}" >> "${LOGPATH}${LASTMONTH}-${BOM_NUM}.log"
            else
                grep "${LASTMONTH} ${BOM_NUM}" "${FILENAME}" >> "${LOGPATH}${LASTMONTH}-${BOM_NUM}.log"
            fi
        done
    fi
done

for EMPTYFILE in $(find . -type f -empty); do
    rm "${EMPTYFILE}"
done

exit 0