restart -force -nowave
view signals wave
config wave -signalnamewidth 1

add wave -color orange rstn
add wave -color orange clk
add wave -color orange uart_tx_inst/r.baud_clk
add wave -color orange uart_tx_inst/r.state
add wave -color orange uart_tx_out.ready
add wave -color orange uart_tx_out.done
add wave -color orange uart_tx_in.data
add wave -color orange uart_tx_in.start
add wave -color orange uart_tx_out.tx

run -all

exit

