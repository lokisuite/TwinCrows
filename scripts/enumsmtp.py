#!/usr/bin/python
import socket,sys,re

class cor:
	head = '\033[94m'
        normal = '\033[0m'

i = 0


tcpport = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
tcpport.connect((sys.argv[1],int(sys.argv[2])))
print cor.head + "\nConectando no servidor...\n" + cor.normal
banner = tcpport.recv(1024)
print banner
print cor.head + "\nEncontrando usuarios...\n" + cor.normal

with open(sys.argv[3], "rU") as wl:
	for user in wl:
		tcpport = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		tcpport.connect((sys.argv[1],int(sys.argv[2])))
		banner2 = tcpport.recv(1024)
		tcpport.send("VRFY "+user)
		userresp = tcpport.recv(1024)
		if re.search("252",userresp):
			print "Usuario encontrado: " + userresp.strip("252 2.0.0")
			i = i+1

if i == 0:
	print "Nenhum usuario encontrado"
