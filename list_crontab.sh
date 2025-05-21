#!/bin/sh

echo

for i in $(cat /etc/passwd | cut -d : -f 1)
do

        crontab -u $i -l 2> /dev/null

        if [ $? -eq 0 ]
        then
                echo "Crontab di $i"
                echo
        fi


done
