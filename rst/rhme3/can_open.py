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


d= list(bytearray("lock\0\0\0\0"))

id = 0x332

while True:
	time.sleep(1)
	send_frame(id,d)
  
