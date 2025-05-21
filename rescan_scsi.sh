#!/bin/bash

echo "Rescan scsi bus withuot reboot"

rescan-scsi-bus.sh -a ; ERROR_SCAN=$?

if [ $ERROR_SCAN -eq 127 ]
then
	for i in $(ls /sys/class/scsi_host)
	do

        echo "Eseguo lo scan di $i"
        echo "- - -" > /sys/class/scsi_host/$i/scan

	done
fi

for i in $(ls /sys/class/scsi_device/)
do

		echo "Eseguo lo scan di $i"
		echo 1 > /sys/class/scsi_device/$i/device/rescan

done

exit 0
