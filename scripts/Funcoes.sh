#!/bin/bash

sair() {
	echo -e "${cinza}\n\nOBRIGADO POR UTILIZAR O TWINCROWS!\n\n${normal}"
	exit
}

menu_um() {
	centralizado "${azulbold}===== HTML parsing =====\n\n${normal}"
	echo -e "${cinza}Este modulo faz um parsing no codiho html da pagina informada e extrai todos os links encontrados e seus respectivos IPs de servidor.${normal}"
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
                menu_um
        else
                exec $1
        fi

}

menu_dois() {
	centralizado "${azulbold}===== whois =====\n\n${normal}"
        echo -e "${cinza}Este modulo executa uma pesquisa de whois no dominio informado, as informacoes entregues podem ser usadas para obter mais informacoes."
        echo
        echo -e "${verde}Digite o dominio ou IP:${normalbold}"
        read  -p '>> ' dominio
        echo
        centralizado "${azulbold}=====RESULTADO======${normal}\n"
        echo
        python $TCScripts/whois.py $dominio
	echo -e "${verdebold}\n\nDeseja efetuar uma nova pesquisa? [s/n]:${normalbold}"
	read -p '>> ' opcao
	if [ "$opcao" == "s" ]
	then
		menu_dois
	else
		exec $1
	fi
}

menu_tres() {
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
                menu_tres
        else
                exec $1
        fi
}

menu_quatro() {
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

menu_cinco() {
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
                menu_cinco
        else
                exec $1
        fi


}

menu_seis() {
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

menu_sete() {
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
                menu_sete
        else
                exec $1
        fi
}

menu_oito() {
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
                menu_oito
        else
                exec $1
        fi

}

menu_nove() {
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
                menu_nove
        else
                exec $1
        fi
}

menu_dez() {
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
                menu_dez
        else
                exec $1
        fi


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
