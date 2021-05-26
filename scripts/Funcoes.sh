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
	echo -e "${verde}Informe o dominio:${normalbold}"
	read -p '>> ' dominio
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
	echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]:${normalbold}"
        read -p '>> ' opcao
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
        echo -e "${verde}Digite o dominio ou IP:${normalbold}"
        read  -p '>> ' dominio
        echo
        centralizado "${azulbold}=====RESULTADO======${normal}\n"
        echo
        whois $dominio
	echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]:${normalbold}"
	read -p '>> ' opcao
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
	echo -e "${verde}Informe o dominio:${normalbold}"
	read -p '>> ' dominio
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
	host -t hinnfo $dominio
	echo -e "\n\n${amarelo}---- Tentativa de transferencia de zona  --------------${normal}\n"
	for dns in $(host -t ns $dominio | cut -d " " -f4)
	do
		host -l $dominio $dns
	done
	echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa [s/n]:${normalbold}"
        read -p '>> ' opcao
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
	echo -e "${verde}Informe o dominio:${normalbold}"
	read -p '>> ' dominio
	echo -e "\n"
	echo -e "${verde}Deseja informar uma wordlist?[s/n]${normalbold}"
	read -n2 -p '>> ' opcao
	if [ "$opcao" == "s" ]
	then
		echo -e "${verde}Informe o caminho da wordlist:${normalbold}"
		read -p '>> ' wlsubdominio
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
	echo -e "${verde}Informe o IP da rede Ex 37.59.174.226:${normalbold}"
	read -p '>> ' ip
	echo $ip > ip
	echo
        echo -e "${verde}Digite o intervalo do netrange Ex: 220 226${normalbold}"
	read -p '>> ' intervalo
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
	echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa [s/n]:${normalbold}"
        read -p '>> ' opcao
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
	echo -e "${verde}Informe o dominio:${normalbold}"
        read -p '>> ' dominio
        echo
	echo -e "${verde}Informe uma extensao ex(php) ou pressione enter para não pesquisar por arquivos:${normalbold}"
	read -p '>> ' extensao
	echo
	echo -e "${verde}Deseja informar uma wordlist?[s/n]${normalbold}"
        read -n2 -p '>> ' opcao
        if [ "$opcao" == "s" ]
        then
                echo -e "${verde}Informe o caminho da wordlist:${normalbold}"
                read -p '>> ' wldiretorio
        fi
	echo
	echo -e "${verde}Deseja utilizar o Tor como proxy?[s/n]:${normalbold}"
	read -n2 -p '>> ' optprox
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
	echo -e "${verde}Informe o dominio:${normalbold}"
	read -p '>> ' dominio
	echo
	centralizado "${azulbold}===== RESULTADO =====${normal}\n"
	echo
	whatweb -v $dominio
	rm -f ip
        echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa [s/n]:${normalbold}"
        read -p '>> ' opcao
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
	echo -e "${verde}Informe o dominio:${normalbold}"
        read -p '>> ' dominio
        echo
	echo -e "${verde}Informe a extensão da pagina ex(php):${normalbold}"
	read -p '>> ' extensao
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
	echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa [s/n]:${normalbold}"
        read -p '>> ' opcao
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
	echo -e "${verde}Informe o IP da rede Ex 37.59.174.226:${normalbold}"
        read -p '>> ' ip
        echo $ip > ip
        echo
        echo -e "${verde}Digite o intervalo do netrange Ex: 220 226${normalbold}"
        read -p '>> ' intervalo
        echo
        centralizado "${azulbold}===== RESULTADO =====${normal}\n"
        echo
        prefixo=$(awk -F. '{print $1"."$2"."$3}' ip)
        prefixo2=$(awk -F. '{print $1"-"$2"-"$3}' ip)
        for range in $(seq $intervalo);do ping -c 1 $prefixo.$range -w 1| grep "64 bytes" | cut -d " " -f4 | sed s'/.$//'g
	done
	rm -f ip
	echo -e "${verdebold}\n\nDeseja efetuar um novo pingsweep? [s/n]:${normalbold}"
        read -p '>> ' opcao
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
	echo -e "${verde}Informe o caminho da wordlist base:${normalbold}"
	read -p '>> ' wl
	echo -e "\n"
	echo -e "${verde}Informe o nome para o arquivo de saida da wordlist mutada:${normalbold}"
	read -p '>> ' nome
	echo -e "\n\n"
	python3 $TCScripts/wlmutacao.py $wl $TCWordlists/$nome
	echo -e "\n"
	echo -e "Arquivo salvo em $TCWordlists/$nome"
	echo
	echo -e "${verdebold}\n\nDeseja efetuar uma nova mutacao de wordlist? [s/n]:${normalbold}"
        read -p '>> ' opcao
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
	echo -e "${verde}Informe o dominio para a pesquisa:${normalbold}"
	read -p '>> ' dominio
	echo -e '\n'
	echo -e "${verde}Informe a extensao para pesquisa de arquivo ex pdf, txt ou xlsx:${normalbold}"
	read -p '>> ' arquivo
	echo -e '\n'
	echo -e "${verde}Informe o caminho para salvar os arquivos baixados:${normalbold}"
	read -p '>> ' caminho
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
        echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]:${normalbold}"
        read -p '>> ' opcao
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
        echo -e "${verde}1 - FTP Enumeration"
	echo -e "2 - NetBIOS/SMB Enumeration"
	echo -e "3 - SMTP Enumeration e bruteforce"
	echo -e "4 - NSE Enumeration"
	echo -e "5 - SNMP Enumeration"
        echo
        echo -e "0 - voltar${normal}"

        echo -e "${normalbold}"

        read  -p '>> ' opcao

        echo

        case $opcao in

		1)
			centralizado "${azulbold}===== Enumeracao de FTP =====\n\n${normal}"
			echo -e "${cinza}Este modulo faz uma conexao com o servidor ftp alvo e captura seu banner, logo em seguida faz a tentativa de login com um usuario informado e executa um comando."
			echo
			echo -e "${verde}Informe o IP do servidor ftp alvo:${normalbold}"
			read -p '>> ' ip
			echo -e "${verde}Informe a porta, caso seja diferente de 21:${normalbold}"
			read -p '>> ' ftpport
			if [ "$ftpport" == "" ]
			then
				ftpport=21
			fi
			echo -e "${verde}Informe um usuario para tentativa de login (default: anonymous):${normalbold}"
			read -p '>> ' ftpuser
			if [ "$ftpuser" == "" ]
			then
				ftpuser="anonymous"
			fi
			echo -e "${verde}Informe uma senha para tentativa de login (default: anonymous):${normalbold}"
			read -p '>> ' ftppass
			if [ "$ftppass" == "" ]
			then
				ftppass="anonymous"
			fi
			echo -e "${verde}Informe um comando para rodar apos o login (default: pwd):${normalbold}"
			read -p '>> ' ftpcmd
			if [ "$ftpcmd" == "" ]
			then
				ftpcmd="pwd"
			fi
			echo -e '\n'
			python $TCScripts/enumftp.py $ip $ftpport $ftpuser $ftppass $ftpcmd
			echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]:${normalbold}"
        		read -p '>> ' opcao
        		if [ "$opcao" == "s" ]
        		then
                		tc_enumeration
        		else
                		exec $TCPath/TwinCrows.sh
        		fi
		;;

		2)
			centralizado "${azulbold}===== Enumeracao de NetBIOS/SMB =====\n\n${normal}"
			echo -e "${cinza}Este modulo utiliza o enum4linux para fazer uma varredura nos servicos de NetBIOS/SMB e tras informacoes importantes caso seja possivel."
			echo
			echo -e "${verde}Informe o IP do servidor alvo:${normalbold}"
			read -p '>> ' ip
			centralizado "${azulbold}===== RESULTADO =====${normal}\n"
        		echo
			enum4linux -a $ip
			echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]:${normalbold}"
                        read -p '>> ' opcao
                        if [ "$opcao" == "s" ]
                        then
                                tc_enumeration
                        else
                                exec $TCPath/TwinCrows.sh
                        fi
		;;

		3)
			centralizado "${azulbold}===== Enumeracao e bruteforce de SMTP =====\n\n${normal}"
			echo -e "${cinza}Este modulo faz a enumeracao do servico de SMTP na porta 25 e faz bruteforce para encontrar usuarios validos utilizando o comando VRFY, nem todos os servicos tem esta vulnerabilidade. o TwinCrows tem uma wordlist padrao, mas uma nova pode ser informada."
			echo
			echo -e "${verde}Informe o IP do servidor alvo:${normalbold}"
			read -p '>> ' ip
			echo -e "${verde}Informe a porta caso seja diferente de 25, ou pressione enter:${normalbold}"
			read -p '>> ' porta
			if [ "$porta" == "" ]
			then
				porta=25
			fi
			echo -e "${verde}Informe o caminho de uma wordlist ou pressione enter para usar a padrao:${normalbold}"
			read -p '>> ' wl
			if [ "$wl" == "" ]
			then
				wl=$TCWordlists/usernames.txt
			fi
			centralizado "${azulbold}===== RESULTADO =====${normal}\n"
        		echo
			python $TCScripts/enumsmtp.py $ip $porta $wl
			echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]:${normalbold}"
                        read -p '>> ' opcao
                        if [ "$opcao" == "s" ]
                        then
                                tc_enumeration
                        else
                                exec $TCPath/TwinCrows.sh
                        fi
		;;
		4)
			umount /tmp/tcnfs 2> /dev/null
			rm -rf /tmp/tcnfs 2> /dev/null
			centralizado "${azulbold}===== Enumeracao de NSE =====\n\n${normal}"
			echo -e "${cinza}Este modulo faz a enumeracao do servico de NSE, e se vulneravel, faz a montagem do diretorio compartilhado com seus respectivos acessos."
			echo
			echo -e "${verde}Informe o IP do servidor alvo:${normalbold}"
			read -p '>> ' ip
			echo -e "${verde}Informe a porta caso seja diferente de 2049, ou pressione enter:${normalbold}"
			read -p '>> ' porta
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
			echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]:${normalbold}"
                        read -p '>> ' opcao
                        if [ "$opcao" == "s" ]
                        then
                                tc_enumeration
                        else
                                exec $TCPath/TwinCrows.sh
                        fi

		;;
		5)
			centralizado "${azulbold}===== Enumeracao de SNMP =====\n\n${normal}"
			echo -e "${cinza}Este modulo faz a enumeracao do servico de SNMP, e se vulneravel, faz a montagem do diretorio compartilhado com seus respectivos acessos."
			echo
			echo -e "${verde}Informe o IP do host alvo:${normalbold}"
			read -p '>> ' ip
			echo -e "${verde}Informe o caminho para uma wordlist de communities ou pressione enter para usar a padrao:${normalbold}"
			read -p '>> ' wl
			echo -e "${azul}Procurando por communities...${normal}\n"
			if [ "$wl" == "" ]
			then
				wl=$TCWordlists/snmp.txt
			fi
			onesixtyone -c $wl $ip | cut -d " " -f1,2 | grep -v "Scanning"
			while [ "$com" == "" ]
			do
				echo -e "\n${verde}Qual comunnubity deseja utilizar?${normalbold}"
				read -p '>> ' com
			done
			xterm -title "SNMPWALK" -hold -geometry 96x120+0+0 -e snmpwalk -c $com -v1 $ip &
			echo -e "\n${azul}Executando checagem de SNMP, pode demorar um pouco...${normal}\n"
			snmp-check $ip -c $com
			echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]:${normalbold}"
                        read -p '>> ' opcao
                        if [ "$opcao" == "s" ]
                        then
                                tc_enumeration
                        else
                                exec $TCPath/TwinCrows.sh
                        fi

		;;
		0)
			exec $TCPath/TwinCrows.sh
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
