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
-y ../../src/rtl/template +libext+.v \
-y ../../../models/ecp3 +libext+.v \
../../src/params/ts_mac_defines.v \
../../../../tsmac36_beh.v \
../../src/rtl/top/ts_mac_top.v \
../../../testbench/top/pkt_mon.v \
../../../testbench/top/orcastra_drv.v \
../../../testbench/top/test_ts_mac.v

vcom ../../src/rtl/top/ts_mac_core_only_top.vhd
#==== run the simulation
vsim -novopt -L work work.test_ts_mac -l tsmac36_eval.log 

view structure wave
do wave.do
run -all
