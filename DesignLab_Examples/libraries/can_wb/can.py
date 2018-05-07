from pyvit import can
from pyvit.hw.cantact import CantactDev
import time


dev = CantactDev("/dev/ttyUSB1")
dev.set_bitrate(50000)
dev.start()

def send_frame(id,data):
  frame = can.Frame(id)
  frame.data = data
  dev.send(frame)


d=[0x22,0x33,0x44,0x55,0x66,0x77,0x88]
# Send inital frame
id = 0x00
send_frame(id,d)

while True:
  frame = dev.recv()
  if frame is not None:
    print(frame)
    if frame.dlc != 7:
          print("ERROR !!1")
          break
    send_frame(id,d)
    id = id + 1
    if id > 0x7fe:
          id =0
  
