#!/bin/bash

function help(){
	echo -e "\n[+] Netinfo Script Syntax:"
	echo -e "---"
	echo -e "PARAMETER\tDESCRIPTION\n"
	echo -e "   -c\t\tObtain network information given a CIDR"
	echo -e "   -r\t\tObtain network information given an IP range"
	echo -e "   -m\t\tObtain network information given an IP and subnet mask"
}

function calcMask(){
	local argument="$1"
	local maskLine="$(cat ./netmask_table | grep $argument)"
	local maskGroup=$(echo $maskLine | awk '{print $1}' | grep -o "$argument[A-Z]" | sed 's/^.*[0-9]//')
	local maskOctet="$(echo $maskLine | awk '{print $2}')"

	case "$maskGroup" in
	  S) echo "$maskOctet.0.0.0";;
	  A) echo "255.$maskOctet.0.0";;
	  B) echo "255.255.$maskOctet.0";;
	  C) echo "255.255.255.$maskOctet";;
	  *) echo "Error";;
	esac
}

function computeCidr(){
	local argument="$1"
	local prefix="$(echo $argument | sed 's/^.*\//\//')"
	local netMask="$(calcMask $prefix)"
	local hosts=$(echo "2^(32-$(for i in $(seq 1 4); do echo $netMask | cut -d '.' -f$i | xargs echo 'obase=2;' | bc; done | xargs | grep -o '1' | wc -l))-2"| bc)

#	calcMask $prefix

	echo "Obtain network info via CIDR: $argument"
	echo -e "\n[+] Network Information:\n---"
	echo -e "CIDR:\t$1\n"
	echo -e "Network Prefix:\t\t[$prefix]"
	echo -e "Netmask:\t\t[$netMask]"
	echo -e "Total Hosts:\t\t[$hosts] (+2)"
	echo -e "Network ID:\t\t[NetID]"
	echo -e "Broadcast Address:\t[Broadcast]"
	echo -e "---"
}

function computeRange(){
	local argument="$1"
	echo "Obtain network information via IP_Range: $argument"
}

function computeMask(){
	local argument="$1"
	echo "Obtain network info via IP-SubnetMask: $argument"
}

while getopts "c:r:m:h" arg; do
	case $arg in
	  c) #Input CIDR
		computeCidr $OPTARG
		exit;;
	  r) #Input IP Range
		computeRange $OPTARG
		exit;;
	  m) #Input Subnet Mask
		computeMask $OPTARG
		exit;;
	  h) #Show the help panel
		help
		exit;;
	 \?) #Invalid Syntax
		echo "Syntax Error. Use \"-h\" for help"
		exit;;
	esac
done
