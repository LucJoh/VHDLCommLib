restart -force -nowave
view signals wave
config wave -signalnamewidth 1

#add wave -color cyan uart_tx_inst/r.baud_clk
#add wave -color cyan uart_tx_inst/r.state
#add wave -color cyan uart_tx_out.ready
#add wave -color cyan uart_tx_in.data
#add wave -color cyan uart_tx_in.start
#add wave -color cyan uart_tx_out.tx

add wave rstn
add wave clk
add wave uart_tx_inst/r.baud_clk
add wave uart_tx_inst/r.state
add wave uart_tx_out.ready
add wave uart_tx_out.done
add wave uart_tx_in.data
add wave uart_tx_in.start
add wave uart_tx_out.tx

run -all

exit

