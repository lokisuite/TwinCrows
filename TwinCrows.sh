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
	echo -e "${verde}1 - HTML Parsing			7 - Whatweb"
	echo "2 - whois				8 - Pagesearch"
	echo "3 - Mapeamento de dominio		9 - PingSweep"
	echo "4 - Bruteforce de subdominios		10 - Mutacao de wordlist"
	echo "5 - Pesquisa de DNS reverso		11 - Nmap utils"
	echo "6 - Dirsearch"
	echo
	echo -e "0 - sair${normal}"

	echo -e "${normalbold}"

	read -n3 -p '>> ' opcao

	echo

	case $opcao in

# =========================================================================== #
# =========================== < HTML Parsing > ============================== #
# =========================================================================== #
	1)
		menu_um $0
	;;
# =========================================================================== #
# =============================== < Whois > ================================= #
# =========================================================================== #
	2)
		menu_dois $0
	;;
# =========================================================================== #
# ====================== < Mapeamento de dominio > ========================== #
# =========================================================================== #
	3) 
		menu_tres $0
	;;
# =========================================================================== #
# ==================== < Bruteforce de subdominio > ========================= #
# =========================================================================== #
	4)
		menu_quatro $0 $wlsubdominio
	;;
# =========================================================================== #
# =========================== < DNS reverso > =============================== #
# =========================================================================== #
	5)
		menu_cinco $0
	;;
# =========================================================================== #
# ============================ < Dirsearch > ================================ #
# =========================================================================== #
	6)
		menu_seis $0 $wldiretorio
	;;
# =========================================================================== #
# ============================= < Whatweb > ================================= #
# =========================================================================== #
	7)
		menu_sete $0
	;;
# =========================================================================== #
# =========================== < Pagesearch > ================================ #
# =========================================================================== #
	8)
		menu_oito $0
	;;
# =========================================================================== #
# ============================ < PingSweep > ================================ #
# =========================================================================== #
	9)
		menu_nove $0
	;;
# =========================================================================== #
# ========================= < Mutacao de wordlist > ========================= #
# =========================================================================== #
	10)
		menu_dez $0
	;;
# =========================================================================== #
# ============================== < Nmap utils > ============================= #
# =========================================================================== #
	11)
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

