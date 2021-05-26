#!/usr/bin/python
import socket,sys,signal

class cor:
	head = '\033[94m'
        normal = '\033[0m'

def signal_handler(signum, frame):
	raise Exception("O servidor nao esta respondendo!")

signal.signal(signal.SIGALRM, signal_handler)
signal.alarm(10)

try:

	wl = open(sys.argv[3])

	tcpport = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	tcpport.connect((sys.argv[1],int(sys.argv[2])))
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
			print "O servico nao e vulneravel ao comando VRFY."
			break
		else:
			print userresp
except Exception, msg:
	print "O servidor nao esta respondendo!"
