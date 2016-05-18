from threading import Thread
from cmd import Cmd
import signal, sys, os, time
import socket

IP = '127.0.0.1'
PORT = 53474


class ConnectedNESDebug(Cmd):


    def __init__(self, *args, **kwargs):
        Cmd.__init__(self, *args, **kwargs)
        self.intro = '\n ConnectedNES  \n'
        self.scope = {}
        self.prompt = '>>> '
        self.sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)

    def default(self, msg):
        self.sock.sendto(bytes(msg), (IP, PORT))
        print 'OK'

if __name__ == '__main__':
    try:
        ConnectedNESDebug().cmdloop()
    except KeyboardInterrupt:
        print '\n\nBye'
        pass



