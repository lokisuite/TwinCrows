#!/usr/bin/python

import crypt
import sys
import os

#os.system("clear")

def banner():
	print  """


	   ___               _       __
	  / __\__ _ __  _ __(_)_ __ / __\ __ __ _  ___| | __
	 / _\/ _ \ '_ \| '__| | '__/ / | '__/ _` |/ __| |/ /
	/ / |  __/ | | | |  | | | / /__| | | (_| | (__|   < 
	\/   \___|_| |_|_|  |_|_| \____/_|  \__,_|\___|_|\_\

	
	Desenvolvido por:

	Fenrir

	------------------------------------------------------

"""


apaga = '\x1b[2K'

class cor:
	normal = '\033[0m'
	azul = '\033[94m'
	tent = '\033[91m'
	verde = '\033[92m'

banner()

hash = raw_input("HASH: ")
wl = raw_input("\nWORDLIST: ")


print "\n" + cor.azul
os.system("echo 'Tamanho da wordlist: '$(cat "+  wl +" | wc -l)")
print "\nBruteforce em andamento...\n"


with open(wl, "rU") as wordlist:
	for linha in wordlist:
		linha = linha.strip()
		dec = crypt.crypt(linha,hash)

		if dec == hash:
			print apaga + cor.verde + "A senha e: " + cor.normal + linha + "\r"
			exit()
		else:
			s = apaga + cor.tent + "Tentando: "+ cor.normal + linha+"\r"
			sys.stdout.write(s)
			sys.stdout.flush()
