restart -force -nowave
view signals wave
config wave -signalnamewidth 1

add wave spi_inst/r.state
add wave spi_in.tx_addr
add wave spi_in.tx_data
add wave spi_in.rw
add wave spi_in.enable
add wave spi_out.ready
add wave spi_out.cs
add wave spi_out.sclk
add wave spi_out.mosi
add wave spi_in.miso

run -all

exit

