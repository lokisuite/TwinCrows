#!/usr/bin/python
import socket,sys

class cor:
	head = '\033[94m'
        normal = '\033[0m'

wl = open(sys.argv[2])

tcpport = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
tcpport.connect((sys.argv[1],25))
print cor.head + "\nConectando no servidor...\n" + cor.normal
banner = tcpport.recv(1024)
print banner
print cor.head + "\nEncontrando usuarios...\n" + cor.normal

for user in wl:
	tcpport = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	tcpport.connect((sys.argv[1],25))
	tcpport.send("VRFY "+user)
	userresp = tcpport.recv(1024)
	if banner == userresp:
		print "O servico esta bloqueado por firewall, tente outra tecnica."
		break
	else:
		print userresp
