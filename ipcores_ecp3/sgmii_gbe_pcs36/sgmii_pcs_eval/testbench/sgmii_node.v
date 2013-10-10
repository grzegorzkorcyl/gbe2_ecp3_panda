//**************************************************************************
// *************************************************************************
// *                LATTICE SEMICONDUCTOR CONFIDENTIAL                     *
// *                         PROPRIETARY NOTE                              *
// *                                                                       *
// *  This software contains information confidential and proprietary      *
// *  to Lattice Semiconductor Corporation.  It shall not be reproduced    *
// *  in whole or in part, or transferred to other documents, or disclosed *
// *  to third parties, or used for any purpose other than that for which  *
// *  it was obtained, without the prior written consent of Lattice        *
// *  Semiconductor Corporation.  All rights reserved.                     *
// *                                                                       *
// *************************************************************************
//**************************************************************************

`timescale 1ns/100ps

module sgmii_node (
	// Control Interface
	gbe_mode,
	sgmii_mode,
	force_loopback,
	rst_n,
	phy_speed,

	// G/MII Interface
	data_in_mii,
	en_in_mii,
	err_in_mii,

	data_out_mii,
	dv_out_mii,
	err_out_mii,

	// GMII Timing References
	tx_clk_125,
	tx_ce_sink,
	tx_ce_source,

	rx_clk_125,
	rx_ce_sink,
	rx_ce_source,

	// SERIAL GMII Interface 
	refclkp,
	refclkn,
	hdinp0, 
	hdinn0, 
	hdoutp0, 
	hdoutn0
	);



// I/O Declarations
input		rst_n;		// System Reset, Active Low
input           gbe_mode ;      // GBE Mode       (0=SGMII  1=GBE)
input           sgmii_mode ;    // SGMII PCS Mode (0=MAC    1=PHY)
input           force_loopback ;
input [1:0]	phy_speed;

input		refclkp, refclkn ;
input		tx_clk_125 ;    // GMII Transmit clock 125Mhz
input		tx_ce_sink ;
output		tx_ce_source ;

input [7:0]	data_in_mii;	// G/MII Incoming Data
input		en_in_mii;	// G/MII Incoming Data Valid
input		err_in_mii;	// G/MII Incoming Error

input		rx_clk_125 ;    // GMII Receive clock 125Mhz
input		rx_ce_sink ;
output		rx_ce_source ;

output [7:0]	data_out_mii;	// G/MII Outgoing Data
output		dv_out_mii; 	// G/MII Outgoing Data Valid
output		err_out_mii;	// G/MII Outgoing Error

input		hdinp0;		// Incoming SGMII (on SERDES)
input		hdinn0;		// Incoming SGMII (on SERDES)

output		hdoutp0;	// Outgoing SGMII (on SERDES)
output		hdoutn0;	// Outgoing SGMII (on SERDES)



//  8-bit Interface Signals from SGMII channel to QuadPCS/SERDES
wire [7:0]	data_chan2quad;
wire 		kcntl_chan2quad;
wire 		disparity_cntl_chan2quad;

//  8-bit Interface Signals from QuadPCS/SERDES to SGMII channel
wire [7:0]	data_quad2chan;
wire		kcntl_quad2chan;
wire		disp_err_quad2chan;
wire		cv_err_quad2chan;
wire		link_status;
wire		serdes_recovered_clk;
wire		xmit_autoneg;

wire adv_link_status;
wire adv_duplex_mode;
wire [1:0] adv_link_speed;

//  Active High Reset
wire 		rst;
assign rst = ~rst_n;


wire debug_link_timer_short;
wire [1:0] operational_rate;
wire [15:0] mr_lp_adv_ability;
wire mr_an_complete;

// Control Advertised Ability
//	When in PHY mode, choose appropriate values
//	When in MAC mode, always set to zeros
assign adv_link_status = gbe_mode ? 1'b0 : sgmii_mode ? 1'b1 : 1'b0;
assign adv_duplex_mode = gbe_mode ? 1'b0 : sgmii_mode ? 1'b1 : 1'b0;
assign adv_link_speed  = gbe_mode ? 2'd0 : sgmii_mode ? phy_speed : 2'd0;
wire [7:0] gbe_bits;
assign gbe_bits        = gbe_mode ? 8'h20 : 8'h01;

assign debug_link_timer_short = 1'b0;	//0= normal operation
					// when running simulation
					// will override this value to 1'b1
					// so that autonegotion completes

// Instantiate Global Reset Controller
GSR GSR_INST	(.GSR(rst_n));
PUR PUR_INST	(.PUR(1'b1));


// Instantiate SGMII IP Core
sgmii_gbe_pcs36 sgmii_gbe_pcs36_U (
	// Clock and Reset
	.rst_n (rst_n ),
	.tx_clk_125 (tx_clk_125),
	.tx_clock_enable_sink (tx_ce_sink),
	.tx_clock_enable_source (tx_ce_source),
	.rx_clk_125 (rx_clk_125),
	.rx_clock_enable_sink (rx_ce_sink),
	.rx_clock_enable_source (rx_ce_source),

	// Control
	.gbe_mode (gbe_mode),
	.sgmii_mode (sgmii_mode),
	.debug_link_timer_short (debug_link_timer_short), 
	.force_isolate (1'b0), 
	.force_loopback (force_loopback), 
	.force_unidir (1'b0), 
	.operational_rate (operational_rate),
	.rx_compensation_err (),
	.ctc_drop_flag (),
	.ctc_add_flag (),
	.an_link_ok (),


	// (G)MII TX Port
	.tx_d (data_in_mii),
	.tx_en (en_in_mii),
	.tx_er (err_in_mii),

	// (G)MII RX Port
	.rx_d (data_out_mii),
	.rx_dv (dv_out_mii),
	.rx_er (err_out_mii),
	.col (),
	.crs (),
                  
	// 8BI TX Port
	.tx_data (data_chan2quad),
	.tx_kcntl (kcntl_chan2quad),
	.tx_disparity_cntl (disparity_cntl_chan2quad),

	// 8BI RX Port
	.signal_detect (link_status),
	.serdes_recovered_clk (serdes_recovered_clk),
	.rx_data (data_quad2chan),
	.rx_kcntl (kcntl_quad2chan),
	.rx_even (1'b0), // Signal Not Used in Normal Mode
	.rx_disp_err (disp_err_quad2chan),
	.rx_cv_err (cv_err_quad2chan),
	.rx_err_decode_mode (1'b0), // 0= Normal Mode, always tie low for SC Familiy
	.xmit_autoneg (xmit_autoneg),

	// Management Interface  I/O
	.mr_adv_ability ({adv_link_status, 2'd0, adv_duplex_mode, adv_link_speed, 2'd0, gbe_bits}),
	.mr_an_enable (1'b1), 
	.mr_main_reset (1'b0),  
	.mr_restart_an (1'b0),   

	.mr_an_complete (mr_an_complete),   
	.mr_lp_adv_ability (mr_lp_adv_ability), 
	.mr_page_rx ()
	);


// (G)MII Rate Resolution for SGMII IP Core
rate_resolution   rate_resolution (
	.gbe_mode (gbe_mode),
	.sgmii_mode (sgmii_mode),
	.an_enable (1'b1),
	.advertised_rate (phy_speed),
	.link_partner_rate (mr_lp_adv_ability[11:10]),
	.non_an_rate (2'b10), // 1Gbps is rate when auto-negotiation disabled

	.operational_rate (operational_rate)
);


// QUAD ASB 8B10B + SERDES
pcs_serdes pcs_serdes (

// Global Clocks and Resets
	// inputs
	.rst_qd_c(rst), 
	.serdes_rst_qd_c(rst), 

	.refclkp(refclkp), 
	.refclkn(refclkn), 
	.refclk2fpga(), 



// fpga tx datapath signals
	// inputs
	.tx_pcs_rst_ch0_c(rst), 
	.txiclk_ch0(tx_clk_125), 
	.txdata_ch0(data_chan2quad), 
	.tx_k_ch0(kcntl_chan2quad), 
	.tx_disp_correct_ch0(disparity_cntl_chan2quad), 

	// outputs
	.tx_full_clk_ch0(), 
	.tx_half_clk_ch0(), 


// fpga rx datapath signals
	// inputs
	.rx_pcs_rst_ch0_c(rst), 
	.rxiclk_ch0(serdes_recovered_clk), 
	.xmit_ch0(xmit_autoneg), 

	// outputs
	.rx_full_clk_ch0(serdes_recovered_clk),
	.rx_half_clk_ch0(),
	.rxdata_ch0(data_quad2chan), 
	.rx_k_ch0(kcntl_quad2chan), 
	.rx_disp_err_ch0(disp_err_quad2chan), 
	.rx_cv_err_ch0(cv_err_quad2chan), 
	.lsm_status_ch0_s(link_status), 
	.rx_los_low_ch0_s(), 
	.rx_cdr_lol_ch0_s(), 


// serdes signals
	// inputs
	.tx_serdes_rst_c(rst), 
	.rx_serdes_rst_ch0_c(rst), 

	.hdinp_ch0(hdinp0), 
	.hdinn_ch0(hdinn0), 

	// outputs
	.hdoutp_ch0(hdoutp0), 
	.hdoutn_ch0(hdoutn0), 

// misc control signals
	// inputs
	.tx_pwrup_ch0_c(1'b1),		// powerup tx channel
	.rx_pwrup_ch0_c(1'b1),		// power up rx channel

	// outputs
	.tx_pll_lol_qd_s()
);






endmodule

