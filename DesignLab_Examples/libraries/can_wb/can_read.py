from pyvit import can
from pyvit.hw.cantact import CantactDev
import time


dev = CantactDev("/dev/ttyUSB2")
dev.set_bitrate(50000)
dev.start()

while True:
  frame = dev.recv()
  if frame is not None:
    print(frame)
