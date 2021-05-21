#!/bin/bash
nmap_host() {
	if [ -z "$2" ]
	then
		nmap -sn $1 -oG nmap_host_save -v0 
		cat nmap_host_save | grep "Host" | cut -d " " -f2
		rm -f nmap_host_save

	else
		nmap -sn $1 -oG nmap_host_save -v0
		cat nmap_host_save | grep "Host" | cut -d " " -f2 > $2
		cat nmap_host_save | grep "Host" | cut -d " " -f2
		rm -f nmap_host_save
		echo -e "\n\n Hosts salvos no arquivo $2"
	fi
}

nmap_padrao() {
	if [ -z "$2" ]
	then
		nmap -sS -v -Pn $1
	else
		nmap -sS -v -Pn $1 > $2
		echo -e "\n\nArquivo salvo em $2"
	fi
}

nmap_portas() {
	if [ -z "$3" ] 
	then
		nmap -sS -p $2  --open -Pn $1
	else
		nmap -sS -p $2  --open -Pn $1 > $3
		echo -e "\n\narquivo salvo em $3"
	fi
}

nmap_firewall() {
	if [ -z "$5" ]
	then
		nmap -v -sS -O -sV -g $2 -D RND:$3 -T4 -p $4 -Pn --open $1

	else
		nmap -v -sS -O -sV -g $2 -D RND:$3 -T4 -p $4 -Pn --open $1 > $5
		cat $5
		echo -e "\n\nArquivo salvo em $5\n\n"
	fi
}
