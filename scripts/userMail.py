#!/usr/bin/env python3

import sys
import string

dic = {}
dominio = sys.argv[2]
filetxt = open('wordlists/usuarios.txt', 'w')
emailtxt = open('wordlists/email.txt', 'w')


def monta_email(email):
	emailtxt.write((email.rstrip('\n')+'@'+dominio+'\n').lower())

def monta_lista(user):
	x = len(user.split(' '))
	if(x > 1):
		u = user.split(' ')[0]+'\n'
		filetxt.write(u.lower())
		monta_email(u)
		u = user.split(' ')[0]+user.split(' ')[x-1]+'\n'
		filetxt.write(u.lower())
		monta_email(u)
		u = user.split(' ')[0]+'.'+user.split(' ')[x-1]+'\n'
		filetxt.write(u.lower())
		monta_email(u)
		u = user.split(' ')[0][0]+user.split(' ')[x-1]+'\n'
		filetxt.write(u.lower())
		monta_email(u)
		u = user.split(' ')[0]+user.split(' ')[x-1][0]+'\n'
		filetxt.write(u.lower())
		monta_email(u)
		if(x > 2):
			u = user.split(' ')[0][0]+user.split(' ')[1][0]+user.split(' ')[x-1]+'\n'
			filetxt.write(u.lower())
			monta_email(u)
	else:
		filetxt.write(user.lower()+'\n')
		monta_email(user)

def main():
	with open(sys.argv[1]) as file:
		for t in file:
			linha = t.rstrip('\n')
			monta_lista(linha)
	filetxt.close()
	emailtxt.close()

if __name__ == '__main__':
  main()
