//=============================================================================
// Verilog module generated by IPExpress    06/19/2012    09:57:30          
// Filename: sgmii_gbe_pcs35_bb.v                                            
// Copyright(c) 2008 Lattice Semiconductor Corporation. All rights reserved.   
//=============================================================================

//---------------------------------------------------------------
// sgmii_gbe_pcs35 synthesis black box definition              
//---------------------------------------------------------------

/* WARNING - Changes to this file should be performed by re-running IPexpress
or modifying the .LPC file and regenerating the core.  Other changes may lead
to inconsistent simulation and/or implemenation results */

 

                        


module sgmii_gbe_pcs35 (
	// Control Interface
	rst_n,
	signal_detect,
	gbe_mode,
	sgmii_mode,
	operational_rate,
	debug_link_timer_short,
	force_isolate,
	force_loopback,
	force_unidir,

	rx_compensation_err,
	ctc_drop_flag,
	ctc_add_flag,
	an_link_ok,
                  
	// G/MII Interface
	tx_clock_enable_sink ,
	tx_clock_enable_source ,
	tx_clk_125,
	tx_d,
	tx_en,
	tx_er,

	rx_clock_enable_sink ,
	rx_clock_enable_source ,
	rx_clk_125,
	rx_d,
	rx_dv,
	rx_er,
	col,
	crs,

	// 8-bit Interface
	tx_data,
	tx_kcntl,
	tx_disparity_cntl,
	xmit_autoneg,

	serdes_recovered_clk,
	rx_data,
	rx_kcntl,
	rx_even ,
	rx_disp_err ,
	rx_cv_err ,
	rx_err_decode_mode ,
   
	// Managment Control Outputs
	mr_an_complete,
	mr_page_rx,
	mr_lp_adv_ability,

	// Managment Control Inputs
	mr_main_reset,
	mr_an_enable,
	mr_restart_an,
	mr_adv_ability
   );



// Control Interface
input         rst_n ;
input         signal_detect ;
input         gbe_mode ;
input         sgmii_mode ;
input [1:0]   operational_rate ;
input         debug_link_timer_short ;
input         force_isolate ;
input         force_loopback ;
input         force_unidir ;

output        rx_compensation_err ;
output        ctc_drop_flag ;
output        ctc_add_flag ;
output        an_link_ok ;

// G/MII Interface
input         tx_clock_enable_sink;
output        tx_clock_enable_source;
input         tx_clk_125 ;
input [7:0]   tx_d ;
input         tx_en ;
input         tx_er ;

input         rx_clock_enable_sink;
output        rx_clock_enable_source;
input         rx_clk_125 ;
output [7:0]  rx_d ;
output        rx_dv ;
output        rx_er ;
output        col ;
output        crs ;

// 8-bit Interface
output [7:0]  tx_data ;
output        tx_kcntl;
output        tx_disparity_cntl;
output        xmit_autoneg;

input         serdes_recovered_clk ;
input [7:0]   rx_data  ;
input         rx_even ;
input         rx_kcntl;
input         rx_disp_err ;
input         rx_cv_err ;
input         rx_err_decode_mode ;

// Managment Control Outputs
output        mr_an_complete;
output        mr_page_rx;
output [15:0] mr_lp_adv_ability;

// Managment Control Inputs
input         mr_main_reset;
input         mr_an_enable;
input         mr_restart_an;
input [15:0]  mr_adv_ability;



endmodule

