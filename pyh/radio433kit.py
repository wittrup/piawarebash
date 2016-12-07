"""
DIYDrones 3DR RadioTelemetry Kit (433MHz) pinger
"""
from __future__ import print_function
import serial
import threading
from time import strftime as now
from time import sleep
try:
    input = raw_input
except:
    pass


FORMAT = '%Y-%m-%d %H:%M:%S'
ser = serial.Serial('/dev/ttyUSB0', baudrate=57600, timeout=1)
logfile = "/home/pi/433.log"

def readFport(ser):
    line = b''
    while running:
        line += ser.read()
        if line and line[-1] in [10, 13, b'\r', b'\n']: # for both python 2.7.9 and python 3.5
            text = b"RECV: '" + line.rstrip() + b"'"
            print(text)
            print(str.encode(now(FORMAT)) + b' ' + text, file=open(logfile, 'a'))
            line = b''

def writeping(port):
    while running:
        port.write(str.encode(now(FORMAT)) + b' PING\r\n')
        sleep(5)

running = True
threads = {'readFport': threading.Thread(target=readFport, args=(ser,)),
           'writeping': threading.Thread(target=writeping, args=(ser,))}
for name,thread in threads.items():
    thread.start()

try:
    while True:
        query = input()
        if query.upper() in ['QUIT', 'EXIT']:
            running = False
            break
        else:
            ser.write(bytes(query + "\r", encoding='ascii'))
except (KeyboardInterrupt, SystemExit, EOFError):
    ser.close()


