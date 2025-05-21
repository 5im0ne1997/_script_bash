#!/bin/bash

if [ $UID -ne 0 ]
then
        echo "Esegui il comando con sudo o come root"
        exit 1
fi

ALL_VNC_SESSION=( $(cat /etc/tigervnc/vncserver.users | grep -v -e '^#' -e '^$') )

echo "Quale sesione vuoi riavviare?"
N=0
for SESSION in ${ALL_VNC_SESSION[@]}
do
        USERNAME=$(echo $SESSION | cut -d'=' -f 2)
        ID=$(echo $SESSION | cut -d'=' -f 1)
        echo "  ${ID:1}) $USERNAME"
done

read -p "Inserisci il numero >> " ID

systemctl restart vncserver@:$ID.service
sleep 1                                                                                                                                                                                                                                                 
systemctl status vncserver@:$ID.service

exit 0
