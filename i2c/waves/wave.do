restart -force -nowave
view signals wave
config wave -signalnamewidth 1

add wave -color yellow clk
add wave -color yellow i2c_inst/addr
add wave -color yellow i2c_inst/tx_data
add wave -color yellow i2c_inst/state
add wave -color yellow i2c_inst/scl
add wave -color yellow i2c_inst/sda

run -all
