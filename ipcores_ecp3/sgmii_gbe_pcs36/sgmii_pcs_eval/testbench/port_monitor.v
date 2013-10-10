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

module port_monitor (
	rst_n,
	clk,

	len_in_ref,
	len_write_en_ref,

	data_in_ref,
	data_write_en_ref,
	err_in_ref,

	len_in_dut,
	len_write_en_dut,

	data_in_dut,
	data_write_en_dut,
	err_in_dut
);

input       rst_n;
input       clk;

input [16:0] len_in_ref;
input len_write_en_ref;

input [7:0] data_in_ref;
input       data_write_en_ref;
input       err_in_ref;

input [16:0] len_in_dut;
input len_write_en_dut;

input [7:0] data_in_dut;
input       data_write_en_dut;
input       err_in_dut;

/////////////////////////

parameter 
	READY		= 4'd0,
	CHECK_DUT_LEN	= 4'd1,
	PREAMBLE_REF	= 4'd2,
	PREAMBLE_DUT	= 4'd3,
	DEST_ADD	= 4'd4,
	SRC_ADD		= 4'd5,
	LEN		= 4'd6,
	SEQ_NUM		= 4'd7,
	PAYLD		= 4'd8,
	CHECK_FCS	= 4'd9,
	CHECK_CAR_EXT	= 4'd10,
	SUMMARY		= 4'd11;
reg [3:0]         fsm;

integer i;
integer preamb_count_ref;
integer preamb_count_dut;

reg  [15:0] payld_count_ref;
reg  [15:0] payld_count_dut;

reg  [47:0] dest_add_ref;
reg  [47:0] dest_add_dut;

reg  [47:0] src_add_ref;
reg  [47:0] src_add_dut;

reg  [15:0] fr_len_ref;
reg  [15:0] fr_len_dut;

reg  [7:0] seq_num_ref;
reg  [7:0] seq_num_dut;

reg  [31:0] fcs_dut;

reg  [31:0] FCS_d0_ref;
reg  [31:0] FCS_d1_ref;
reg  [31:0] FCS_d2_ref;
reg  [31:0] FCS_d3_ref;
reg  [31:0] FCS_d4_ref;

reg  [31:0] FCS_d0_dut;
reg  [31:0] FCS_d1_dut;
reg  [31:0] FCS_d2_dut;
reg  [31:0] FCS_d3_dut;
reg  [31:0] FCS_d4_dut;

reg  [7:0] data_in_ref_d1;
reg  [7:0] data_in_ref_d2;
reg  [7:0] data_in_ref_d3;
reg  [7:0] data_in_ref_d4;

reg [16:0] len_ref_fifo [0:2560];
reg [7:0] data_ref_fifo [0:256000];
reg err_ref_fifo [0:256000];

reg [16:0] len_dut_fifo [0:2560];
reg [7:0] data_dut_fifo [0:256000];
reg err_dut_fifo [0:256000];

integer hr, tr; // head for ref fifo, tail for ref fifo
integer hd, td; // head for dut fifo, tail for dut fifo

integer l_hr, l_tr; // head for ref length fifo, tail for ref length fifo
integer l_hd, l_td; // head for dut length fifo, tail for dut length fifo

integer words_available_ref;
integer words_available_dut;
integer len_words_available_ref;
integer len_words_available_dut;

reg data_read_en_ref;
reg data_read_en_dut;
reg len_read_en_ref;
reg len_read_en_dut;
reg [16:0] total_len_ref;
reg [16:0] total_len_dut;

reg [16:0] total_count_ref;
reg [16:0] total_count_dut;

wire [16:0] len_ref_fifo_out;
wire  [7:0] data_ref_fifo_out;
wire err_ref_fifo_out;

wire [16:0] len_dut_fifo_out;
wire  [7:0] data_dut_fifo_out;
wire err_dut_fifo_out;
wire read_inhibit_ref;
wire read_inhibit_dut;
reg data_mismatch;
reg capt_first_mismatch;
reg [7:0] data_capt_ref;
reg [7:0] data_capt_dut;
reg [15:0] mismatch_byte_num;

reg fcs_fail_ref;
reg fcs_fail_dut;

reg dest_add_fail;
reg src_add_fail;
reg fr_len_fail;
reg seq_num_fail;
reg car_ext_dut;



// capture incoming data
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0) begin
		hr <= 0; // head for ref fifo
		tr <= 0; // tail for ref fifo

		hd <= 0; // head for dut fifo
		td <= 0; // tail for dut fifo

		l_hr <= 0; // head for ref length fifo
		l_tr <= 0; // tail for ref length fifo

		l_hd <= 0; // head for dut length fifo
		l_td <= 0; // tail for dut length fifo

		words_available_ref <= 0;
		words_available_dut <= 0;
		len_words_available_ref <= 0;
		len_words_available_dut <= 0;
	end

	else begin

		// defaults
		words_available_ref <= hr - tr;
		words_available_dut <= hd - td;
		len_words_available_ref <= l_hr - l_tr;
		len_words_available_dut <= l_hd - l_td;

		////////////////////////
		// FIFO WRITES
		////////////////////////

		// capture reference data
		if (data_write_en_ref) begin
			data_ref_fifo[hr] <= data_in_ref;
			err_ref_fifo[hr] <= err_in_ref;
			if (hr == 256000) begin
				hr <= 0;
			end
			else begin
				hr <= hr + 1;
			end
		end

		// capture dut data
		if (data_write_en_dut) begin
			data_dut_fifo[hd] <= data_in_dut;
			err_dut_fifo[hd] <= err_in_dut;
			if (hd == 256000) begin
				hd <= 0;
			end
			else begin
				hd <= hd + 1;
			end
		end

		// capture reference lengths
		if (len_write_en_ref) begin
			len_ref_fifo[l_hr] <= len_in_ref;
			if (l_hr == 2560) begin
				l_hr <= 0;
			end
			else begin
				l_hr <= l_hr + 1;
			end
		end

		// capture dut lengths
		if (len_write_en_dut) begin
			len_dut_fifo[l_hd] <= len_in_dut;
			if (l_hd == 2560) begin
				l_hd <= 0;
			end
			else begin
				l_hd <= l_hd + 1;
			end
		end

		/////////////////////////////
		// FIFO READ ADDRESS CONTROL
		/////////////////////////////
		if (data_read_en_ref) begin
			if (tr == 256000) begin
				tr <= 0;
			end
			else begin
				tr <= tr + 1;
			end
		end
		if (data_read_en_dut) begin
			if (td == 256000) begin
				td <= 0;
			end
			else begin
				td <= td + 1;
			end
		end
		if (len_read_en_ref) begin
			if (l_tr == 2560) begin
				l_tr <= 0;
			end
			else begin
				l_tr <= l_tr + 1;
			end
		end
		if (len_read_en_dut) begin
			if (l_td == 2560) begin
				l_td <= 0;
			end
			else begin
				l_td <= l_td + 1;
			end
		end




	end
end


always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0) begin
		fsm <= READY;
		i  <= 0;
		preamb_count_ref  <= 0;
		preamb_count_dut  <= 0;

		payld_count_ref  <= 0;
		payld_count_dut  <= 0;

		dest_add_ref  <= 0;
		dest_add_dut  <= 0;

		src_add_ref  <= 0;
		src_add_dut  <= 0;

		fr_len_ref  <= 0;
		fr_len_dut  <= 0;

		seq_num_ref  <= 0;
		seq_num_dut  <= 0;

		fcs_dut  <= 0;

		FCS_d0_ref  <= 0;
		FCS_d1_ref  <= 0;
		FCS_d2_ref  <= 0;
		FCS_d3_ref  <= 0;
		FCS_d4_ref  <= 0;

		FCS_d0_dut  <= 0;
		FCS_d1_dut  <= 0;
		FCS_d2_dut  <= 0;
		FCS_d3_dut  <= 0;
		FCS_d4_dut  <= 0;

		data_in_ref_d1  <= 0;
		data_in_ref_d2  <= 0;
		data_in_ref_d3  <= 0;
		data_in_ref_d4  <= 0;

		data_read_en_ref <= 0;
		data_read_en_dut <= 0;
		len_read_en_ref <= 0;
		len_read_en_dut <= 0;

		total_len_ref <= 0;
		total_len_dut <= 0;

		total_count_ref <= 0;
		total_count_dut <= 0;

		data_mismatch <= 0;
		capt_first_mismatch <= 0;
		data_capt_ref <= 0;
		data_capt_dut <= 0;
		mismatch_byte_num <= 0;

		fcs_fail_ref <= 0;
		fcs_fail_dut <= 0;

		car_ext_dut <= 0;

		end
	else begin

		// defaults
		FCS_d1_ref <= FCS_d0_ref;
		FCS_d2_ref <= FCS_d1_ref;
		FCS_d3_ref <= FCS_d2_ref;
		FCS_d4_ref <= FCS_d3_ref;

		FCS_d1_dut <= FCS_d0_dut;
		FCS_d2_dut <= FCS_d1_dut;
		FCS_d3_dut <= FCS_d2_dut;
		FCS_d4_dut <= FCS_d3_dut;

		data_in_ref_d1 <= data_in_ref;
		data_in_ref_d2 <= data_in_ref_d1;
		data_in_ref_d3 <= data_in_ref_d2;
		data_in_ref_d4 <= data_in_ref_d3;

		data_read_en_ref <= 0;
		data_read_en_dut <= 0;
		len_read_en_ref <= 0;
		len_read_en_dut <= 0;

		data_mismatch <= 0;

		case(fsm)
			READY:
			  begin
				preamb_count_ref  <= 0;
				preamb_count_dut  <= 0;

				payld_count_ref  <= 0;
				payld_count_dut  <= 0;

				dest_add_ref  <= 0;
				dest_add_dut  <= 0;

				src_add_ref  <= 0;
				src_add_dut  <= 0;

				fr_len_ref  <= 0;
				fr_len_dut  <= 0;

				seq_num_ref  <= 0;
				seq_num_dut  <= 0;

				fcs_dut  <= 0;

				FCS_d0_ref  <= 0;
				FCS_d0_dut  <= 0;

				total_count_ref <= 0;
				total_count_dut <= 0;

				data_mismatch <= 0;
				capt_first_mismatch <= 0;
				data_capt_ref <= 0;
				data_capt_dut <= 0;
				mismatch_byte_num <= 0;

				fcs_fail_ref <= 0;
				fcs_fail_dut <= 0;

				car_ext_dut <= 0;
				
				if (len_words_available_ref > 0) begin
				  len_read_en_ref <= 1;
				  total_len_ref <= len_ref_fifo_out;
				  fsm <= CHECK_DUT_LEN;
				end
			  end

			CHECK_DUT_LEN:
			  begin

				if (len_words_available_dut > 0) begin
				  len_read_en_dut <= 1;
				  total_len_dut <= len_dut_fifo_out;

				  data_read_en_ref <= 1;

				  fsm <= PREAMBLE_REF;
				end

			  end

			PREAMBLE_REF:
			  begin
				total_count_ref <= total_count_ref + 1;

				if (data_ref_fifo_out == 8'hd5) begin
				  data_read_en_ref <= 0;
				  data_read_en_dut <= 1;
				  fsm <= PREAMBLE_DUT;
				end
				else begin
				  data_read_en_ref <= 1;
				  preamb_count_ref <= preamb_count_ref + 1;
				end
			  end


			PREAMBLE_DUT:
			  begin
				total_count_dut <= total_count_dut + 1;
				data_read_en_dut <= 1;

				if (data_dut_fifo_out == 8'hd5) begin
				  data_read_en_ref <= 1;
				  i <= 1;
				  fsm <= DEST_ADD;
				end
				else begin
				  preamb_count_dut <= preamb_count_dut + 1;
				end
			  end



			DEST_ADD:
			  begin
				data_read_en_ref <= ~read_inhibit_ref;
				data_read_en_dut <= ~read_inhibit_dut;

				if (!read_inhibit_ref) begin
					total_count_ref <= total_count_ref + 1;
				end 

				if (!read_inhibit_dut) begin
					total_count_dut <= total_count_dut + 1;
				end 

				i <= i + 1;
				case (i)
					1: begin dest_add_ref[47:40] <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					2: begin dest_add_ref[39:32] <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					3: begin dest_add_ref[31:24] <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					4: begin dest_add_ref[23:16] <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					5: begin dest_add_ref[15:8]  <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					6: begin dest_add_ref[7:0]   <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					default: dest_add_ref<= dest_add_ref;
				endcase
				case (i)
					1: begin dest_add_dut[47:40] <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					2: begin dest_add_dut[39:32] <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					3: begin dest_add_dut[31:24] <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					4: begin dest_add_dut[23:16] <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					5: begin dest_add_dut[15:8]  <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					6: begin dest_add_dut[7:0]   <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					default: dest_add_dut<= dest_add_dut;
				endcase

				if (i == 6) begin
				  i <= 1;
				  fsm <= SRC_ADD;
				end
			  end

			SRC_ADD:
			  begin
				data_read_en_ref <= ~read_inhibit_ref;
				data_read_en_dut <= ~read_inhibit_dut;

				if (!read_inhibit_ref) begin
					total_count_ref <= total_count_ref + 1;
				end 

				if (!read_inhibit_dut) begin
					total_count_dut <= total_count_dut + 1;
				end 

				i <= i + 1;
				case (i)
					1: begin src_add_ref[47:40] <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					2: begin src_add_ref[39:32] <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					3: begin src_add_ref[31:24] <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					4: begin src_add_ref[23:16] <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					5: begin src_add_ref[15:8]  <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					6: begin src_add_ref[7:0]   <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					default: src_add_ref<= src_add_ref;
				endcase
				case (i)
					1: begin src_add_dut[47:40] <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					2: begin src_add_dut[39:32] <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					3: begin src_add_dut[31:24] <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					4: begin src_add_dut[23:16] <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					5: begin src_add_dut[15:8]  <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					6: begin src_add_dut[7:0]   <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					default: src_add_dut<= src_add_dut;
				endcase
				if (i == 6) begin
				  i <= 1;
				  fsm <= LEN;
				end
			  end

			LEN:
			  begin
				data_read_en_ref <= ~read_inhibit_ref;
				data_read_en_dut <= ~read_inhibit_dut;

				if (!read_inhibit_ref) begin
					total_count_ref <= total_count_ref + 1;
				end 

				if (!read_inhibit_dut) begin
					total_count_dut <= total_count_dut + 1;
				end 

				i <= i + 1;
				case (i)
					1: begin fr_len_ref[15:8]  <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					2: begin fr_len_ref[7:0]   <= data_ref_fifo_out; FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out; end
					default: fr_len_ref <= fr_len_ref;
				endcase
				case (i)
					1: begin fr_len_dut[15:8]  <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					2: begin fr_len_dut[7:0]   <= data_dut_fifo_out; FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out; end
					default: fr_len_dut <= fr_len_dut;
				endcase
				if (i == 2) begin
				  i <= 1;
				  fsm <= SEQ_NUM;
				end
			  end

			SEQ_NUM:
			  begin
				data_read_en_ref <= ~read_inhibit_ref;
				data_read_en_dut <= ~read_inhibit_dut;

				if (!read_inhibit_ref) begin
					total_count_ref <= total_count_ref + 1;
				end 

				if (!read_inhibit_dut) begin
					total_count_dut <= total_count_dut + 1;
				end 

				seq_num_ref  <= data_ref_fifo_out;
				FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out;
				payld_count_ref <= 2;

				seq_num_dut  <= data_dut_fifo_out;
				FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out;
				payld_count_dut <= 2;

				fsm <= PAYLD;
			  end

			PAYLD:
			  begin
				data_read_en_ref <= ~read_inhibit_ref;
				data_read_en_dut <= ~read_inhibit_dut;

				if (!read_inhibit_ref) begin
					total_count_ref <= total_count_ref + 1;
				end 

				if (!read_inhibit_dut) begin
					total_count_dut <= total_count_dut + 1;
				end 

				FCS_d0_ref <= FCS_d0_ref + data_ref_fifo_out;
				FCS_d0_dut <= FCS_d0_dut + data_dut_fifo_out;

				//if (total_count_ref >= (total_len_ref - 5)) begin
				if (payld_count_ref == (fr_len_ref)) begin
				  i <= 1;
				  fsm <= CHECK_FCS;
				end
				else begin
					payld_count_ref <= payld_count_ref + 1;
					payld_count_dut <= payld_count_dut + 1;
				end

				if (data_ref_fifo_out != data_dut_fifo_out) begin

					if (!capt_first_mismatch) begin
						capt_first_mismatch <= 1;
						data_capt_ref <= data_ref_fifo_out;
						data_capt_dut <= data_dut_fifo_out;
						mismatch_byte_num <= payld_count_ref;
					end

				  	data_mismatch <= 1;
				end

			  end

			CHECK_FCS:
			  begin
				if ((i >= 1) && (i <= 3)) begin
					data_read_en_ref <= ~read_inhibit_ref;
					data_read_en_dut <= ~read_inhibit_dut;
				end

				if (!read_inhibit_ref) begin
					total_count_ref <= total_count_ref + 1;
				end 

				if (!read_inhibit_dut) begin
					total_count_dut <= total_count_dut + 1;
				end 

				case (i)
					1: begin if (FCS_d0_ref[31:24] != data_ref_fifo_out) fcs_fail_ref <= 1; end
					2: begin if (FCS_d0_ref[23:16] != data_ref_fifo_out) fcs_fail_ref <= 1; end
					3: begin if (FCS_d0_ref[15:8]  != data_ref_fifo_out) fcs_fail_ref <= 1; end
					4: begin if (FCS_d0_ref[7:0]   != data_ref_fifo_out) fcs_fail_ref <= 1; end
					default: fcs_fail_ref <= fcs_fail_ref;
				endcase
				case (i)
					1: begin fcs_dut[31:24] <= data_dut_fifo_out; if (FCS_d0_dut[31:24] != data_dut_fifo_out) fcs_fail_dut <= 1; end
					2: begin fcs_dut[23:16] <= data_dut_fifo_out; if (FCS_d0_dut[23:16] != data_dut_fifo_out) fcs_fail_dut <= 1; end
					3: begin fcs_dut[15:8]  <= data_dut_fifo_out; if (FCS_d0_dut[15:8]  != data_dut_fifo_out) fcs_fail_dut <= 1; end
					4: begin fcs_dut[7:0]   <= data_dut_fifo_out; if (FCS_d0_dut[7:0]   != data_dut_fifo_out) fcs_fail_dut <= 1; end
					default: fcs_fail_dut <= fcs_fail_dut;
				endcase

				i <= i + 1;

				if (i == 4) begin
					if ((total_len_dut - total_count_dut) > 1) begin
						data_read_en_dut <= 1;
				  		fsm <= CHECK_CAR_EXT;
					end
					else begin
				  		fsm <= SUMMARY;
					end
				end
			  end

			CHECK_CAR_EXT:
			  begin

				if (!read_inhibit_dut) begin
					total_count_dut <= total_count_dut + 1;
				end 

				if ((data_dut_fifo_out == 8'h0f) && (err_dut_fifo_out == 1'b1)) begin
					car_ext_dut <= 1;
				end


				if ((total_len_dut - total_count_dut) > 1) begin
					data_read_en_dut <= 1;
				end
				else begin
				  	fsm <= SUMMARY;
				end

			  end

			SUMMARY:
			  begin
				if (dest_add_fail || src_add_fail || fr_len_fail || seq_num_fail || capt_first_mismatch || fcs_fail_dut) begin
					$display("PORT MONITOR: recvd frame : ***** FAILED ***** @ %t", $time);
					if (dest_add_fail) begin
						$display("         expected_dest_addr 0x%0h : actual_dest_addr 0x%0h", dest_add_ref, dest_add_dut);
					end
					if (src_add_fail) begin
						$display("         expected_src_addr 0x%0h : actual_src_addr 0x%0h", src_add_ref, src_add_dut);
					end
					if (fr_len_fail) begin
						$display("         expected_frame_length 0x%0h : actual_frame_length 0x%0h", fr_len_ref, fr_len_dut);
					end
					if (seq_num_fail) begin
						$display("         expected_sequence_number 0x%0h : actual_sequence_number 0x%0h", seq_num_ref, seq_num_dut);
					end
					if (capt_first_mismatch) begin
						$display("         expected_data 0x%0h : actual_data 0x%0h    @ byte_number %d", data_capt_ref, data_capt_dut, mismatch_byte_num);
					end
					if (fcs_fail_dut) begin
						$display("         expected_FCS 0x%0h : actual_FCS 0x%0h", FCS_d0_ref, fcs_dut);
					end
				end
				else if (car_ext_dut) begin
					$display("\tPORT MONITOR: recvd frame :        GOOD  ---- CARRIER EXTENSION PRESENT ----        @ %t", $time);
				end

				else begin
					$display("\tPORT MONITOR: recvd frame :        GOOD        @ %t", $time);
				end

				//$display("--------------------------------------------------");
				$display("         preamble_size %0d", preamb_count_dut);
				$display("         dest_addr 0x%0h : src_addr 0x%0h", dest_add_dut, src_add_dut);
				$display("         sequence_num %0d : payload_len %0d : FCS 0x%0h ", seq_num_dut, payld_count_dut, FCS_d0_dut);
				$display("                                                  ");

				fsm <= READY;
			  end



			default :
			  begin
				fsm <= READY;
			  end
		endcase
	end
end 

always @(*) begin

	if (dest_add_ref == dest_add_dut) 
		dest_add_fail <= 0;
	else
		dest_add_fail <= 1;


	if (src_add_ref == src_add_dut) 
		src_add_fail <= 0;
	else
		src_add_fail <= 1;


	if (fr_len_ref == fr_len_dut) 
		fr_len_fail <= 0;
	else
		fr_len_fail <= 1;


	if (seq_num_ref == seq_num_dut) 
		seq_num_fail <= 0;
	else
		seq_num_fail <= 1;


end


// assign FIFO data out
assign len_ref_fifo_out = len_ref_fifo[l_tr];
assign  data_ref_fifo_out = data_ref_fifo [tr];
assign err_ref_fifo_out = err_ref_fifo [tr];

assign len_dut_fifo_out = len_dut_fifo[l_td];
assign  data_dut_fifo_out = data_dut_fifo [td];
assign err_dut_fifo_out = err_dut_fifo [td];

// continuous assignments
assign read_inhibit_ref = (total_count_ref <= total_len_ref) ? 0 : 1;
assign read_inhibit_dut = (total_count_dut <= total_len_dut) ? 0 : 1;


// synopsys translate_off
reg  [(22*8):1] fsm_monitor; 
always @(*) begin
   case (fsm)
      READY		: fsm_monitor = "READY";
      CHECK_DUT_LEN 	: fsm_monitor = "CHECK_DUT_LEN";
      PREAMBLE_REF	: fsm_monitor = "PREAMBLE_REF";         
      PREAMBLE_DUT	: fsm_monitor = "PREAMBLE_DUT";         
      DEST_ADD		: fsm_monitor = "DEST_ADD";
      SRC_ADD		: fsm_monitor = "SRC_ADD";
      LEN		: fsm_monitor = "LEN";
      SEQ_NUM		: fsm_monitor = "SEQ_NUM";
      PAYLD		: fsm_monitor = "PAYLD";         
      CHECK_FCS		: fsm_monitor = "CHECK_FCS";         
      CHECK_CAR_EXT	: fsm_monitor = "CHECK_CAR_EXT";         
      SUMMARY		: fsm_monitor = "SUMMARY";             

      default		: fsm_monitor = "***ERROR***";
   endcase
end
// synopsys translate_on


endmodule
// =============================================================================



