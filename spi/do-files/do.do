restart -force -nowave
view signals wave
config wave -signalnamewidth 1

# TESTBENCH SIGNALS

add wave -divider TESTBENCH
add wave spi_inst/r.state
add wave spi_inst/r.clk_counter
add wave /*

# SPI IN SIGNALS

#add wave -divider SPI_IN
#add wave -radix hex -color yellow spi_inst/r.state
#add wave -radix hex -color yellow spi_inst/spi_in
#
## SPI OUT SIGNALS
#
#add wave -divider SPI_OUT
#add wave -radix hex -color magenta spi_inst/spi_out

run -all
#run 900ns

exit

