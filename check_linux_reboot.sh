#!/bin/bash

AUTH=$(echo -ne "<username>:<password>" | base64 --wrap 0)

session_id=$(curl -s -k --request POST https://<URL VCenter>/api/session --header "Authorization: Basic $AUTH"|sed "s@\"@@g")

list_tags=( $(curl -s -k --request GET 'https://<URL VCenter>/rest/com/vmware/cis/tagging/tag' \
			-H "vmware-api-session-id:$session_id" | jq ".value[]") )

for i in ${list_tags[@]}
do
	i=$(echo $i|sed "s@\"@@g")
	if [ $(curl -s -k --request GET https://<URL VCenter>/rest/com/vmware/cis/tagging/tag/id:$i \
			-H "vmware-api-session-id:$session_id"| jq ".value.name"|sed "s@\"@@g") == "linux" ]
	then
		tag_id=$i
		break
	fi
done

vm_name=( $(curl -s -k --request POST https://<URL VCenter>/api/cis/tagging/tag-association/$tag_id?action=list-attached-objects \
	-H "vmware-api-session-id:$session_id" | jq ".[].id" |sed "s@\"@@g") )

LIST_REMOTE_HOSTS=( $(for i in ${vm_name[@]}
do
	curl -s -k --request GET https://<URL VCenter>/api/vcenter/vm/$i \
		-H "vmware-api-session-id:$session_id" | jq ".name"|sed "s@\"@@g"
done) )

curl -s -k --request DELETE https://<URL VCenter>/api/session \
                        -H "vmware-api-session-id:$session_id"

NEED_REBOOT=()

REMOTE_USER="<ssh user>"
for REMOTE_HOST in ${LIST_REMOTE_HOSTS[@]}
do

	if [ $(ssh -o StrictHostKeyChecking=accept-new $REMOTE_USER@$REMOTE_HOST -C 'cat /etc/os-release|grep -i "red hat" | wc -l') -ge 1 ]
	then
		if [ $(ssh -o StrictHostKeyChecking=accept-new $REMOTE_USER@$REMOTE_HOST -C 'sudo needs-restarting -r &>/dev/null ; echo $?') -eq 1 ]
		then
			NEED_REBOOT+=($REMOTE_HOST)
		fi	
	else
		if [ $(ssh -o StrictHostKeyChecking=accept-new $REMOTE_USER@$REMOTE_HOST -C 'ls /var/run/reboot-required &>/dev/null; echo $?') -eq 0 ]
		then
			NEED_REBOOT+=($REMOTE_HOST)
		fi
	fi
done

echo "${NEED_REBOOT[@]}" | sed 's/ /\n/g'| mail -s "Linux Need reboot" <mailbox>
