#!/bin/bash

# =========================================================================== #
# ================================ < Cores > ================================ # 
# =========================================================================== #


vermelho="\e[31m"
azul="\e[34m"
verde="\e[32m"
vermbold="\e[1;31m"
azulbold="\e[1;34m"
verdebold="\e[1;32m"
normal="\e[0m"
normalbold="\e[1;0m"


centralizado(){
        local x
        local y
        text="$*"
        x=$(( ($(tput cols) - ${#text}) / 2))
        echo -ne "\E[6n";read -sdR y; y=$(echo -ne "${y#*[}" | cut -d ';' -f1)
        echo -ne "\033[${y};${x}f$*"
}

# main()
