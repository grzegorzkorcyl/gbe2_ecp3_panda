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

//`timescale 1ns/100ps
`timescale 1ps/1ps

module mii_monitor (
	rst_n,
	clk,
	GBspeed,

	data_in_ref,
	dv_in_ref,
	err_in_ref,

	data_in_dut,
	dv_in_dut,
	err_in_dut
);

input       rst_n;
input       clk;
input	GBspeed;

input [7:0] data_in_ref;
input       dv_in_ref;
input       err_in_ref;

input [7:0] data_in_dut;
input       dv_in_dut;
input       err_in_dut;



wire [16:0] len_ref_pp;
wire len_write_ref_pp;

wire [7:0] data_ref_pp;
wire err_ref_pp;
wire data_write_ref_pp;

wire [16:0] len_dut_pp;
wire len_write_dut_pp;

wire [7:0] data_dut_pp;
wire err_dut_pp;
wire data_write_dut_pp;

wire dv_in_dut;
wire [7:0] data_in_dut;
wire err_in_dut;


port_parser_mii   pp_ref (
	.rst_n (rst_n),
	.clk (clk),
	.GBspeed (GBspeed),
	.enable_in (dv_in_ref),
	.data_in (data_in_ref),
	.err_in (err_in_ref),

	.err_out (err_ref_pp),
	.data_out (data_ref_pp),
	.length_out (len_ref_pp),
	.dat_wr (data_write_ref_pp),
	.len_wr (len_write_ref_pp)
);

port_parser_mii   pp_dut (
	.rst_n (rst_n),
	.clk (clk),
	.GBspeed (GBspeed),
	.enable_in (dv_in_dut),
	.data_in (data_in_dut),
	.err_in (err_in_dut),

	.err_out (err_dut_pp),
	.data_out (data_dut_pp),
	.length_out (len_dut_pp),
	.dat_wr (data_write_dut_pp),
	.len_wr (len_write_dut_pp)
);




port_monitor   port_monitor (
	.rst_n (rst_n),
	.clk (clk),

	.len_in_ref (len_ref_pp),
	.len_write_en_ref (len_write_ref_pp),

	.data_in_ref (data_ref_pp),
	.data_write_en_ref (data_write_ref_pp),
	.err_in_ref (err_ref_pp),

	.len_in_dut (len_dut_pp),
	.len_write_en_dut (len_write_dut_pp),

	.data_in_dut (data_dut_pp),
	.data_write_en_dut (data_write_dut_pp),
	.err_in_dut (err_dut_pp)
);

endmodule
