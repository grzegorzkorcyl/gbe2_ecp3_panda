if {!0} {
    vlib work 
}
vmap work work

#==== compile
vlog -novopt -incr \
+incdir+../../src/params \
+incdir+../../../testbench/top \
+incdir+../../../testbench/tests \
-y /home/soft/lattice/diamond/2.2_x64/cae_library/simulation/verilog/pmi +libext+.v \
-y /home/soft/lattice/diamond/2.2_x64/cae_library/simulation/verilog/ecp3 +libext+.v \
-y ../../../models/ecp3 +libext+.v \
../../impl/synplify/impl/tsmac36_reference_eval_impl_vo.vo \
../../src/params/ts_mac_defines.v \
../../../testbench/top/pkt_mon.v \
../../../testbench/top/orcastra_drv.v \
../../../testbench/top/test_ts_mac.v

#==== run the simulation
vsim -novopt -L work \
      +nowarnTFMPC +nowarnPCDPC +notimingchecks \
      -multisource_delay max +transport_int_delays +transport_path_delays -v2k_int_delays \
      work.test_ts_mac \
      -l tsmac36_eval.log 

view structure wave
do wave_sdf.do
run -all
