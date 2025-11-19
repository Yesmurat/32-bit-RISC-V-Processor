# myscript.tcl

# launch the simulation
# launch_simulation -simset sim_1 -type behav
launch_simulation -simset sim_1 -type post_synth

set dp_siglist {
    InstrD
    SrcAE
    SrcBE
    multdiv_resultM
    ResultW
    ALUResultM
}

foreach signal $dp_siglist {
    add_wave /top_tb/dut/core/datapath/$signal
}

add_wave /top_tb/dut/instr_mem/rd

set div_siglist {
    stall
    result
    dout_tvalid_u
    ex_is_div
    div_result_u
    div_req_inflight
    div_is_signed
    post_stall
    ex_is_div_int
    dout_tvalid_s
    div_result_s
}

foreach signal $div_siglist {
    add_wave /top_tb/dut/core/datapath/divider/$signal
}

# run 1000ns

# save_wave_config {C:/Users/Yesmurat Sagyndyk/RV32IM/project/waveforms.wcfg}