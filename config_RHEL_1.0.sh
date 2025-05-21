#!/bin/bash

#Imposta hostname al server, case 1 menu principale
function sethostname {

SETH_TITLE="Configurazione Hostname"

var_hostname=$(whiptail --inputbox "Inserisci nuovo hostname:" 10 40 --title "$SETH_TITLE" $(hostname) 3>&1 1>&2 2>&3)

if [ $? -eq 0 ]
then
	var_hostname=$(echo $var_hostname | xargs | sed 's/ /-/g')
	if [ ${#var_hostname} -ne 0 ]
	then
		hostnamectl set-hostname $var_hostname
		whiptail --title "$SETH_TITLE" --msgbox "L'hostname impostato è: $(hostname)" 10 40
	else
		whiptail --title "$SETH_TITLE" --msgbox "Non è possibile lasciare il campo vuoto" 10 40
	fi
fi
return
}

#Imposta l'IP del server, case 1 function setup_network
function setup_network_ip {

IP=$(whiptail --inputbox "Inserisci l'IP" 8 40 --title "$SETN_TITLE" $IP 3>&1 1>&2 2>&3)
if [ $? -eq 0 ]
then
	IP=$(echo $IP | xargs)
	if [ $(expr "$IP" : '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$' >/dev/null ; echo $?) -eq 0 ]
	then
	OK=1
		for i in 1 2 3 4
		do
			if [ $(echo $IP | cut -d. -f$i) -gt 254 ]
			then
				OK=0
				break
			fi
		done
	else
		OK=0
	fi
	if [ $OK -eq 0 ]
	then
		whiptail --title "$SETN_TITLE" --msgbox "$(echo "IP $IP non valido" | xargs)" 10 40
		unset IP
	else
		whiptail --title "$SETN_TITLE" --msgbox "IP impostato correttamente" 10 40
	fi
fi
unset OK
return
}

#Imposta la subnet del server, case 2 function setup_network
function setup_network_subnet {

if [ ${#SN} -eq 0 ]
then
	SN=24
fi
SN=$(whiptail --inputbox "Inserisci la Subnet (default 24)" 8 40 --title "$SETN_TITLE" $SN 3>&1 1>&2 2>&3)
if [ $? -eq 0 ]
then
	SN=$(echo $SN | xargs)
	if [ $(expr "$SN" : '[0-9]*$' >/dev/null ; echo $?) -ne 0 ] || [ $SN -gt 32 ]
	then
		whiptail --title "$SETN_TITLE" --msgbox "$(echo "Subnet $SN non valida" | xargs)" 10 40
		unset SN
	else
		whiptail --title "$SETN_TITLE" --msgbox "Subnet impostata correttamente" 10 40
	fi
fi
return
}

#Imposta il gateway del server, case 3 function setup_network
function setup_network_gateway {

GW=$(whiptail --inputbox "Inserisci il Gateway" 8 40 --title "$SETN_TITLE" $GW 3>&1 1>&2 2>&3)
if [ $? -eq 0 ]
then
	GW=$(echo $GW | xargs)
	if [ $(expr "$GW" : '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$' >/dev/null ; echo $?) -eq 0 ]
	then
	OK=1
		for i in 1 2 3 4
		do
			if [ $(echo $GW | cut -d. -f$i) -gt 254 ]
			then
				OK=0
				break
			fi
		done
	else
		OK=0
	fi
	if [ $OK -eq 0 ]
	then
		whiptail --title "$SETN_TITLE" --msgbox "$(echo "Gateway $GW non valido" | xargs)" 10 40
		unset GW
	else
		whiptail --title "$SETN_TITLE" --msgbox "Gateway impostato correttamente" 10 40
		fi
fi
unset OK
return
}

#Imposta il DNS del server, case 4 function setup_network
function setup_network_dns {

DNS=$(whiptail --inputbox "Inserisci il/i DNS (se più di uno separare con la virgola \",\")" 8 40 --title "$SETN_TITLE" $DNS 3>&1 1>&2 2>&3)
if [ $? -eq 0 ]
then
	DNS_=( $(echo $DNS | xargs | sed 's/,/ /g') )
	for ii in ${DNS_[@]}
	do
		if [ $(expr "$ii" : '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$' >/dev/null ; echo $?) -eq 0 ]
		then
		OK=1
			for i in 1 2 3 4
			do
				if [ $(echo $ii | cut -d. -f$i) -gt 254 ]
				then
					OK=0
					break 2
				fi
			done
		else
			OK=0
			break
		fi
	done
	if [ $OK -eq 0 ]
	then
		whiptail --title "$SETN_TITLE" --msgbox "$(echo "DNS $ii non valido" | xargs)" 10 40
		unset DNS
	else
		DNS=( $(echo ${DNS_[@]} | sed 's/ /,/g') )
		whiptail --title "$SETN_TITLE" --msgbox "DNS impostato correttamente" 10 40
	fi
fi
unset OK
return
}

#Controlla e modifica scheda di rete, case 5 function setup_network
function setup_network_all {

if (whiptail --title "$SETN_TITLE" --yesno "I parametri da impostare sono:\n\nIP: $IP\nSubnet: $SN\nGateway: $GW\nDNS: $DNS\n\nConfermi?" 20 50)
then
	if [ ${#IP} -ne 0 ] && [ ${#SN} -ne 0 ] && [ ${#GW} -ne 0 ] && [ ${#DNS} -ne 0 ]
	then
		
#		sleep 2
#		if (whiptail --title "$SETN_TITLE" --yesno "Verrà impostata la scheda di rete $NOMEDEVICE con i seguenti parametri:\n\nIP: $IP\nSubnet: $SN\nGateway: $GW\nDNS: $DNS\n\nConfermi?" 20 50)
#		then
			if [ $CONNECTED -eq 0 ]
			then
				nmcli connection add ifname $NOMEDEVICE type ethernet con-name $NOMECONN &>/dev/null
			fi
			nmcli connection modify $NOMECONN IPv4.method manual IPv4.address $IP/$SN IPv4.gateway $GW IPv4.dns $DNS connection.autoconnect yes &>/dev/null
			nmcli connection down $NOMECONN &>/dev/null
			nmcli connection up $NOMECONN &>/dev/null
			whiptail --title "$SETN_TITLE" --msgbox "Connessione configurata correttamente" 10 40
#		fi
	else
		whiptail --title "$SETN_TITLE" --msgbox "Mancano dei parametri" 10 40
	fi
fi
return
}

#Menu di configurazione della network, case 2 menu principale
function setup_network {

SETN_TITLE="Configurazione Network"

while :
do
#	DEVICE=$(whiptail --inputbox "Quale scheda di rete vuoi configurare?\n\n$(nmcli device status|grep -v loopback)" 15 50 --title "$SETN_TITLE" 3>&1 1>&2 2>&3)

	DEVICE=( $(nmcli -g device,state,connection device status | grep -v lo) )
	
	count=0
	netconfig_menu=( --title "$SETN_TITLE" --radiolist "Quale scheda di rete vuoi configurare?" 15 42 ${#DEVICE[@]} )
	for i in "${DEVICE[@]}"
	do
		netconfig_menu+=( "$count: $(echo $i | cut -d: -f1)" "$(echo $i | cut -d: -f2)" )
		((count++))
		if [ "${DEVICE[0]}" = "$i" ]
		then
			netconfig_menu+=( "on" )
		else
			netconfig_menu+=( "off" )
		fi
	done
	
	unset IP SN GW DNS
	NOMEDEVICE=$(whiptail "${netconfig_menu[@]}" 3>&1 1>&2 2>&3)
	if [ $? -eq 0 ]
	then
		NOMECONN=$(echo ${DEVICE[$(echo $NOMEDEVICE| cut -d: -f1 | xargs)]} | cut -d: -f3)
		NOMEDEVICE=$(echo $NOMEDEVICE| cut -d: -f2 | xargs)
		if [ ${#NOMECONN} -eq 0 ]
		then
			CONNECTED=0
			NOMECONN=$NOMEDEVICE
#		else
#			CONNECTED=1
		fi
		while :
		do
			CHOICEIP=$(whiptail --title "$SETN_TITLE" --menu "Parametri Network scheda $NOMEDEVICE" 15 40 5\
	"1)" "Cambia l'indirizzo IP"\
	"2)" "Cambia la subnet"\
	"3)" "Cambia il gateway"\
	"4)" "Cambia il/i DNS"\
	"5)" "Configura scheda di rete" 3>&1 1>&2 2>&3)
				
			if [ $? -eq 1 ]
			then
				break
			fi
			
			case $CHOICEIP in
			
			"1)") 
				setup_network_ip
			;;
			
			"2)")
				setup_network_subnet
			;;
			
			"3)")
				setup_network_gateway
			;;
			
			"4)")
				setup_network_dns
			;;
			
			"5)")
				setup_network_all
			;;
			
			esac
		done
	else
		return
	fi
done
}

#Imposta email registrazione su sito red hat, case 1 function yum_register
function yum_register_email {

EMAIL=$(whiptail --title "$REGYUM_TITLE" --inputbox "Inserisci la email:" 8 40 $EMAIL 3>&1 1>&2 2>&3)

if [ $? -eq 0 ]
then
	EMAIL=$(echo $EMAIL | xargs)
	if [ ${#EMAIL} -eq 0 ]
	then
		whiptail --title "$REGYUM_TITLE" --msgbox "Inserisci la email" 8 40
	else
		whiptail --title "$REGYUM_TITLE" --msgbox "Email impostata correttamente" 8 40
	fi
fi
return
}

#Imposta password registrazione su sito red hat, case 2 function yum_register
function yum_register_password {

OK=2
PASS=$(whiptail --title "$REGYUM_TITLE" --passwordbox "Inserisci la password:" 8 40 3>&1 1>&2 2>&3)

if [ $? -eq 0 ]
then
	PASS=$(echo $PASS | xargs)
	if [ ${#PASS} -eq 0 ]
	then
		OK=0
	else
		PASS_=$(whiptail --title "$REGYUM_TITLE" --passwordbox "Re-Inserisci la password:" 8 40 3>&1 1>&2 2>&3)
		if [ $? -eq 0 ]
		then
			PASS_=$(echo $PASS_ | xargs)
			if [ ${#PASS_} -eq 0 ]
			then
				OK=0
			else
				if [ "$PASS" = "$PASS_" ]
				then
					OK=2
					
				else
					OK=1
				fi
			fi
		fi
	fi
	if [ $OK -eq 0 ]
	then
		whiptail --title "$REGYUM_TITLE" --msgbox "Password non inserita" 8 40
	elif [ $OK -eq 1 ]
	then
		whiptail --title "$REGYUM_TITLE" --msgbox "Le password sono diverse" 8 40
	else
		whiptail --title "$REGYUM_TITLE" --msgbox "Le password sono uguali" 8 40
	fi	
fi
unset OK
return

}

#Registrazione su sito red hat, case 3 function yum_register
function yum_register_register {
if [ ${#EMAIL} -ne 0 ] && [ ${#PASS} -ne 0 ]
then
	subscription-manager clean &>/dev/null
	if [ $(subscription-manager register --username $EMAIL --password $PASS &>/dev/null ; echo $?) -ne 0 ]
	then
		whiptail --title "$REGYUM_TITLE" --msgbox "Registrazione fallita" 8 40
	else
		subscription-manager attach --auto &>/dev/null
		whiptail --title "$REGYUM_TITLE" --msgbox "Registrazione completata" 8 40
	fi
	unset PASS PASS_ EMAIL
else
	whiptail --title "$REGYUM_TITLE" --msgbox "Dati mancanti" 8 40
fi
return
}

#Menu di registrazione e aggiornamento VM, case 3 menu principale
function yum_register {

REGYUM_TITLE="Registrazione VM $(hostname)"

if [ ${#var_hostname} -eq 0 ]
then
	if [ $(hostname | grep -qi localhost ; echo $?) -eq 0 ]
	then
		whiptail --title "$REGYUM_TITLE" --msgbox "Necessario cambiare hostname" 10 40
		return
	fi
fi

while :
do
	CHOICEREGYUM=$(
	whiptail --title "$REGYUM_TITLE" --menu "Credenziali REDHAT e aggiornamento OS" 20 70 4 \
		"1)" "Imposta email RHEL subscription"  \
		"2)" "Imposta passwdord RHEL subscription" \
		"3)" "Registra OS su RHEL subscription" \
		"4)" "Aggiorna OS" 3>&1 1>&2 2>&3)
	if [ $? -eq 1 ]
	then
		return
	fi

	case $CHOICEREGYUM in
		"1)")   
			yum_register_email
		;;

		"2)")   
			yum_register_password
		;;

		"3)")   
			yum_register_register
		;;

		"4)")   
			yum update -y
		;;
	esac
done
}

#Disabilitazione root login da ssh, case 4 menu principale
function disable_root {
if [ $(ls /etc/ssh/ | grep -q sshd_config.bak; echo $?) -ne 0 ]
then
	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
fi
if [ $(grep -q "^PermitRootLogin" /etc/ssh/sshd_config ; echo $?) -eq 0 ]
then
	sed -i "/^PermitRootLogin/d" /etc/ssh/sshd_config
fi
if [ $(grep -q "^PermitRootLogin" /etc/ssh/sshd_config ; echo $?) -ne 0 ]
then
	sed -i "\$aPermitRootLogin no" /etc/ssh/sshd_config
fi
systemctl restart sshd
whiptail --title "Disabilitazione root login da SSH" --msgbox "Disabilitato accesso di root in SSH" 8 40
}

#Creazione utenza e cambio password, case 1 e 2 function user_conf
function mod_users {

USER_TITLE="Configurazione utente $1"

OK=2

if [ $(cat /etc/passwd | grep -q $1 ; echo $?) -ne 0 ]
then
	useradd -b /home -c $1 -m -s /bin/bash $1
fi
PASSUSER=$(whiptail --title "$USER_TITLE" --passwordbox "Inserisci la password:" 8 40 3>&1 1>&2 2>&3)

if [ $? -eq 0 ]
then
	PASSUSER=$(echo $PASSUSER | xargs)
	if [ ${#PASSUSER} -lt 8 ]
	then
		OK=0
	else
		PASSUSER_=$(whiptail --title "$USER_TITLE" --passwordbox "Re-Inserisci la password:" 8 40 3>&1 1>&2 2>&3)
		if [ $? -eq 0 ]
		then
			PASSUSER_=$(echo $PASSUSER_ | xargs)
			if [ ${#PASSUSER_} -lt 8 ]
			then
				OK=0
			else
				if [ "$PASSUSER" = "$PASSUSER_" ]
				then
					OK=2
					echo $PASSUSER | passwd --stdin $1 &>/dev/null
					usermod -aG wheel $1 &>/dev/null
				else
					OK=1
				fi
			fi
		fi
	fi
	if [ $OK -eq 0 ]
	then
		whiptail --title "$USER_TITLE" --msgbox "Password troppo corta" 8 40
	elif [ $OK -eq 1 ]
	then
		whiptail --title "$USER_TITLE" --msgbox "Le password sono diverse" 8 40
	else
		whiptail --title "$USER_TITLE" --msgbox "Password impostata correttamente" 8 40
	fi	
fi
unset PASSUSER PASSUSER_
return
}

#Configurazione user1 e user2, case 5 menu principale
function user_conf {

while :
do
	CHOICEUSER=$(
	whiptail --title "Menu configurazione utenti" --menu "Scegli quale utente configurare" 10 40 2 \
		"1)" "Cambia password user1"  \
		"2)" "Cambia password user2" 3>&1 1>&2 2>&3)

	if [ $? -eq 1 ]
	then
		return
	fi
	
	case $CHOICEUSER in
		"1)")   
			mod_users user1
		;;
		"2)")   
			mod_users user2
		;;

	esac
done
}


#Menu principale
while :
do
	CHOICE=$(
	whiptail --title "Creazione nuova VM"  --cancel-button "Exit" --menu "Menu configurazione server" 20 70 5 \
		"1)" "Cambiare hostname"  \
		"2)" "Configurare scheda di rete" \
		"3)" "Registrare VM sul sito RedHat e installazione aggiornamenti" \
		"4)" "Disabilitazione accesso come root in SSH"\
		"5)" "Utenze user1 e user2" 3>&1 1>&2 2>&3)

	if [ $? -eq 1 ]
	then
		exit 0
	fi
	
	case $CHOICE in
		"1)")   
			sethostname
		;;
		"2)")   
			setup_network
		;;
		"3)")   
			yum_register
		;;
		"4)")
			disable_root
		;;
		"5)")
			user_conf
		;;
	esac
done
