import zmq
import random
import sys
import time

port = "5596"
context = zmq.Context()
socket = context.socket(zmq.PAIR)
socket.connect("tcp://127.0.0.1:%s" % port)

while True:
    msg = socket.recv()
    print(msg)
    # socket.send_string("client message to server1")
    # socket.send_string("client message to server2")
    time.sleep(0.01)
