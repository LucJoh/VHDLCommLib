restart -force -nowave
view signals wave
config wave -signalnamewidth 1

add wave clk
add wave i2c_inst/addr
add wave i2c_inst/tx_data
add wave i2c_inst/state
add wave i2c_inst/scl
add wave i2c_inst/sda
add wave i2c_inst/done
add wave i2c_inst/rx_data

run -all
