import zmq
import random
import sys
import time
import csv
import math

port = "15567"
context = zmq.Context()
socket = context.socket(zmq.PAIR)
socket.bind("tcp://127.0.0.1:%s" % port)

# while True:
#     socket.send_string("Server message to client3")
#     msg = socket.recv()
#     print(msg)
#     time.sleep(1)

# for i in range(1000):
#     print(i)
#     socket.send_string(str(i))
#     time.sleep(0.01)

with open('/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/TrainingData/2016-05-28_16-17-34_PavanIn_Story1En.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    line_count = 0
    for row in csv_reader:
        if line_count == 0:
            print("Column names are" + ", ".join(row))
            line_count += 1
        elif row[-3] != '':
            #print(row)
            socket.send_string("|".join( (row[-3], row[-2], row[-1]) ) )
            print("|".join( (row[-3], row[-2], row[-1]) ) )
            #time.sleep(0.01)
