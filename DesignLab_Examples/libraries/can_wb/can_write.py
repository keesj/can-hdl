from pyvit import can
from pyvit.hw.cantact import CantactDev
import time


dev = CantactDev("/dev/ttyUSB2")
dev.set_bitrate(50000)
dev.start()

def send_frame(id,data):
  frame = can.Frame(id)
  frame.data = data
  dev.send(frame)

id=0x70
while True:
  print("send frame")
  send_frame(id,[0x12])
  time.sleep(1)
  
