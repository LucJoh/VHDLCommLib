restart -force -nowave
view signals wave
config wave -signalnamewidth 1

add wave -color pink rstn
add wave -color pink clk
add wave -color pink rx_vector
add wave -color pink uart_rx_inst/r.baud_clk
add wave -color pink uart_rx_inst/r.state
add wave -color pink uart_rx_out.ready
add wave -color pink uart_rx_out.done
add wave -color pink uart_rx_out.data
add wave -color pink uart_rx_in.rx
add wave -color pink uart_rx_inst/r.rx_vector

run -all

exit

