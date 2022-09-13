import socket
import json
import struct
import numpy as np


class TCP():
    def __init__(self,address='127.0.0.1',port=9999):

        self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.s.bind((address,port))
        self.s.listen(5)
        print('waiting for connection...')
        self.sock,self.addr=self.s.accept()
        

    def decode_data(self,buf):
        buf_2 = struct.unpack('ddddddddddddd', buf)
        return buf_2


    def receive_data(self,buf_size):
        buf = self.sock.recv(buf_size)
        buf_2 = self.decode_data(buf)
        return buf_2


    def send_data(self,data):
        control_signal = np.array(data, float)
        s = str(control_signal)
        s2 = s.replace("\n", "")
        s_l = bytes(s2, encoding='utf8')
        self.sock.send(s_l)

    def close_tcp(self):
        self.sock.close()