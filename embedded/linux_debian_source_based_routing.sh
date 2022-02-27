#!/bin/bash

# Script d'édition des interfaces réseau pour gérer le source-based routing.

# MENU D'AIDE
usage()
{
	echo
	echo "----------------------------------------------------------------------------------"
	echo "Script d'édition des interfaces réseau pour l'utilisation du source based routing."
	echo "Options: $0 [-s] [--silent]"
	echo "----------------------------------------------------------------------------------"
	echo
	exit 2
}

# INSTALLATION DU PAQUET RESOLVCONF
set_resolvconf()
{
	if  [ $VERBOSE = true ]; then
		echo "----------------------------------------------------------------------"
		echo "[+] Téléchargement du paquet 'resolvconf' pour la configuration du DNS"
		echo "[+] ... "
		echo
		sleep 1
	fi

	REQUIRED_PKG=resolvconf
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
	echo Checking for $REQUIRED_PKG: $PKG_OK
	if [ "" = "$PKG_OK" ]; then
  		echo "$REQUIRED_PKG N'est pas installé. Installation de $REQUIRED_PKG."
  		DEBIAN_FRONTEND=noninteractive apt-get install -y $REQUIRED_PKG
	fi

	if [ $VERBOSE = true ]; then
		echo
		echo "[+] ..."
		echo "[+] Done !"
		echo "----------------------------------------------------------------------"
		echo
		sleep 0.5
	fi
}

# PREPARARTION DES FICHIERS DE CONFIGURATION
set_configuration_file()
{
	if  [ $VERBOSE = true ]; then
		echo "----------------------------------------------------------------------"
		echo "[+] Sauvegarde du fichier de configuration des interfaces réseau"
		echo "[+] ... "
		sleep 1
	fi

	IF_FILE="/etc/network/interfaces"

	if [[ -e $IF_FILE.bak || -L $IF_FILE.bak ]] ; then
    	i=1
    	while [[ -e $IF_FILE-$i.bak || -L $IF_FILE-$i.bak ]] ; do
        	let i++
    	done
    	IF_FILE=$IF_FILE-$i
	fi
	touch -- "$IF_FILE".bak

	cat << EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# Ce fichier a été généré par le script source-base-routing.sh
# L'original a été archivé en interfaces.bak dans ce répertoire

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

EOF
	if [ $VERBOSE = true ]; then
		echo "[+] Done !"
		echo "----------------------------------------------------------------------"
		echo
		sleep 0.5
	fi
}

# FONCTION POUR EDITION DES IF
IP_PATTERN="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
set_interfaces()
{
# IP NIC
	while :; do
		read -p "[+] Entrez l'adresse IPv4 de l'interface           : " ETH_IP
            [[ $ETH_IP =~ $IP_PATTERN ]] || { echo "/!\\ '$ETH_IP' n'est pas une adresse valide" ; continue; }
        if [[ $ETH_IP =~ $IP_PATTERN ]]; then
        break
        fi
	done

# GATEWAY
	while :; do
        read -p "[+] Entrez l'adresse IPv4 de la gateway            : " ETH_GATEWAY
            [[ $ETH_GATEWAY =~ $IP_PATTERN ]] || { echo "/!\\ '$ETH_GATEWAY' n'est pas une adresse valide." ; continue; }
        if [[ $ETH_GATEWAY =~ $IP_PATTERN ]]; then
        break
        fi
	done

# NETWORK
	while :; do
        read -p "[+] Entrez l'adresse IPv4 du réseau                : " ETH_NETWORK
            [[ $ETH_NETWORK =~ $IP_PATTERN ]] || { echo "/!\\ '$ETH_NETWORK' n'est pas une adresse valide." ; continue; }
        if [[ $ETH_NETWORK =~ $IP_PATTERN ]]; then
        break
        fi
	done

# NETMASK
	while :; do
		read -p "[+] Entrez le masque de sous réseau au format CIDR : " ETH_NETMASK
			[[ $ETH_NETMASK =~ ^[0-9]{1,2}[:.,-]?$ ]] || { echo "/!\\ Entrez un chiffre entre 0 et 32."; continue; }
		if (($ETH_NETMASK >= 0 && $ETH_NETMASK <= 32)); then
    		break
  		else
    		echo "/!\\ Le masque de sous réseau doit-être entre 0 et 32."
  		fi
	done

# PRIMARY DNS
	while :; do
		read -p "[+] Entrez l'adresse du serveur DNS primaire       : " ETH_DNS_1
            [[ $ETH_DNS_1 =~ $IP_PATTERN ]] || { echo "/!\\ '$ETH_DNS_1' n'est pas une adresse valide" ; continue; }
        if [[ $ETH_DNS_1 =~ $IP_PATTERN ]]; then
        break
        fi
	done

# SECONDARY DNS
	while :; do
		read -p "[+] Entrez l'adresse du serveur DNS secondaire     : " ETH_DNS_2
            [[ $ETH_DNS_2 =~ $IP_PATTERN ]] || { echo "/!\\ '$ETH_DNS_2' n'est pas une adresse valide" ; continue; }
        if [[ $ETH_DNS_2 =~ $IP_PATTERN ]]; then
        break
        fi
	done

	echo
	echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
	echo "[+] Résumé des informations :"
	echo
	echo "[+] Adresse de l'interface = $ETH_IP"
	echo "[+] Adresse de la gateway  = $ETH_GATEWAY"
	echo "[+] Adresse du réseau      = $ETH_NETWORK"
	echo "[+] Masque de sous réseau  = $ETH_NETMASK"
	echo "[+] DNS primaire           = $ETH_DNS_1"
	echo "[+] DNS secondaire         = $ETH_DNS_2"
	echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
	echo

	while true; do
		read -p "$*--> Souhaitez-vous valider ces informations ? [y/n]: " yn
		case $yn in
			[Yy]*) return 0 ;;
			[Nn]*) set_interfaces ; return 1 ;;
		esac
	done
}

# EDITION PREMIERE IF
set_eth0()
{
	if  [ $VERBOSE = true ]; then
		echo "----------------------------------------------------------------------"
		echo "[+] Configuration de l'interface eth0 :"
		echo "[+] ... "
		sleep 1
	fi

	set_interfaces

	cat << EOF >> /etc/network/interfaces
# The primary network interface
allow-hotplug eth0
iface eth0 inet static
	address $ETH_IP/$ETH_NETMASK
	dns-nameserver $ETH_DNS_1
	dns-nameserver $ETH_DNS_2
	post-up ip route add $ETH_NETWORK/$ETH_NETMASK dev eth0 src $ETH_IP table eth0-route
	post-up ip route add default via $ETH_GATEWAY dev eth0 table eth0-route
	post-up ip rule add from $ETH_IP lookup eth0-route
	post-up ip rule add to $ETH_IP lookup eth0-route

EOF

	if [ $VERBOSE = true ]; then
		echo "[+] ... "
		echo "[+] Done !"
		echo "----------------------------------------------------------------------"
		echo
		sleep 0.5
	fi
}

# EDITION SECONDE IF
set_eth1()
{
	if  [ $VERBOSE = true ]; then
		echo "----------------------------------------------------------------------"
		echo "[+] Configuration de l'interface eth1"
		echo "[+] ... "
		sleep 1
	fi

	set_interfaces

cat << EOF >> /etc/network/interfaces
# The secondary network interface
allow-hotplug eth1
iface eth1 inet static
	address $ETH_IP/$ETH_NETMASK
	gateway $ETH_GATEWAY
	dns-nameserver $ETH_DNS_1
	dns-nameserver $ETH_DNS_2
	post-up ip route add $ETH_NETWORK/$ETH_NETMASK dev eth1 src $ETH_IP table eth1-route
	post-up ip route add default via $ETH_GATEWAY dev eth1 table eth1-route
	post-up ip rule add from $ETH_IP lookup eth1-route
	post-up ip rule add to $ETH_IP lookup eth1-route

EOF

	if [ $VERBOSE = true ]; then
		echo "[+] ... "
		echo "[+] Done !"
		echo "----------------------------------------------------------------------"
		echo
		sleep 0.5
	fi

}

# CREATION DES TABLES DE ROUTAGE
ETH0_ROUTE="100 eth0-route"
ETH1_ROUTE="101 eth1-route"
ROUTE_TABLES="/etc/iproute2/rt_tables"
set_routing_tables()
{
	if  [ $VERBOSE = true ]; then
		echo "----------------------------------------------------------------------"
		echo "[+] Ajout des nouvelles routes à la table de routage"
		echo "[+] ... "
		sleep 1
	fi

	case `grep -Fxq "$ETH0_ROUTE" "$ROUTE_TABLES" >/dev/null; echo $?` in
  		0)
			echo "[+] La route $ETH0_ROUTE existait déjà. Etape suivante..." ;;
		1)
			echo "[+] Ajout de la route $ETH0_ROUTE à $ROUTE_TABLES" ;
			echo "$ETH0_ROUTE" >> $ROUTE_TABLES ;;
		*)
			;;
	esac

	case `grep -Fxq "$ETH1_ROUTE" "$ROUTE_TABLES" >/dev/null; echo $?` in
  		0)
			echo "[+] La route $ETH1_ROUTE existait déjà. Etape suivante..." ;;
		1)
			echo "[+] Ajout de la route $ETH1_ROUTE à $ROUTE_TABLES" ;
			echo "$ETH1_ROUTE" >> $ROUTE_TABLES ;;
		*)
			;;
	esac

	if [ $VERBOSE = true ]; then
		echo "[+] ..."
		echo "[+] Done !"
		echo "----------------------------------------------------------------------"
		echo
		sleep 0.5
	fi
}

set_reboot()
{
	if  [ $VERBOSE = true ]; then
		echo "----------------------------------------------------------------------"
		echo "[+] Configuration terminée ! Un redémarrage est nécessaire :"
		echo "[+] En cas d'erreur de configuration, la connexion sera perdue."
		sleep 1
	fi

	while true; do
		read -p "$*--> Souhaitez-vous redémarrer maintenant ? [y/n]: " yn
		case $yn in
			[Yy]*) systemctl reboot now ;;
			[Nn]*) return 1 ;;
		esac
	done

	if [ $VERBOSE = true ]; then
		echo "[+] ..."
		echo "[+] Done !"
		echo "----------------------------------------------------------------------"
		echo
		sleep 0.5
	fi
}
# Variables getops
VERBOSE=true

# Traitement des arguments
while getopts ":hvs:-:" option
do
    case $option in
        h ) usage ;;
        s ) VERBOSE=false ;;
        - )
            LONG_OPTARG="${OPTARG#*=}"
                case $OPTARG in
                    help ) usage ;;
                    silent ) VERBOSE=false ;;
                    '' ) break ;;
                    * )  echo "Illegal option --$OPTARG" >&2; exit 2 ;;
                esac
            ;;
        : )
            echo "Missing arg for -$OPTARG option"
            exit 1
        ;;
        \? )
            echo "$OPTARG: illegal option"
            exit 1
        ;;
    esac
done
shift $((OPTIND-1))

# APPEL DES FONCTIONS
set_resolvconf
set_routing_tables
set_configuration_file
set_eth0
set_eth1
set_reboot