#!/bin/bash


webrecon() {
	echo
	echo -e "${azulbold}====== Escaneando URL: ${verdebold}$2 ${azulbold}======${normal}"
	echo
	qtd=$(cat $1 | wc -l)
	echo -e "Wordlist com $qtd linhas\n\n"
	echo "DIRETORIOS"
	echo
	for diretorio in $(cat $1)
	do
		resp=$(curl -s -o /dev/null -w "%{http_code}" -A "TwinCrows" $2/$diretorio/)
		if [ $resp == "200" ]
		then
			echo -ne "\rDiretorio encontrado: $2/$diretorio"
			echo
		else
			echo -ne "\r$2/$diretorio ... nao encontrado            "
		fi
	done

	if [ ! -z "$3" ]
	then
		echo
		echo
		echo "ARQUIVOS"
		echo
        	for diretorio in $(cat $1)
        	do
                	resp=$(curl -s -o /dev/null -w "%{http_code}" -A "TwinCrows" $2/$diretorio.$3)
                	if [ $resp == "200" ]
                	then
                        	echo -ne "\rArquivo encontrado: $2/$diretorio.$3"
                        	echo
                	else
                        	echo -ne "\r$2/$diretorio.$3 ...nao encontrado             "
                	fi
        	done 
	fi
	dirsearch
}
