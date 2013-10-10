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

`timescale 1ps/1ps

module tb ;

reg        clk_125 ;
reg        hclk ;
wire  hready_n;
wire [7:0] hdataout;
reg [9:0] haddr;
reg [7:0] hdatain;
reg hcs_n;
reg hread_n;
reg hwrite_n;
reg hdataout_en_n;

reg        rst_n ;
reg        rst_tb_n;

reg         clk_25;
reg         clk_12_5;
reg         clk_2_5;
reg         clk_1_25;
reg [3:0]   clk_count;
reg [5:0]   sclk_count;

///////////////////////

reg [7:0]   drv_data;
reg         drv_en;
reg         drv_er;

wire [7:0]   local_tx_d;
wire         local_tx_en;
wire         local_tx_er;

wire [7:0]   mn_data;
wire         mn_dv;
wire         mn_er;

wire [7:0]   mon_data;
wire         mon_dv;
wire         mon_er;

///////////////////////

wire [7:0]   local_rx_d;
wire         local_rx_dv;
wire         local_rx_er;

reg		clk_mii;
reg		clk_drvmon;
reg [1:0]	adv_speed;
reg [1:0]	mii_speed;
reg 		dut_sgmii_mode;
reg 		dut_gbe_mode;
reg		GBspeed_drvmon;
reg		force_loopback;


//////////////////////////////////////////////////////////////////////////////

initial
begin
   clk_125 = 1'b0 ;
   hclk     = 1'b0 ;
   $timeformat (-9 ,1 , "ns", 10);
end

// 125 Mhz clock Generation
always #4000 clk_125 = ~clk_125 ;

// HCLK Clock Generation
always #10000 hclk = ~hclk ;

// 25Mhz Clock Generation
always @(posedge clk_125 or negedge rst_tb_n)
begin
	if (rst_tb_n == 1'b0) begin
		clk_count <= 4'd0;
		clk_25 <= 1'd0;
		clk_12_5 <= 1'd0;
	end
	else begin

		// These statements implement a "divide by 5"
		if (clk_count == 4'd4)
			clk_count <= 4'd0;
		else
			clk_count <= clk_count + 1;


		if ((clk_count==4'd1) || (clk_count==4'd4))
			clk_25 <= ~clk_25;

		if ((clk_25 == 1'd0) && (clk_count == 4'd1))
			clk_12_5 <= ~clk_12_5;


	end
end 



// 2.5Mhz Clock Generation
always @(posedge clk_125 or negedge rst_tb_n)
begin
	if (rst_tb_n == 1'b0) begin
		sclk_count <= 0;
		clk_2_5 <= 0;
		clk_1_25 <= 0;
	end
	else begin

		// These statements implement a "divide by 50"
		if (sclk_count == 49)
			sclk_count <= 0;
		else
			sclk_count <= sclk_count + 1;


		if ((sclk_count==24) || (sclk_count==49))
			clk_2_5 <= ~clk_2_5;

		if ((clk_2_5 == 0) && (sclk_count == 1))
			clk_1_25 <= ~clk_1_25;

	end
end 


// choose mii clock based on DUT_MII_SPEED
always @(*)
begin
	if (mii_speed == 2'b01)
		clk_mii = 1'b1;
	else if (mii_speed == 2'b00)
		clk_mii = 1'b1;
	else
		clk_mii = 1'b1;
end

// choose driver and monitor clock
always @(*)
begin
	if (mii_speed == 2'b01)
		clk_drvmon = clk_12_5;
	else if (mii_speed == 2'b00)
		clk_drvmon = clk_1_25;
	else
		clk_drvmon = clk_125;
end


GSR GSR_INST	(.GSR(rst_n));
PUR PUR_INST	(.PUR(1'b1));
OLVDS O_CLK_BUF (.A(clk_125), .Z(clk_125_p), .ZN(clk_125_n));

//////////////////////////////////////////////////////////////////////////////

// Device Under Test (DUT)
top_hb top (
   .rst_n ( rst_n ) ,
   .gbe_mode ( dut_gbe_mode ) ,
   .sgmii_mode ( dut_sgmii_mode ) ,

   .hclk (hclk),
   .hcs_n (hcs_n),
   .hwrite_n (hwrite_n),
   .haddr (haddr[5:0]),
   .hdatain (hdatain),

   .hdataout (hdataout),
   .hready_n (hready_n),

   // G/MII Interface
   .data_in_mii ( {local_tx_d} ) ,
   .en_in_mii ( local_tx_en ) ,
   .err_in_mii ( local_tx_er ) ,
                  
   .data_out_mii ( local_rx_d ) ,
   .dv_out_mii ( local_rx_dv ) ,
   .err_out_mii ( local_rx_er ) ,
   .col_out_mii (  ) ,
   .crs_out_mii (  ) ,

   .debug_link_timer_short(1'b1),
   .mr_an_complete(mr_an_complete),

   // GMII Clocks
   .in_clk_125    ( clk_125 ) ,
   .in_ce_sink    ( clock_enable ) ,
   .in_ce_source  ( clock_enable ) ,
   .out_clk_125   ( clk_125 ) ,
   .out_ce_sink   ( clock_enable ) ,
   .out_ce_source ( ) ,

   // SERDES Interface
   .refclkp ( clk_125_p ) ,
   .refclkn ( clk_125_n ) ,
   .hdoutp0 ( local_serdes_p ) ,
   .hdoutn0 ( local_serdes_n ) ,
   .hdinp0 ( remote_serdes_p ),
   .hdinn0 ( remote_serdes_n )
   );


// Loopback DUT (G)MII Interface
assign local_tx_d = local_rx_d;
assign local_tx_en = local_rx_dv;
assign local_tx_er = local_rx_er;


// Testbench SGMII Channel
sgmii_node sgmii_node (
	// Control Interface
	.rst_n (rst_n) ,
	.gbe_mode (dut_gbe_mode) ,
	.sgmii_mode (~dut_sgmii_mode) ,
	.force_loopback (force_loopback) ,
	.phy_speed (adv_speed) ,

	// G/MII Interface
	.data_in_mii (drv_data),
	.en_in_mii (drv_en),
	.err_in_mii (drv_er),

	.data_out_mii (mon_data),
	.dv_out_mii (mon_dv),
	.err_out_mii (mon_er),

	// GB Timing References
	.tx_clk_125 (clk_125) ,
	.tx_ce_source () ,
	.tx_ce_sink (clock_enable) ,

	.rx_clk_125 (clk_125) ,
	.rx_ce_source () ,
	.rx_ce_sink (clock_enable) ,
                  
	// SERDES Interface
	.refclkp (clk_125_p) ,
	.refclkn (clk_125_n) ,
	.hdoutp0 (remote_serdes_p) ,
	.hdoutn0 (remote_serdes_n) ,
	.hdinp0 (local_serdes_p ),
	.hdinn0 (local_serdes_n )
);






// Compare MII In/Out Ports of DUT
mii_monitor   mii_monitor (
	.rst_n (rst_n),
	.clk (clk_drvmon),
	.GBspeed (GBspeed_drvmon) ,

	.data_in_ref (drv_data),
	.dv_in_ref (drv_en),
	.err_in_ref (drv_er),

	.data_in_dut (mon_data),
	.dv_in_dut (mon_dv),
	.err_in_dut (mon_er)
);



//////////////////////////////////////////////////////////////////////////////

// THIS BLOCK CONTROLS TEST SCRIPT FLOW
initial
begin
	rst_tb_n   = 1'b0 ;
	rst_n = 0;

	haddr = 10'd0;
	hdatain = 8'd0;
	hcs_n = 1'b1;
	hread_n = 1'b1;
	hwrite_n = 1'b1;
	hdataout_en_n = 1'b1;

	drv_data = 8'd0;
	drv_en = 1'd0;
	drv_er = 1'd0;

	force_loopback = 1'b0;

	// the following lines allow short autonegotiation timer to operate
	force sgmii_node.debug_link_timer_short = 1'b1 ;

/////// SET SGMII MODE  == 1GB Rate /////////////////////////////////////////////////////////////////////

	GBspeed_drvmon = 1;
	mii_speed = 2'b10; // 1GB
	adv_speed = 2'b10; // 1GB
	dut_sgmii_mode = 1'b0; // MAC
	dut_gbe_mode = 1'b0;   // SGMII

	#1000000               // Wait for 100 nanoseconds
	$display(" ") ;
	$display(" !!!!!!!!!!  Starting SGMII Tests  !!!!!!!!!!");
	$display(" ") ;
	$display(" ") ;
	$display(" ") ;
	$display(" ") ;
	$display("    MII operating @ 1Gbps in SGMII Mode") ;
	$display(" ") ;
	$display("    Device Under Test operating in SGMII MAC mode") ;
	$display(" ") ;


	// release testbench reset
	#1000000               // Wait for 100 nanoseconds
	rst_tb_n   <= 1'b1 ;

	// Perform Device Resets
	#1000000               // Wait for 1 microsecond
	rst_n = 0;             // Apply reset
	#1000000               // Wait for 1 microsecond
	rst_n = 1;             // Release reset
	#1000000               // Wait for 1 microsecond


////////////////////

	#1000000               // Wait for 1 microsecond

	@(posedge hclk);
// Quick Check of SGMII Management Registers
	$display(" TEST#1 of 3 : Check SGMII Management Registers before Autonegotiaion Completes ");

	hb_read (10'h000, 8'h00, 8'h00); // Reg 0
	hb_read (10'h001, 8'h00, 8'h00);
	$display("  ") ;

	hb_read (10'h002, 8'h00, 8'h00); // Reg 1
	hb_read (10'h003, 8'h00, 8'h00);
	$display("  ") ;

	hb_read (10'h008, 8'h00, 8'h00); // Reg 4
	hb_read (10'h009, 8'h00, 8'h00);
	$display("  ") ;

	hb_read (10'h00A, 8'h00, 8'h00); // Reg 5
	hb_read (10'h00B, 8'h00, 8'h00);
	$display("  ") ;

	hb_read (10'h00C, 8'h00, 8'h00); // Reg 6
	hb_read (10'h00D, 8'h00, 8'h00);
	$display("  ") ;


// Wait for Auto Negotiation to Complete
	wait (mr_an_complete) 

	@(posedge hclk);
// Quick Check of SGMII Management Registers
	#2000000              // Wait for 2.00 microseconds
	$display(" TEST#2 of 3 : Check SGMII Management Registers after Autonegotiaion Completes ");

	hb_read (10'h000, 8'h40, 8'hFF); // Reg 0
	hb_read (10'h001, 8'h11, 8'hFF);
	$display("  ") ;

	hb_read (10'h002, 8'h2C, 8'h00); // Reg 1
	hb_read (10'h003, 8'h00, 8'h00);

	hb_read (10'h002, 8'h2C, 8'hFF); // Reg 1 Re-Read
	hb_read (10'h003, 8'h01, 8'hFF);
	$display("  ") ;

	hb_read (10'h008, 8'h01, 8'hFF); // Reg 4
	hb_read (10'h009, 8'h40, 8'hFF);
	$display("  ") ;

	hb_read (10'h00A, 8'h01, 8'hFF); // Reg 5
	hb_read (10'h00B, 8'hD8, 8'hFF);
	$display("  ") ;

	hb_read (10'h00C, 8'h02, 8'hFF); // Reg 6
	hb_read (10'h00D, 8'h00, 8'hFF);

	hb_read (10'h01E, 8'h00, 8'hFF); // Reg F
	hb_read (10'h01F, 8'h80, 8'hFF);
	$display("  ") ;


	#10000000              // Wait for 10.00 microseconds


	@(posedge clk_drvmon );
// Send 4 Ethernet Frames
	$display(" TEST#3 of 3 : Send 4 ethernet frames");
	//send_local_gmii_frame (preamble size, dest addr, src addr, payload len, sequence number); 
	send_mii_frame (7, 'h112233445566, 'h778899aabbcc, 512, 0); 
	send_mii_frame (7, 'h112233445566, 'h778899aabbcc, 512, 1); 
	send_mii_frame (7, 'h112233445566, 'h778899aabbcc, 512, 2); 
	send_mii_frame (7, 'h112233445566, 'h778899aabbcc, 512, 3); 

	repeat (2000) @(posedge clk_drvmon );



	$display("\n\n\n\n") ;
	$display(" TEST#4  : Test Loopback Function");
	force_loopback = 1'b1;
	repeat (500) @(posedge clk_drvmon );

	send_mii_frame (7, 'h112233445566, 'h778899aabbcc, 512, 4); 
	repeat (500) @(posedge clk_drvmon );

	force_loopback = 1'b0;
	repeat (500) @(posedge clk_drvmon );

	send_mii_frame (7, 'h112233445566, 'h778899aabbcc, 512, 5); 
	repeat (1000) @(posedge clk_drvmon );






	$display("\n\n\n\n") ;
	$display(" TEST#5  : Test Isolate Function");
	hb_write (10'h001, 8'h15);
	hb_read (10'h000, 8'h40, 8'hFF);
	hb_read (10'h001, 8'h15, 8'hFF);

	send_mii_frame (7, 'h112233445566, 'h778899aabbcc, 512, 6); 
	repeat (500) @(posedge clk_drvmon );

	hb_write (10'h001, 8'h11);
	hb_read (10'h000, 8'h40, 8'hFF);
	hb_read (10'h001, 8'h11, 8'hFF);

	repeat (500) @(posedge clk_drvmon );

	send_mii_frame (7, 'h112233445566, 'h778899aabbcc, 512, 7); 
	repeat (1000) @(posedge clk_drvmon );
	$display("**** Expected Frame Mismatch Failure, Due to Isolate Function****");





	$display("\n\n\n\n") ;
	$display(" !!!!!!!!!!  Testbench Done.  All Tests Completed  !!!!!!!!!!");
	$stop ;
end

// END OF TEST SCRIPT FLOW ////////////////////////////////////////////////////////////











//////////////////////////////////////////////////////////////////////////////
task send_mii_frame ;
input [7:0]   preamble_len; // Total number of bytes
input [47:0]  dest_add;
input [47:0]  src_add;
input [15:0]  payld_len;
input [15:0]  sequence_num;

integer    i;
reg[31:0]  j;
reg [31:0] FCS;

begin

// Put Preamble ///////////////////
for(i = 0; i < preamble_len; i = i+1) begin
	if (GBspeed_drvmon) begin
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 8'h55;
		FCS  = #1 32'd0;
		@(posedge clk_drvmon);
	end
	else begin
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 8'h05;
		FCS  = #1 32'd0;
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 8'h05;
		FCS  = #1 32'd0;
		@(posedge clk_drvmon);
	end
end

// Put SFD ////////////////////////
	if (GBspeed_drvmon) begin
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 8'hd5;
		@(posedge clk_drvmon);
	end
	else begin
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 8'h05; // low nibble
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 8'h0d; // high nibble
		@(posedge clk_drvmon);
	end

// Put Destination Address ///////////////////////
for(i = 0; i < 6; i = i+1) begin

	drv_en = #1 1'b1;   
	drv_er = #1 1'b0;   

	if (GBspeed_drvmon) begin
		case (i)
			0: begin drv_data  = #1 dest_add[47:40]; FCS = #1 (FCS + dest_add[47:40]);  @(posedge clk_drvmon); end
			1: begin drv_data  = #1 dest_add[39:32]; FCS = #1 (FCS + dest_add[39:32]);  @(posedge clk_drvmon); end
			2: begin drv_data  = #1 dest_add[31:24]; FCS = #1 (FCS + dest_add[31:24]);  @(posedge clk_drvmon); end
			3: begin drv_data  = #1 dest_add[23:16]; FCS = #1 (FCS + dest_add[23:16]);  @(posedge clk_drvmon); end
			4: begin drv_data  = #1 dest_add[15:8];  FCS = #1 (FCS + dest_add[15:8]);   @(posedge clk_drvmon); end
			5: begin drv_data  = #1 dest_add[7:0];   FCS = #1 (FCS + dest_add[7:0]);    @(posedge clk_drvmon); end
		endcase

	end
	else begin
		case (i)
			0:  begin 
				drv_data  = #1 {4'd0, dest_add[43:40]};
				@(posedge clk_drvmon);
				drv_data  = #1 {4'd0, dest_add[47:44]}; FCS = #1 (FCS + dest_add[47:40]);
				@(posedge clk_drvmon);
			    end

			1:  begin 
				drv_data  = #1 {4'd0, dest_add[35:32]};
				@(posedge clk_drvmon);
				drv_data  = #1 {4'd0, dest_add[39:36]}; FCS = #1 (FCS + dest_add[39:32]);
				@(posedge clk_drvmon);
			    end

			2:  begin 
				drv_data  = #1 {4'd0, dest_add[27:24]};
				@(posedge clk_drvmon);
				drv_data  = #1 {4'd0, dest_add[31:28]}; FCS = #1 (FCS + dest_add[31:24]);
				@(posedge clk_drvmon);
			    end

			3:  begin 
				drv_data  = #1 {4'd0, dest_add[19:16]};
				@(posedge clk_drvmon);
				drv_data  = #1 {4'd0, dest_add[23:20]}; FCS = #1 (FCS + dest_add[23:16]);
				@(posedge clk_drvmon);
			    end

			4:  begin 
				drv_data  = #1 {4'd0, dest_add[11:8]};
				@(posedge clk_drvmon);
				drv_data  = #1 {4'd0, dest_add[15:12]}; FCS = #1 (FCS + dest_add[15:8]);
				@(posedge clk_drvmon);
			    end

			5: begin 
				drv_data  = #1 {4'd0, dest_add[3:0]};
				@(posedge clk_drvmon);
				drv_data  = #1 {4'd0, dest_add[7:4]};   FCS = #1 (FCS + dest_add[7:0]);
				@(posedge clk_drvmon);
			    end
		endcase
	end
end

// Put Source Address ///////////////////////
for(i = 0; i < 6; i = i+1) begin

	drv_en = #1 1'b1;   
	drv_er = #1 1'b0;   

	if (GBspeed_drvmon) begin
		case (i)
			0: begin drv_data  = #1 src_add[47:40]; FCS = #1 (FCS + src_add[47:40]);  @(posedge clk_drvmon); end
			1: begin drv_data  = #1 src_add[39:32]; FCS = #1 (FCS + src_add[39:32]);  @(posedge clk_drvmon); end
			2: begin drv_data  = #1 src_add[31:24]; FCS = #1 (FCS + src_add[31:24]);  @(posedge clk_drvmon); end
			3: begin drv_data  = #1 src_add[23:16]; FCS = #1 (FCS + src_add[23:16]);  @(posedge clk_drvmon); end
			4: begin drv_data  = #1 src_add[15:8];  FCS = #1 (FCS + src_add[15:8]);   @(posedge clk_drvmon); end
			5: begin drv_data  = #1 src_add[7:0];   FCS = #1 (FCS + src_add[7:0]);    @(posedge clk_drvmon); end
		endcase

	end
	else begin
		case (i)
			0:  begin 
				drv_data  = #1 {4'd0, src_add[43:40]};
				@(posedge clk_drvmon);
				drv_data  = #1 {4'd0, src_add[47:44]}; FCS = #1 (FCS + src_add[47:40]);
				@(posedge clk_drvmon);
			    end

			1:  begin 
				drv_data  = #1 {4'd0, src_add[35:32]};
				@(posedge clk_drvmon);
				drv_data  = #1 {4'd0, src_add[39:36]}; FCS = #1 (FCS + src_add[39:32]);
				@(posedge clk_drvmon);
			    end

			2:  begin 
				drv_data  = #1 {4'd0, src_add[27:24]};
				@(posedge clk_drvmon);
				drv_data  = #1 {4'd0, src_add[31:28]}; FCS = #1 (FCS + src_add[31:24]);
				@(posedge clk_drvmon);
			    end

			3:  begin 
				drv_data  = #1 {4'd0, src_add[19:16]};
				@(posedge clk_drvmon);
				drv_data  = #1 {4'd0, src_add[23:20]}; FCS = #1 (FCS + src_add[23:16]);
				@(posedge clk_drvmon);
			    end

			4:  begin 
				drv_data  = #1 {4'd0, src_add[11:8]};
				@(posedge clk_drvmon);
				drv_data  = #1 {4'd0, src_add[15:12]}; FCS = #1 (FCS + src_add[15:8]);
				@(posedge clk_drvmon);
			    end

			5: begin 
				drv_data  = #1 {4'd0, src_add[3:0]};
				@(posedge clk_drvmon);
				drv_data  = #1 {4'd0, src_add[7:4]};   FCS = #1 (FCS + src_add[7:0]);
				@(posedge clk_drvmon);
			    end
		endcase
	end
end

// Put Length ////////////////////////
	if (GBspeed_drvmon) begin
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 payld_len[15:8];
		FCS  = #1 FCS + payld_len[15:8];
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 payld_len[7:0];
		FCS  = #1 FCS + payld_len[7:0];
		@(posedge clk_drvmon);
	end
	else begin
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, payld_len[11:8]};
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, payld_len[15:12]};
		FCS  = #1 FCS + payld_len[15:8];
		@(posedge clk_drvmon);

		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, payld_len[3:0]};
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, payld_len[7:4]};
		FCS  = #1 FCS + payld_len[7:0];
		@(posedge clk_drvmon);
	end

// Put Sequence Num (part of the payload) ////
	if (GBspeed_drvmon) begin
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 sequence_num[7:0];
		FCS  = #1 FCS + sequence_num[7:0];
		@(posedge clk_drvmon);
	end
	else begin
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, sequence_num[3:0]};
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, sequence_num[7:4]};
		FCS  = #1 FCS + sequence_num[7:0];
		@(posedge clk_drvmon);
	end

// Put Payload ///////////////////////
for(j = 1; j < payld_len; j = j+1) begin
	if (GBspeed_drvmon) begin
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 j;
		FCS  = #1 FCS + j[7:0];
		@(posedge clk_drvmon);
	end
	else begin
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, j[3:0]}; // low nibble
		@(posedge clk_drvmon);

		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, j[7:4]}; // high nibble
		FCS  = #1 FCS + j[7:0];
		@(posedge clk_drvmon);
	end
end

// Put FCS ///////////////////////
	if (GBspeed_drvmon) begin
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 FCS[31:24];
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 FCS[23:16];
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 FCS[15:8];
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 FCS[7:0];
		@(posedge clk_drvmon);
	end
	else begin
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, FCS[27:24]};
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, FCS[31:28]};
		@(posedge clk_drvmon);

		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, FCS[19:16]};
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, FCS[23:20]};
		@(posedge clk_drvmon);

		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, FCS[11:8]};
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, FCS[15:12]};
		@(posedge clk_drvmon);

		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, FCS[3:0]};
		@(posedge clk_drvmon);
		drv_en = #1 1'b1;   
		drv_er = #1 1'b0;   
		drv_data  = #1 {4'd0, FCS[7:4]};
		@(posedge clk_drvmon);
	end

// Put Carrier Extension ///////////////////////
//
//
////////////////////////////////////////////////

// Put Inter packet gap ///////////
for(i = 1; i <= 12; i = i+1) begin
	drv_en = #1 1'b0;   
	drv_er = #1 1'b0;
	@(posedge clk_drvmon);
end



end
endtask





task hb_write;

input [9:0] address;
input [7:0] data;

begin
      @(posedge hclk);
      
      #1
      haddr[9:0] = address[9:0];
      hdatain[7:0] = data[7:0];

      hcs_n = 1'b0; // assert
      hread_n = 1'b1;
      hwrite_n = 1'b0; // assert
      hdataout_en_n = 1'b1;

      // wait for an acknowledge
      @ (negedge hready_n); 

      @(posedge hclk);
      #1
      hcs_n = 1'b1; 
      hread_n = 1'b1;
      hwrite_n = 1'b1;
      hdataout_en_n = 1'b1;

      @(posedge hclk);
      #1
      hcs_n = 1'b1; 
      hread_n = 1'b1;
      hwrite_n = 1'b1;
      hdataout_en_n = 1'b1;
end

endtask





task hb_read;

input [9:0] address;
input [7:0] expected_data;
input [7:0] mask;

reg [7:0]  read_data;

begin
      @(posedge hclk);
      
      #1
      haddr[9:0] = address[9:0];

      hcs_n = 1'b0; // assert
      hread_n = 1'b0;
      hwrite_n = 1'b1;
      hdataout_en_n = 1'b0; // assert

      // wait for an acknowledge
      @ (negedge hready_n); 

      @(posedge hclk);
      #1
      read_data[7:0] = hdataout[7:0];
      hcs_n = 1'b1; 
      hread_n = 1'b1;
      hwrite_n = 1'b1;
      hdataout_en_n = 1'b1;

      if ((read_data & mask) != (expected_data & mask)) begin
         $display ("ERROR : Read-data mismatch at address %h", address) ;
         $display ("      : Expected Data : %h. Read Data : %h.", (expected_data & mask), read_data ) ;
      end
      else begin
         $display (" INFO : Read Check Passed at address %h", address) ;
      end


      @(posedge hclk);
      #1
      hcs_n = 1'b1; 
      hread_n = 1'b1;
      hwrite_n = 1'b1;
      hdataout_en_n = 1'b1;
end

endtask





endmodule
// =============================================================================

