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
		if [ "$lin" == "postgresql" ]
		then
			ins=$(dpkg --get-selections | grep postgresql | wc -l)
			if [ "$ins" == 0 ]
			then
				echo -e "{vermbold}[-] $lin nao instalado.${normal}"
				dep+=($lin)
			else
				echo -e "${azulbold}[+] $lin instalado.${normal}"
			fi
		elif [ "$lin" == "metasploit-framework" ]
		then
			ins=$(builtin type -p msfconsole | wc -l)
			if [ "$ins" == 0 ]
			then
				echo -e "${vermvold}[-] $lin nao instalado.${normal}"
				dep+=($lin)
			else
				echo -e "${azulbold}[+] $lin instalado.${normal}"
			fi
		else
			ins=$(builtin type -p $lin | wc -l)
        		if [ "$ins" == 0 ]
        		then
                		echo -e "${vermbold}[-] $lin nao instalado.${normal}"
                		dep+=($lin)
       	 		else
                		echo -e "${azulbold}[+] $lin instalado.${normal}"
        		fi
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
			if [ "$lin" == "tor" ]
			then
				echo -e "${cinza}Para que o TwinCrows rode utilizando a rede Tor para anonimizacao, e necessario incluir 'socks5 127.0.0.1 9050' sem aspas  no arquivo de configuracao que se encontra em /etc/proxychains*.conf, caso tenha duvidas, procure o manual do Tor e do proxychains..${normal}"
			fi
		done
		clear
		echo -e "\n\n"
	else
        	echo -e "\n"
	fi
for lin in $(cat $TCLibPath/dependencias_apk)
do
	apt install $lin -y
done
echo -e "${azulbold}Atualizando bibliotecas. ${normal}"
apt update && apt upgrade
mv $TCLibPath/apktool* /usr/local/bin
chmod a+x /usr/local/bin
apt remove apktool -y
apt install apktool -y
apktool empty-framework-dir --force
echo -e "\n\n"
centralizado "${azulbold}[+] Todas as dependencias ja estao instaladas. Execute a aplicacao normalmente.\n\n${normal}"
exit

}
