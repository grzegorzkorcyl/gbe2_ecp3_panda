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

`define SGMII_NO_ENC
`define SGMII_YES_CTC_DYNAMIC
`define SGMII_FIFO_FAMILY_ECP2M
`define SGMII_YES_SINGLE_CLOCK

module sgmii_gbe_pcs32 (

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
`ifdef SGMII_YES_SINGLE_CLOCK
	tx_clock_enable_sink ,
	tx_clock_enable_source ,

	rx_clock_enable_sink ,
	rx_clock_enable_source ,
`else
	tx_clk_mii ,
	rx_clk_mii ,
`endif
	tx_clk_125,
	tx_d,
	tx_en,
	tx_er,

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
`ifdef SGMII_YES_SINGLE_CLOCK
  input       tx_clock_enable_sink;
  output      tx_clock_enable_source;

  input       rx_clock_enable_sink;
  output      rx_clock_enable_source;
`else
  input       tx_clk_mii;
  input       rx_clk_mii;
`endif

input         tx_clk_125 ;
input [7:0]   tx_d ;
input         tx_en ;
input         tx_er ;

input          rx_clk_125 ;
output [7:0]   rx_d ;
output         rx_dv ;
output         rx_er ;
output         col ;
output         crs ;

// 8-bit Interface
output [7:0]   tx_data ;
output         tx_kcntl;
output         tx_disparity_cntl;
output         xmit_autoneg;

input         serdes_recovered_clk ;
input [7:0]   rx_data  ;
input         rx_even ;
input         rx_kcntl;
input         rx_disp_err ; // Displarity error on "rx_data".
input         rx_cv_err ;   // Code error on "rx_data".
input         rx_err_decode_mode ;

// Managment Control Outputs
output		mr_an_complete;
output		mr_page_rx;
output [15:0]	mr_lp_adv_ability;

// Managment Control Inputs
input		mr_main_reset;
input		mr_an_enable;
input		mr_restart_an;
input [15:0]	mr_adv_ability;


parameter STATIC_HI_THRESH = 32;
parameter STATIC_LO_THRESH = 16;
parameter LINK_TIMER_SH    = 21'h1fff01;

	

// SGMII PCS
sgmii_pcs_gda_001 # (.STATIC_HI_THRESH(STATIC_HI_THRESH), .STATIC_LO_THRESH(STATIC_LO_THRESH), .LINK_TIMER_SH(LINK_TIMER_SH)) sgmii_pcs_gda_001 (
   // Clock and Reset
   .rst_n                  ( rst_n ) ,
   .signal_detect          ( signal_detect ) ,
   .gbe_mode               ( gbe_mode ) ,
   .sgmii_mode             ( sgmii_mode ) ,
   .operational_rate       ( operational_rate ) ,
   .debug_link_timer_short ( debug_link_timer_short ) ,
   .force_isolate          ( force_isolate ) ,
   .force_loopback         ( force_loopback ) ,
   .force_unidir           ( force_unidir ) ,

   .rx_compensation_err    ( rx_compensation_err ) ,
   .ctc_drop_flag          ( ctc_drop_flag ) ,
   .ctc_add_flag           ( ctc_add_flag ) ,
   .an_link_ok             ( an_link_ok ) ,

`ifdef SGMII_YES_SINGLE_CLOCK
   .tx_clock_enable_sink   ( tx_clock_enable_sink ),
   .tx_clock_enable_source ( tx_clock_enable_source ),

   .rx_clock_enable_sink   ( rx_clock_enable_sink ),
   .rx_clock_enable_source ( rx_clock_enable_source ),
`else
   .tx_clk_mii             ( tx_clk_mii ),
   .rx_clk_mii             ( rx_clk_mii ),
`endif

   // GMII TX Inputs
   .tx_clk_125      ( tx_clk_125 ) ,
   .tx_d            ( tx_d) ,
   .tx_en           ( tx_en) ,
   .tx_er           ( tx_er) ,

   // GMII RX Outputs
   // To GMII/MAC interface
   .rx_clk_125      ( rx_clk_125 ) ,
   .rx_d            ( rx_d ) ,
   .rx_dv           ( rx_dv ) ,
   .rx_er           ( rx_er ) ,
   .col             ( col ) ,
   .crs             ( crs ) ,
                  
   // 8BI TX Outputs
   .tx_data           ( tx_data) ,
   .tx_kcntl          ( tx_kcntl) ,
   .tx_disparity_cntl ( tx_disparity_cntl) ,
   .xmit_autoneg      ( xmit_autoneg) ,

   // 8BI RX Inputs
   .serdes_recovered_clk ( serdes_recovered_clk ) ,
   .rx_data              ( rx_data ) ,
   .rx_kcntl             ( rx_kcntl ) ,
   .rx_even              ( rx_even ) ,
   .rx_disp_err          ( rx_disp_err ) ,
   .rx_cv_err            ( rx_cv_err ) ,
   .rx_err_decode_mode   ( rx_err_decode_mode ) ,

   // Management Interface  I/O
   .mr_adv_ability    (mr_adv_ability),
   .mr_an_enable      (mr_an_enable), 
   .mr_main_reset     (mr_main_reset),  
   .mr_restart_an     (mr_restart_an),   

   .mr_an_complete    (mr_an_complete),   
   .mr_lp_adv_ability (mr_lp_adv_ability), 
   .mr_page_rx        (mr_page_rx)
   );


endmodule
