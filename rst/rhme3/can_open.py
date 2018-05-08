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


d= list(bytearray("unlock\0\0"))

id = 0x332

while True:
	time.sleep(1)
	frame = dev.recv()
	if frame is not None:
		print(frame)
		send_frame(id,d)
  
