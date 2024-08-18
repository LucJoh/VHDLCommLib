restart -force -nowave
view signals wave
config wave -signalnamewidth 1

add wave -color cyan spi_inst/r.state
add wave -color cyan spi_in.tx_addr
add wave -color cyan spi_in.tx_data
add wave -color cyan spi_in.rw
add wave -color cyan spi_in.enable
add wave -color cyan spi_out.ready
add wave -color cyan spi_out.cs
add wave -color cyan spi_out.sclk
add wave -color cyan spi_out.mosi
add wave -color cyan spi_in.miso

run -all

exit

