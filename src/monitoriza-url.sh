#!/bin/bash
logger "starting monitor $1"
eval source "$HOME/monitoriza-url.env"
URL=$1
URL=$(systemd-escape -u "$URL")
STATUS="-"
while true
do
    ans=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
    echo $ans
    if [ "$ans" = "200" ] && [ "$STATUS" != "OK" ]
    then
        STATUS="OK"
        MESSAGE="Se ha recuperado la connectividad con ${URL}"
        TELEGRAM_URL=https://api.telegram.org/bot${TOKEN}/sendMessage
        logger "Status: ${ans} => ${MESSAGE}"
        curl -s -X POST ${TELEGRAM_URL} -d chat_id=${CHAT_ID} -d text="${MESSAGE}"
    elif [ "$ans" != "200" ] && [ "$STATUS" != "KO" ]
    then
        STATUS="KO"
        MESSAGE="Se ha perdido la connectividad con ${URL}"
        TELEGRAM_URL=https://api.telegram.org/bot${TOKEN}/sendMessage
        logger "Status: ${ans} => ${MESSAGE}"
        curl -s -X POST ${TELEGRAM_URL} -d chat_id=${CHAT_ID} -d text="${MESSAGE}"
    fi
    sleep $TIMELAPSE
done
