# add_waves.tcl 
set sig_list [list clk tx_addr tx_data state scl sda]
gtkwave::addSignalsFromList $sig_list
