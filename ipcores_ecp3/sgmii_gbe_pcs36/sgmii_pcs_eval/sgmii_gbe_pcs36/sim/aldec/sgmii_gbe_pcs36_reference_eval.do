cd "/home/hadaq/greg/projects/git/gbe2_ecp3/ipcores_ecp3/sgmii_gbe_pcs36/sgmii_pcs_eval/sgmii_gbe_pcs36/sim/aldec" 
workspace create sgmii_pcs_space 
design create sgmii_pcs_design . 
design open sgmii_pcs_design 
cd "/home/hadaq/greg/projects/git/gbe2_ecp3/ipcores_ecp3/sgmii_gbe_pcs36/sgmii_pcs_eval/sgmii_gbe_pcs36/sim/aldec" 
set sim_working_folder .

# compile the IP core ###############
vlog ../../../../sgmii_gbe_pcs36_beh.v

# compile components of an sgmii channel ###############
vlog ../../src/rtl/template/ecp3/register_interface_hb.v  
vlog ../../src/rtl/template/ecp3/rate_resolution.v 
vlog ../../src/rtl/template/ecp3/tx_reset_sm_sim.v 
vlog ../../src/rtl/template/ecp3/rx_reset_sm_sim.v 

# compile top level hardware components ###############
vlog ../../../models/ecp3/pcs_serdes/pcs_serdes.v  
vlog ../../../models/ecp3/pmi_fifo_dc/pmi_fifo_dc.v  

# compile top level wrapper ###############
vcom ../../src/rtl/top/ecp3/top_hb.vhd  

# compile testbench components of sgmii_node ###############
vlog ../../../testbench/sgmii_node.v  

# compile testbench components of mii monitor ###############
vlog ../../../testbench/port_parser_mii.v  
vlog ../../../testbench/port_monitor.v  
vlog ../../../testbench/mii_monitor.v  

# compile the testbench ###############
vlog ../../../testbench/tb_hb.v 


#start the simulator
vsim +access +r -t 1ps -L pcsd_aldec_work -L ovi_ecp3 tb 


# list waves
view wave
onerror {resume}
add wave -divider {Control Signals}
add wave -format Logic -radix hexadecimal sim:/tb/top/rst_n
add wave -format Logic -radix hexadecimal sim:/tb/top/sgmii_mode
add wave -divider {Host Bus Signals}
add wave -format Logic -radix hexadecimal sim:/tb/top/hcs_n
add wave -format Logic -radix hexadecimal sim:/tb/top/hwrite_n
add wave -format Logic -radix hexadecimal sim:/tb/top/haddr
add wave -format Logic -radix hexadecimal sim:/tb/top/hdatain
add wave -format Logic -radix hexadecimal sim:/tb/top/hdataout
add wave -format Logic -radix hexadecimal sim:/tb/top/hready_n
add wave -divider {(G)MII Inbound Signals}
add wave -format Logic -radix hexadecimal sim:/tb/top/in_ce_source
add wave -format Logic -radix hexadecimal sim:/tb/top/in_ce_sink
add wave -format Logic -radix hexadecimal sim:/tb/top/en_in_mii
add wave -format Literal -radix hexadecimal sim:/tb/top/data_in_mii
add wave -format Logic -radix hexadecimal sim:/tb/top/err_in_mii
add wave -divider {(G)MII Outbound Signals}
add wave -format Logic -radix hexadecimal sim:/tb/top/out_ce_source
add wave -format Logic -radix hexadecimal sim:/tb/top/out_ce_sink
add wave -format Logic -radix hexadecimal sim:/tb/top/dv_out_mii
add wave -format Literal -radix hexadecimal sim:/tb/top/data_out_mii
add wave -format Logic -radix hexadecimal sim:/tb/top/err_out_mii
add wave -format Logic -radix hexadecimal sim:/tb/top/col_out_mii
add wave -format Logic -radix hexadecimal sim:/tb/top/crs_out_mii
add wave -divider {SERDES Outbound Signals}
add wave -format Logic -radix hexadecimal sim:/tb/top/hdoutp0
add wave -format Logic -radix hexadecimal sim:/tb/top/hdoutn0
add wave -divider {SERDES Inbound Signals}
add wave -format Logic -radix hexadecimal sim:/tb/top/hdinp0
add wave -format Logic -radix hexadecimal sim:/tb/top/hdinn0


# run simulation cycles
run -all

