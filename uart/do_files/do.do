restart -force -nowave
view signals wave
config wave -signalnamewidth 1

add wave -color cyan uart_tx_inst/baud_clk
add wave -color cyan uart_tx_inst/state
add wave -color cyan uart_tx_out.ready
add wave -color cyan uart_tx_in.data
add wave -color cyan uart_tx_in.start
add wave -color cyan uart_tx_out.tx

run -all

exit

