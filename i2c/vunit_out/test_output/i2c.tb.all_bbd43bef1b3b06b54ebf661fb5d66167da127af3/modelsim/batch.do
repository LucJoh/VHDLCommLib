onerror {quit -code 1}
source "/home/lucas/git/VHDLCommLib/i2c/vunit_out/test_output/i2c.tb.all_bbd43bef1b3b06b54ebf661fb5d66167da127af3/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
