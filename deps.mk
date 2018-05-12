can_tx.o: hdl/can/syn/can_tx.vhd can_crc.o
can_phy.o: hdl/can/syn/can_phy.vhd
can.o: hdl/can/syn/can.vhd can_tx_mux.o can_clk.o can_tx.o can_rx.o
can_rx.o: hdl/can/syn/can_rx.vhd can_crc.o
can_crc.o: hdl/can/syn/can_crc.vhd can_crc_raw.o
can_crc_raw.o: hdl/can/syn/can_crc_raw.vhd
can_tx_mux.o: hdl/can/syn/can_tx_mux.vhd
can_clk.o: hdl/can/syn/can_clk.vhd
can_wb.o: hdl/can/syn/can_wb.vhd can.o
can_send.o: hdl/can/examples/can_send.vhd can.o
can_wb_tb.o: hdl/can/sim/can_wb_tb.vhd can_wb.o
can_tx_tb.o: hdl/can/sim/can_tx_tb.vhd can_tx.o
can_crc_tb.o: hdl/can/sim/can_crc_tb.vhd can_crc.o
can_tb.o: hdl/can/sim/can_tb.vhd can.o
can_clk_tb.o: hdl/can/sim/can_clk_tb.vhd can_clk.o
can_rx_tb.o: hdl/can/sim/can_rx_tb.vhd can_rx.o
can_phy_tb.o: hdl/can/sim/can_phy_tb.vhd can_phy.o
can_wb_register_tb.o: hdl/can/sim/can_wb_register_tb.vhd can_wb.o
can_two_devices_clk_sync_tb.o: hdl/can/sim/can_two_devices_clk_sync_tb.vhd can.o
can_two_devices_tb.o: hdl/can/sim/can_two_devices_tb.vhd can.o
