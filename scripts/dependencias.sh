#!/bin/bash

dependencias() {
	clear
	local dep=()
	echo -ne "${cinza}\n\n"

	banner=()

	banner+=("▀▀█▀▀ █░░░█ ░▀░ █▀▀▄ ▒█▀▀█ █▀▀█ █▀▀█ █░░░█ █▀▀ \n")
	banner+=("░▒█░░ █▄█▄█ ▀█▀ █░░█ ▒█░░░ █▄▄▀ █░░█ █▄█▄█ ▀▀█ \n")
	banner+=("░▒█░░ ░▀░▀░ ▀▀▀ ▀░░▀ ▒█▄▄█ ▀░▀▀ ▀▀▀▀ ░▀░▀░ ▀▀▀\n")

	for linha in "${banner[@]}"
	do
        	centralizado $linha
        	sleep 0.05
	done

	echo -ne "${normal}\n"

	centralizado "${verde}Verificando dependencias..."
	echo -e "\n\n"
	for lin in $(cat $TCLibPath/dependencias)
	do
        	if [ $(dpkg --get-selections | grep $lin | wc -l) == 0 ]
        	then
                	echo -e "${vermbold}[-] $lin nao instalado.${normal}"
                	dep+=($lin)
       	 	else
                	echo -e "${azulbold}[+] $lin instalado.${normal}"
        	fi
	done
	sleep 0.05
	if [ ! -z "$dep" ]
	then
        	echo -e "\n${vermbold}Instalando dependencias..."
		apt update
		for lin in "${dep[@]}"
                do
                        centralizado "${verdebold}[+] ${normal} instalando $lin..."
                        apt install $lin -y
                        clear
			if [ "$lin" == "proxychains" ]
			then
				echo -e "${cinza}Para que o TwinCrows rode utilizando a rede Tor para anonimizacao, e necessario incluir 'socks5 127.0.0.1 9050' sem aspas  no arquivo de configuracao que se encontra em /etc/proxychains*.conf, caso tenha duvidas, procure o manual do Tor e do proxychains..${normal}"
			fi
		done
		echo -e "\n\n"
		centralizado "${azulbold}[+] Dependencias instaladas, execute normalmente.${normal}"
		exit
	else
        	echo -e "\n"
	fi
	centralizado "${azulbold}[+] Todas as dependencias ja estao instaladas. Execute a aplicacao normalmente.\n\n${normal}"
}
