#!/bin/bash

# =========================================================================== #
# ============================= < PARAMETROS > ============================== # 
# =========================================================================== #
readonly HELLAPath=$(dirname $(readlink -f "$0"))
readonly HELLALibPath="$HELLAPath/lib"
readonly HELLAScripts="$HELLAPath/scripts"


# =========================================================================== #
# =========================== < Incluindo Libs > ============================ # 
# =========================================================================== #
source "$HELLALibPath/Format.sh"


# =========================================================================== #
# =========================== < Opcoes default > ============================ # 
# =========================================================================== #
wlsubdominio="$HELLALibPath/subdominios.txt"


# =========================================================================== #
# ================================ < Menu > ================================= # 
# =========================================================================== #
while :
do

	echo
	echo -e "${verdebold}V 1.0.0"
	echo
	echo "1 - whois"
	echo "2 - Mapeamento de dominio"
	echo "3 - Transferencia de zona"
	echo "4 - Bruteforce de subdominios"
	echo "5 - Pesquisa de DNS reverso"
	echo
	echo -e "0 - sair${normal}"

	echo

	read -n2 -p 'Opcao: ' opcao

	echo

	case $opcao in

# =========================================================================== #
# =============================== < Whois > ================================= #
# =========================================================================== #
	1)
		echo -e "${verde}Digite o dominio ou IP:${normal}"
		read dominio
		echo
		centralizado "${azulbold}RESULTADO\n"
		centralizado "---------------------------------${normal}"
		echo
		python $HELLAScripts/whois.py $dominio
		exit
	;;
# =========================================================================== #
# ====================== < Mapeamento de dominio > ========================== #
# =========================================================================== #
	2) 
		echo -e "${verde}1 - Localizar IPv4"
		echo "2 - Localizar IPv6"
		echo "3 - Localizar servidor DNS"
		echo "4 - Localizar servidor de e-mail"
		echo "5 - Localizar TXT info"
		echo -e "6 - HINFO${normal}"
		echo

		read -n2 -p 'Opcao: ' resp1
		echo
		case $resp1 in
			"1")
				echo -e "${verde}Informe o dominio:${normal}"
				read dominio
				echo 
				echo
				centralizado "${azulbold}RESULTADO\n"
                		centralizado "---------------------------------${normal}"
				echo
				echo
				respdom=$( host -t A $dominio)
				echo $respdom
				echo
				echo
				exit
			;;

			"2")
				echo -e "${verde}Informe o dominio:${normal}"
                                read dominio
                                echo
                                echo
				echo
                                centralizado "${azulbold}RESULTADO\n"
                                centralizado "---------------------------------${normal}"
                                echo
				echo
                                host -t aaaa $dominio
                                echo
                                echo
                                exit
			;;

			"3")
				echo -e "${verde}Informe o dominio:${normal}"
                                read dominio
                                echo
				echo
                                centralizado "${azulbold}RESULTADO\n"
                                centralizado "---------------------------------${normal}"
                                echo
				echo
                                host -t ns $dominio
                                echo
                                echo
                                exit
                        ;;

			"4")
                                echo -e "${verde}Informe o dominio:${normal}"
                                read dominio
                                echo 
                                echo
				centralizado "${azulbold}RESULTADO\n"
                                centralizado "---------------------------------${normal}"
                                echo
                                echo
                                host -t mx $dominio
                                echo
                                echo
                                exit
                        ;;

			"5")
                                echo -e "${verde}Informe o dominio:${normal}"
                                read dominio
                                echo
                                echo
				centralizado "${azulbold}RESULTADO\n"
                                centralizado "---------------------------------${normal}"
                                echo
                                echo
                                host -t txt $dominio
                                echo
                                echo
                                exit
                        ;;

			"6")
                                echo -e "${verde}Informe o dominio:${normal}"
                                read dominio
                                echo 
                                echo
				centralizado "${azulbold}RESULTADO\n"
                                centralizado "---------------------------------${normal}"
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
		echo -e "${verde}Informe o dominio:${normal}"
                read dominio
                echo
                echo
		centralizado "${azulbold}RESULTADO\n"
                centralizado "---------------------------------${normal}"
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
		echo -e "${verde}Informe o dominio:${normal}"
                read dominio
                echo
                echo
		echo -e "${verde}Deseja informar uma wordlist?"
		echo "1 - Sim"
		echo -e "2 - Usar a padrao${normal}"
		echo
		read -n2 -p 'Opcao: ' wl
		if [ $wl == 1 ]
		then
			echo
			echo -e "${azul}Imforme o caminho da wordlist:${normal}"
			read wlsubdominio
		elif [ $wl -gt 2 ]
		then
			echo -e "${vermelho}Informe uma opcao valida"
			read wlsubdominio
		fi
		echo
		echo
		echo -e "${azulbold}Mapeando os subdominios, aguarde...${normal}"
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
		echo -e "${verde}Informe o IP da rede Ex 37.59.174.226:${normal}"
                read ip
		echo $ip > ip
                echo
                echo -e "${verde}Digite o intervalo do netrange Ex: 220 226${normal}"
		read intervalo
		echo
		centralizado "${azulbold}RESULTADO\n"
                centralizado "---------------------------------${normal}"
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



	esac
done
