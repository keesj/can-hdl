Tutorial
========

Can Signaling
'''''''''''''

* Differential

.. image:: tutorial/can_h_can_l.png

* High transmision(the default state) is recessive (hang loose)

.. image:: tutorial/high_recessive.png

* Low transmission is dominant (driven)

.. image:: tutorial/low_dominant.png


* Ended with 120 Ohm resistors
* No dedicated TX/RX like on an UART
* No separate clock line like on SPI/JTAG/I2C
* 0 is STRONGER than 1


Can topology
''''''''''''

* Star topology (and others)

.. image:: tutorial/can_topology.png


Can frame
'''''''''

.. image:: tutorial/can_base_frame.png

* Prevent collision during arbitration (when I send a recessive bit but "see" a dominant one)

.. image:: tutorial/can_arbitration.png


Can bit stuffing
''''''''''''''''

.. image:: tutorial/can_bit_stuffing.png

