import socket
from time import sleep

IP = '127.0.0.1'
PORT = 53474

sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)


while True:
    m = 'ping'
    sock.sendto(bytes(m), (IP, PORT))
    print m
    sleep(10)
