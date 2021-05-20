#!/bin/bash

dirsearch(){
        echo -e "\n\n"
        echo -e "${verdebold}Deseja efetuar um novo dirscan? [s/n]${normalbold}"
        read -p '>>' resposta
        if [ "$resposta" == "s" ]
        then
               echo -e "${verde}Informe o dominio:${normalbold}"
               read -p ">> " dominio
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
        else
                exit
        fi

}

