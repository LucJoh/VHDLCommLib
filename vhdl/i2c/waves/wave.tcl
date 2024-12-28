# add_waves.tcl 
set sig_list [list clk tx_addr tx_data state scl sda done rx_data]
gtkwave::addSignalsFromList $sig_list
