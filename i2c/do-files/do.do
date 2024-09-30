restart -force -nowave
view signals wave
config wave -signalnamewidth 1

add wave clk
add wave i2c_inst/r.state
add wave i2c_in.addr
add wave i2c_in.tx_data
add wave i2c_in.rw
add wave i2c_in.start
add wave i2c_out.ready
add wave i2c_inst/r.dcl_enable
add wave i2c_inst/r.scl_enable
add wave i2c_inst/r.dcl_rising_edge
add wave i2c_inst/r.scl_rising_edge
add wave i2c_inst/r.dcl
add wave i2c_inst/r.scl
add wave i2c_inst/r.dcl_counter
add wave i2c_inst/r.scl_counter
add wave scl
add wave sda

run -all

exit

