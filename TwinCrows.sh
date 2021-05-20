#!/bin/bash

# =========================================================================== #
# ============================= < PARAMETROS > ============================== # 
# =========================================================================== #
readonly TCPath=$(dirname $(readlink -f "$0"))
readonly TCLibPath="$TCPath/lib"
readonly TCScripts="$TCPath/scripts"
readonly TCWordlists="$TCPath/wordlists"

# =========================================================================== #
# =========================== < Incluindo Libs > ============================ # 
# =========================================================================== #
source "$TCLibPath/Format.sh"
source "$TCScripts/WebRecon.sh"
source "$TCScripts/dirsearch.sh"
source "$TCScripts/dependencias.sh"
source "$TCLibPath/Ajuda.sh"
source "$TCScripts/Funcoes.sh"


# =========================================================================== #
# =========================== < Opcoes default > ============================ # 
# =========================================================================== #
wlsubdominio="$TCWordlists/subdominios.txt"
wldiretorio="$TCWordlists/diretorios.txt"

# =========================================================================== #
# ======================== < Checando Permissoes > ========================== # 
# =========================================================================== #
usr=$(whoami)

if [ $usr != "root" ]
then
        echo -e "${vermbold}\n\n[-] Necessario privilegio de root para rodar.\n\n${normal}"
        exit
fi

if [ "$1" == "-d" ]
then
	dependencias
	exit
fi
if [ "$1" == "-h" ]
then
	tc_ajuda
	exit
fi

# =========================================================================== #
# ======================== < Iniciando Processos > ========================== # 
# =========================================================================== #
clear

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


# =========================================================================== #
# ===================== < Verificando dependencias > ======================== # 
# =========================================================================== #

dep=()
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
	echo -e "\n${vermbold}Existem pacotes a serem instalados."
	echo -e "Para prosseguir, execute ${verdebold} $0 -d ${normal}\n\n"
else
	echo -e "\n"
fi
centralizado "${azulbold}[+] Todas as dependencias ja estao instaladas.${normal}\n\n"









# =========================================================================== #
# ================================ < Menu > ================================= # 
# =========================================================================== #
while :
do

	echo
	centralizado "Git: https://github.com/lokisuite/TwinCrows.git\n"
	centralizado "${verde}V 1.0.0\n"
	echo
	echo "1 - whois				6 - Dirsearch			11 - Nmap utils"
	echo "2 - Mapeamento de dominio		7 - Whatweb"
	echo "3 - Transferencia de zona		8 - Pagesearch"
	echo "4 - Bruteforce de subdominios		9 - PingSweep"
	echo "5 - Pesquisa de DNS reverso		10 - Mutacao de wordlist"
	echo
	echo -e "0 - sair${normal}"

	echo -e "${normalbold}"

	read -n3 -p '>> ' opcao

	echo

	case $opcao in

# =========================================================================== #
# =============================== < Whois > ================================= #
# =========================================================================== #
	1)
		centralizado "${azulbold}===== whois =====\n${normal}"
		echo
		echo -e "${verde}Digite o dominio ou IP:${normalbold}"
		read  -p '>> ' dominio
		echo
		centralizado "${azulbold}=====RESULTADO======${normal}\n"
		echo
		python $TCScripts/whois.py $dominio
		exit
	;;
# =========================================================================== #
# ====================== < Mapeamento de dominio > ========================== #
# =========================================================================== #
	2) 
		centralizado "${azulbold}===== Mapeamento de dominio =====\n${normal}"
		echo
		echo -e "${verde}1 - Localizar IPv4"
		echo "2 - Localizar IPv6"
		echo "3 - Localizar servidor DNS"
		echo "4 - Localizar servidor de e-mail"
		echo "5 - Localizar TXT info"
		echo -e "6 - HINFO${normalbold}"
		echo

		read -n2 -p '>> ' resp1
		echo
		case $resp1 in
			"1")
				echo -e "${verde}Informe o dominio:${normalbold}"
				read -p '>> ' dominio
				echo 
				echo
				centralizado "${azulbold}===== RESULTADO =====${normal}\n"
				echo
				echo
				respdom=$( host -t A $dominio)
				echo $respdom
				echo
				echo
				exit
			;;

			"2")
				echo -e "${verde}Informe o dominio:${normalbold}"
                                read -p '>> ' dominio
                                echo
                                echo
				echo
				centralizado "${azulbold}===== RESULTADO =====${normal}\n"
                                echo
				echo
                                host -t aaaa $dominio
                                echo
                                echo
                                exit
			;;

			"3")
				echo -e "${verde}Informe o dominio:${normalbold}"
                                read -p '>> ' dominio
                                echo
				echo
				centralizado "${azulbold}===== RESULTADO =====${normal}\n"
                                echo
				echo
                                host -t ns $dominio
                                echo
                                echo
                                exit
                        ;;

			"4")
                                echo -e "${verde}Informe o dominio:${normalbold}"
                                read -p '>> ' dominio
                                echo 
                                echo
				centralizado "${azulbold}===== RESULTADO =====${normal}\n"
                                echo
                                echo
                                host -t mx $dominio
                                echo
                                echo
                                exit
                        ;;

			"5")
                                echo -e "${verde}Informe o dominio:${normalbold}"
                                read -p '>> ' dominio
                                echo
                                echo
				centralizado "${azulbold}===== RESULTADO =====${normal}\n"
                                echo
                                echo
                                host -t txt $dominio
                                echo
                                echo
                                exit
                        ;;

			"6")
                                echo -e "${verde}Informe o dominio:${normalbold}"
                                read -p '>> ' dominio
                                echo 
                                echo
				centralizado "${azulbold}===== RESULTADO =====${normal}\n"
                                echo
                                echo
                                host -t hinfo $dominio
                                echo
                                echo
                                exit
                        ;;

			*)
				echo -e "${vermbold}Escolha uma opcao valida!${normal}"
				echo
				echo
			;;
		esac
;;
# =========================================================================== #
# ====================== < Transferencia de zona > ========================== #
# =========================================================================== #
	3)
		echo -e "${verde}Informe o dominio:${normalbold}"
                read -p '>> ' dominio
                echo
                echo
		centralizado "${azulbold}===== RESULTADO =====${normal}\n"
                echo
                echo
		for dns in $(host -t ns $dominio | cut -d " " -f4)
		do
			host -l $dominio $dns
		done
		exit
	;;

# =========================================================================== #
# ==================== < Bruteforce de subdominio > ========================= #
# =========================================================================== #
	4)
		echo -e "${verde}Informe o dominio:${normalbold}"
                read -p '>> ' dominio
                echo
                echo
		echo -e "${verde}Deseja informar uma wordlist?"
		echo "1 - Sim"
		echo -e "2 - Usar a padrao${normalbold}"
		echo
		read -n2 -p '>> ' wl
		if [ $wl == 1 ]
		then
			echo
			echo -e "${azul}Informe o caminho da wordlist:${normalbold}"
			read -p '>> ' wlsubdominio
		elif [ $wl -gt 2 ]
		then
			echo -e "\n${vermelho}Opcao $wl invalida."
			exec $0
		fi
		echo
		echo
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
		exit
	;;



# =========================================================================== #
# =========================== < DNS reverso > =============================== #
# =========================================================================== #
	5)
		echo -e "${verde}Informe o IP da rede Ex 37.59.174.226:${normalbold}"
                read -p '>> ' ip
		echo $ip > ip
                echo
                echo -e "${verde}Digite o intervalo do netrange Ex: 220 226${normalbold}"
		read -p '>> ' intervalo
		echo
		centralizado "${azulbold}===== RESULTADO =====${normal}\n"
                echo
                echo
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
		echo
		echo
		exit

	;;
# =========================================================================== #
# ============================ < Dirsearch > ================================ #
# =========================================================================== #
	6)
		echo -e "${verde}Informe o dominio:${normalbold}"
                read -p '>> ' dominio
                echo
                echo
		echo -e "${verde}Informe uma extensao ex(php) ou pressione enter para não pesquisar por arquivos:${normalbold}"
		read -p '>> ' extensao
		echo
		echo
		echo -e "${verde}Deseja informar uma wordlist?"
                echo "1 - Sim"
                echo -e "2 - Usar a padrao${normalbold}"
                echo
                read -n2 -p '>> ' wl
                if [ $wl == 1 ]
                then
                        echo
                        echo -e "${azul}Informe o caminho da wordlist:${normalbold}"
                        read -p '>> ' wldiretorio
                elif [ $wl -gt 2 ]
                then
                        echo -e "${vermelho}Opcao $wl invalida."
			exec $0
                fi
                echo
                echo

		webrecon $wldiretorio $dominio $extensao
	;;
# =========================================================================== #
# ============================= < Whatweb > ================================= #
# =========================================================================== #
	7)
		echo -e "${verde}Informe o dominio:${normalbold}"
                read -p '>> ' dominio
                echo
                echo
		centralizado "${azulbold}===== RESULTADO =====${normal}\n"
                echo
                echo
		whatweb -v $dominio
		exit
	;;
# =========================================================================== #
# =========================== < Pagesearch > ================================ #
# =========================================================================== #
	8)
		echo -e "${verde}Informe o dominio:${normalbold}"
                read -p '>> ' dominio
                echo
                echo
		echo -e "${verde}Informe a extensão da pagina ex(php):${normalbold}"
		read -p '>> ' extensao
		echo
		echo
                centralizado "${azulbold}===== RESULTADO =====${normal}\n"
                echo
                echo
		saida=$(lynx -dump "http://google.com/search?num=500&q=site:"$dominio"+ext:"$extensao"" | cut -d "=" -f2 | grep ".$extensao" | egrep -v "site|google" | sed s'/...$//'g)
		if [ -z "$saida" ]
		then
			echo -e "Não houve resultados para esta pesquisa\n"
			exit
		else
			lynx -dump "http://google.com/search?num=500&q=site:"$dominio"+ext:"$extensao"" | cut -d "=" -f2 | grep ".$extensao" | egrep -v "site|google" | sed s'/...$//'g
			echo -e "\n\n"
		fi
		exit
	;;
# =========================================================================== #
# ============================ < PingSweep > ================================ #
# =========================================================================== #
	9)
		echo -e "${verde}Informe o IP da rede Ex 37.59.174.226:${normalbold}"
                read -p '>> ' ip
                echo $ip > ip
                echo
                echo -e "${verde}Digite o intervalo do netrange Ex: 220 226${normalbold}"
                read -p '>> ' intervalo
                echo
                centralizado "${azulbold}===== RESULTADO =====${normal}\n"
		echo
                echo
                prefixo=$(awk -F. '{print $1"."$2"."$3}' ip)
                prefixo2=$(awk -F. '{print $1"-"$2"-"$3}' ip)
                for range in $(seq $intervalo);do ping -c 1 $prefixo.$range -w 1| grep "64 bytes" | cut -d " " -f4 | sed s'/.$//'g
		done
		exit
		echo
		echo

	;;
# =========================================================================== #
# ========================= < Mutacao de wordlist > ========================= #
# =========================================================================== #
	10)
		echo -e "${verde}Este modulo cria mutação de wordlist existentes, quanto maior a lista de palavras, o tamanho do resultado sera exponencial!\n"
		echo -e "Informe o caminho da wordlist base:${normalbold}"
		read -p '>> ' wl
		echo -e "\n"
		echo -e "${verde}Informe o nome para o arquivo de saida da wordlist mutada:${normalbold}"
		read -p '>> ' nome
		echo -e "\n\n"
		python3 $TCScripts/wlmutacao.py $wl $TCWordlists/$nome
		echo -e "\n\n"
		echo -e "Arquivo salvo em $TCWordlists/$nome"
		echo
		exit
	;;
# =========================================================================== #
# ============================== < Nmap utils > ============================= #
# =========================================================================== #
	11)
		echo -e "${verde}Este modulo explora varias funcionalidades do Nmap."
		echo -e "Escolha uma opcao:"
		echo
		echo -e "${verde}1 - Descobrir hosts ativos na rede"
                echo "2 - Escaneamento de portas padrao"
                echo "3 - Escaneamento -sS por portas"
                echo -e "6 - HINFO${normalbold}"
                echo
		read -n2 -p '>> ' resp3
                echo
                case $resp3 in
                        "1")
                                echo -e "${verde}Informe o IP do host com intervalo ex(192.168.0-255 ou 192.168.0/24):${normalbold}"
                                read -p '>> ' dominio
                                echo 
                                echo
				echo -e "${verde}Caso queira salvar um arquivo de saida, por favor informar:${normalbold}"
				read -p '>> ' arquivo
                                centralizado "${azulbold}===== RESULTADO =====${normal}\n"
                                echo
                                echo
                                nmap_host $dominio $arquivo
                                echo
                                echo
                                exit
                        ;;
			"2")
				echo -e "${verde}Informe o IP do host:${normalbold}"
				read -p '>> ' ip
				echo -e "\n\n"
				echo -e "${verde}Caso queira salvar um arquivo de saida, por favor informar:${normalbold}"
                                read -p '>> ' arquivo
                                centralizado "${azulbold}===== RESULTADO =====${normal}\n"
                                echo
                                echo
				nmap_padrao $ip $arquivo
				echo -e "\n\n"
				exit
			;;
			"3")
				echo -e "${verde}Deseja carregar um arquivo de hosts? [s/n].${normalbold}"
				read -p '>> ' opcao
				echo -e "\n\n"
				if [ "$opcao" == "s" ]
				then
					echo -e "${verde}Informe o caminho para o arquivo:${normalbold}"
					read -p '>> ' origem
				else
					echo -e "${verde}Informe o IP do host:${normalbold}"
        	                        read -p '>> ' ip
				fi
                                echo -e "\n\n"
				echo -e "${verde}Informe as portas ex(21,22,25 ou 0-80):${normalbold}"
				read -p '>> ' porta
				echo -e '\n\n'
                                echo -e "${verde}Caso queira salvar um arquivo de saida, por fafor informe ${normalbold}"
                                read -p '>> ' arquivo
				centralizado "${azulbold}===== RESULTADO =====${normal}\n"
				echo -e '\n\n'
				if [ ! -z "$origem" ]
				then
					modo="-iL=$origem"
				else
					modo="$ip"
				fi
				nmap_portas $modo $porta $arquivo
				echo -e "\n\n"
				exit
			;;
		esac


	;;
# =========================================================================== #
# ================================ < Sair > ================================= #
# =========================================================================== #
	0)
		echo -e "${cinza}OBRIGADO POR UTILIZAR O TWINCROWS!!${normal}\n\n"
		exit
	;;
# =========================================================================== #
# =========================== < Opcao invalida > ============================ #
# =========================================================================== #
	*)
		echo -e "${vermbold}OPÇÃO INVÁLIDA!!\n\n"
	;;



	esac
done

trap echo -e "${cinza}OBRIGADO POR UTILIZAR O TWINCROWS!" EXIT
