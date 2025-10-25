# myscript.tcl

# Restart the simulation
restart

# Add internal signals to waveform
add_wave /top_tb/dut/core/datapath/PCF
add_wave /top_tb/dut/core/datapath/InstrD
add_wave /top_tb/dut/core/datapath/RD1E
add_wave /top_tb/dut/core/datapath/RD2E
add_wave /top_tb/dut/core/datapath/ImmExtE
add_wave /top_tb/dut/core/datapath/ALUResultE
add_wave /top_tb/dut/core/datapath/multiplier_resultE
add_wave /top_tb/dut/core/datapath/ResultW

# set_property radix 

run 1000ns