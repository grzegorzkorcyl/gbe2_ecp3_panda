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

module port_parser_mii (
	rst_n,
	clk,
	enable_in,
	data_in,
	err_in,
	GBspeed,

	err_out,
	data_out,
	length_out,
	dat_wr,
	len_wr
);

input       rst_n;
input       clk;
input       enable_in;
input       err_in;
input [7:0] data_in;
input	GBspeed;

output err_out;
output [7:0] data_out;
output [16:0] length_out;
output dat_wr;
output len_wr;

reg err_out;
reg [7:0] data_out;
reg dat_wr;
reg len_wr;

reg [16:0] count;

parameter 
    SEEK_EN	= 3'd0,
    DO_WRITE_LO	= 3'd1,
    DO_WRITE_HI	= 3'd2,
    CAR_EXT_LO	= 3'd3,
    CAR_EXT_HI	= 3'd4,
    DO_WRITE_GB	= 3'd5,
    CAR_EXT_GB	= 3'd6;
reg [2:0]          cfsm;



always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0) begin
		cfsm <= SEEK_EN;
		count <= 17'd0;
		data_out <= 8'd0;
		err_out <= 1'b0;
		dat_wr <= 1'b0;
		len_wr <= 1'b0;
	end
	else begin
		// defaults
		//data_out <= data_in;
		err_out <= err_in;
		dat_wr <= 1'b0;
		len_wr <= 1'b0;

		case(cfsm)
			SEEK_EN:
			  begin
				count <= 17'd1;
				if (enable_in) begin
					if (GBspeed) begin
						// 1GBPS Mode
						dat_wr <= 1'b1;
						data_out <= data_in;
						cfsm <= DO_WRITE_GB;
					end
					else begin
						// 100MBPS or 10MBPS Mode
				  		data_out[3:0] <= data_in[3:0];
				  		cfsm <= DO_WRITE_HI;
					end
				end
			  end





			DO_WRITE_LO:
			  begin
				data_out[3:0] <= data_in[3:0];

				if (enable_in) begin
					count <= count + 1;
					cfsm <= DO_WRITE_HI;
				end
				else begin
					if (err_in) begin
						count <= count + 1;
				        	cfsm <= CAR_EXT_HI;
					end
					else begin
				        	cfsm <= DO_WRITE_HI;
					end
				end
			  end
			DO_WRITE_HI:
			  begin
				if (enable_in) begin
					dat_wr <= 1'b1;
					data_out[7:4] <= data_in[3:0];
				        cfsm <= DO_WRITE_LO;
				end
				else begin
					if (err_in) begin
						dat_wr <= 1'b1;
				        	cfsm <= CAR_EXT_LO;
					end
					else begin
						len_wr <= 1'b1;
				        	cfsm <= SEEK_EN;
					end
				end
			  end



			CAR_EXT_LO:
			  begin
				if (err_in) begin
					count <= count + 1;
				end
				data_out[3:0] <= data_in[3:0];
				cfsm <= CAR_EXT_HI;
			  end
			CAR_EXT_HI:
			  begin
				if (err_in) begin
					dat_wr <= 1'b1;
					data_out[7:4] <= data_in[3:0];
				        cfsm <= CAR_EXT_LO;
				end
				else begin
					len_wr <= 1'b1;
				        cfsm <= SEEK_EN;
				end
			  end


			DO_WRITE_GB:
			  begin
				data_out <= data_in;
				if (enable_in) begin
					dat_wr <= 1'b1;
					count <= count + 1;
				end
				else begin
					if (err_in) begin
						dat_wr <= 1'b1;
						count <= count + 1;
				        	cfsm <= CAR_EXT_GB;
					end
					else begin
						len_wr <= 1'b1;
				        	cfsm <= SEEK_EN;
					end
				end
			  end
			CAR_EXT_GB:
			  begin
				data_out <= data_in;
				if (err_in) begin
					dat_wr <= 1'b1;
					count <= count + 1;
				        cfsm <= CAR_EXT_GB;
				end
				else begin
					len_wr <= 1'b1;
				        cfsm <= SEEK_EN;
				end
			  end




			default :
			  begin
				cfsm <= SEEK_EN;
			  end
		endcase
	end
end 


assign length_out = count;



// synopsys translate_off
reg  [(22*8):1] cfsm_monitor; 
always @(*) begin
   case (cfsm)
      SEEK_EN		: cfsm_monitor = "SEEK_EN";
      DO_WRITE_LO 	: cfsm_monitor = "DO_WRITE_LO";
      DO_WRITE_HI	: cfsm_monitor = "DO_WRITE_HI";         
      CAR_EXT_LO	: cfsm_monitor = "CAR_EXT_LO";         
      CAR_EXT_HI	: cfsm_monitor = "CAR_EXT_HI";
      DO_WRITE_GB	: cfsm_monitor = "DO_WRITE_GB";
      CAR_EXT_GB	: cfsm_monitor = "CAR_EXT_GB";

      default		: cfsm_monitor = "***ERROR***";
   endcase
end
// synopsys translate_on

endmodule
// =============================================================================



