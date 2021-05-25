#!/usr/bin/python

import socket,sys

class cor:
	head = '\033[94m'
	normal = '\033[0m'

tcpport = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
tcpport.connect((sys.argv[1],int(sys.argv[2])))
print cor.head + "\nConectando no servidor...\n" + cor.normal
banner = tcpport.recv(1024)
print banner

print cor.head + '\nTentando usuario ' + sys.argv[3] + '\n' + cor.normal
tcpport.send("USER " + sys.argv[3] + "\r\n")
user = tcpport.recv(1024)
print user

print cor.head + '\nTentando senha ' + sys.argv[4] + '\n' + cor.normal
tcpport.send("PASS " + sys.argv[4] + "\r\n")
pw = tcpport.recv(1024)
print pw

print cor.head + '\nEnviando comando ' + sys.argv[5] + '\n'  + cor.normal
tcpport.send(sys.argv[5] + "\r\n")
cmd = tcpport.recv(2048)
print cmd
