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

banner+=("▀▀█▀▀ █░░░█ ░▀░ █▀▀▄ ▒█▀▀█ █▀▀█ █▀▀█ █░░░█ █▀▀\n")
banner+=("░▒█░░ █▄█▄█ ▀█▀ █░░█ ▒█░░░ █▄▄▀ █░░█ █▄█▄█ ▀▀█\n")
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
	exit
else
	echo -e "\n"
fi
centralizado "${azulbold}[+] Todas as dependencias ja estao instaladas.${normal}"
echo -e "\n"


# =========================================================================== #
# ================================ < Menu > ================================= # 
# =========================================================================== #
while :
do

	echo
	centralizado "Git: https://github.com/lokisuite/TwinCrows.git\n"
	centralizado "${vermelho}v 1.1.0\n"
	echo
	echo -e "${verde}1 - whois				6 - Whatweb"
	echo "2 - Mapeamento de dominio		7 - Pagesearch"
	echo "3 - Bruteforce de subdominios		8 - PingSweep"
	echo "4 - Pesquisa de DNS reverso		9 - Mutacao de wordlist"
	echo "5 - Dirsearch				10 - Nmap utils"
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
		menu_um $0
	;;
# =========================================================================== #
# ====================== < Mapeamento de dominio > ========================== #
# =========================================================================== #
	2) 
		menu_dois $0
	;;
# =========================================================================== #
# ==================== < Bruteforce de subdominio > ========================= #
# =========================================================================== #
	3)
		menu_tres $0 $wlsubdominio
	;;



# =========================================================================== #
# =========================== < DNS reverso > =============================== #
# =========================================================================== #
	4)
		menu_quatro $0
	;;
# =========================================================================== #
# ============================ < Dirsearch > ================================ #
# =========================================================================== #
	5)
		menu_cinco $0 $wldiretorio
	;;
# =========================================================================== #
# ============================= < Whatweb > ================================= #
# =========================================================================== #
	6)
		menu_seis $0
	;;
# =========================================================================== #
# =========================== < Pagesearch > ================================ #
# =========================================================================== #
	7)
		menu_sete $0
	;;
# =========================================================================== #
# ============================ < PingSweep > ================================ #
# =========================================================================== #
	8)
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
		exit

	;;
# =========================================================================== #
# ========================= < Mutacao de wordlist > ========================= #
# =========================================================================== #
	9)
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
		exit
	;;
# =========================================================================== #
# ============================== < Nmap utils > ============================= #
# =========================================================================== #
	10)
		centralizado "${azulbold}===== Nmap utils =====\n\n${normal}"
		echo -e "${cinza}Este modulo traz algumas opcoes pre configuradas de utilizacao do nmap, como o nmap e uma ferramenta extremamente completa, estes modulos sao so uma fracao de sua capacidade."
		echo
		echo -e "Escolha uma opcao:"
		echo
		echo -e "${verde}1 - Descobrir hosts ativos na rede"
                echo "2 - Escaneamento de portas padrao"
                echo "3 - Escaneamento -sS por portas"
                echo -e "4 - Scan com evasion de firewall/IDS${normalbold}"
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
			"4")
				echo -e "${verde}Informe o IP do host:${normalbold}"
				read -p '>> ' ip
				echo -e "\n"
				echo -e "${verde}Informe a porta para bypass:${normalbold}"
				read -p '>> ' portabp
				echo -e "\n"
				echo -e "${verde}Informe a quantidade de IPs falsos:${normalbold}"
				read -p '>> ' decoy
				echo -e "\n"
				echo -e "${verde}Informe as portas ex(21,22,25 ou 0-80):${normalbold}"
				read -p '>> ' porta
				echo -e "\n"
				echo -e "${verde}Caso queira salvar um arquivo de saida, por favor informe:${normalbold}"
				read -p '>> ' arquivo
				echo
				nmap_firewall $ip $portabp $decoy $porta $arquivo
				exit
			;;
		esac


	;;
# =========================================================================== #
# ================================ < Sair > ================================= #
# =========================================================================== #
	0)
		sair
	;;
# =========================================================================== #
# =========================== < Opcao invalida > ============================ #
# =========================================================================== #
	*)
		echo -e "${vermbold}OPÇÃO INVÁLIDA!!\n\n"
	;;



	esac
done

