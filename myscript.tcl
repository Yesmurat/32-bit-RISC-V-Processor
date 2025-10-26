# myscript.tcl

# launch the simulation
launch_simulation

# Add internal signals to waveform
add_wave /top_tb/dut/core/datapath/PCF
add_wave /top_tb/dut/core/datapath/InstrD
add_wave /top_tb/dut/core/datapath/RD1
add_wave /top_tb/dut/core/datapath/RD2
add_wave /top_tb/dut/core/datapath/Rs1D
add_wave /top_tb/dut/core/datapath/Rs2D
add_wave /top_tb/dut/core/datapath/RdD
add_wave /top_tb/dut/core/datapath/ImmExtD
add_wave /top_tb/dut/core/datapath/ALUResultE
add_wave /top_tb/dut/core/datapath/multiplier_resultE
add_wave /top_tb/dut/core/datapath/ResultW
add_wave /top_tb/dut/core/datapath/StallF
add_wave /top_tb/dut/core/datapath/ResultW

set_property DISPLAY_NAME "a_instr" [add_wave top_tb/dut/instr_mem/a]
set_property DISPLAY_NAME "rd_instr" [add_wave top_tb/dut/instr_mem/rd]
# add_wave /top_tb/dut/data_mem/a
# add_wave /top_tb/dut/data_mem/rd

# set_property radix 
run 1000ns