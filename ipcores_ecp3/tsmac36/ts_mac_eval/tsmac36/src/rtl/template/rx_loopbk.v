// ===========================================================================
// Verilog module generated by IPexpress
// Filename: rx_loopbk.v  
// Copyright 2012 (c) Lattice Semiconductor Corporation. All rights reserved.
// ===========================================================================

//`timescale 1ns/100ps


// DEFINES


module rx_loopbk(
                clk,
                reset_n,
                rxmac_clk_en,
                add_swap,
                loop_enb,
		rx_dbout,
                rx_write,
                rx_eof,
                tx_dbin,
                tx_write,
                tx_eof
		);


        input clk;                       // rx fifo clock 
        input reset_n;                   // active low global reset
        input rxmac_clk_en;              // rx clk enable 
        
        input add_swap;                  // address swap control bit from reg  
        input loop_enb;                  // loop back enable control bit from reg
 
	input [7:0] rx_dbout;           // rxdata input to Rx FIFO 
	input rx_eof;                    // rxdata EOF input to Rx FIFO  
	input rx_write;                  // Rx FIFO write enable 

	output [7:0] tx_dbin;           // txdata input to Tx FIFO 
	reg [7:0] tx_dbin;              //
  
	output tx_eof;                   // txdata EOF input to Tx FIFO  
	reg tx_eof;                      //  

	output tx_write;                 // Tx FIFO write enable 
	reg tx_write;                    //  

        
	reg [7:0] rx_dbout_1f;          // rxdata input to Rx FIFO flopped 1 time  
	reg rx_eof_1f;                   // rxdata EOF input to Rx FIFO  flopped 1 time 
	reg rx_write_1f;                 // Rx FIFO write enable flopped 1 time 

	reg [7:0] rx_dbout_2f;          // rxdata input to Rx FIFO flopped 2 times  
	reg rx_eof_2f;                   // rxdata EOF input to Rx FIFO  flopped 2 times 
	reg rx_write_2f;                 // Rx FIFO write enable flopped 2 times 

	reg [7:0] rx_dbout_3f;          // rxdata input to Rx FIFO flopped 3 times  
	reg rx_eof_3f;                   // rxdata EOF input to Rx FIFO  flopped 3 times 
	reg rx_write_3f;                 // Rx FIFO write enable flopped 3 times 

	reg [7:0] rx_dbout_4f;          // rxdata input to Rx FIFO flopped 4 times  
	reg rx_eof_4f;                   // rxdata EOF input to Rx FIFO  flopped 4 times 
	reg rx_write_4f;                 // Rx FIFO write enable flopped 4 times 

	reg [7:0] rx_dbout_5f;          // rxdata input to Rx FIFO flopped 5 times  
	reg rx_eof_5f;                   // rxdata EOF input to Rx FIFO  flopped 5 times 
	reg rx_write_5f;                 // Rx FIFO write enable flopped 5 times 

	reg [7:0] rx_dbout_6f;          // rxdata input to Rx FIFO flopped 6 times  
	reg rx_eof_6f;                   // rxdata EOF input to Rx FIFO  flopped 6 times 
	reg rx_write_6f;                 // Rx FIFO write enable flopped 6 times 

	reg [7:0] rx_dbout_7f;          // rxdata input to Rx FIFO flopped 7 times  
	reg rx_eof_7f;                   // rxdata EOF input to Rx FIFO  flopped 7 times 
	reg rx_write_7f;                 // Rx FIFO write enable flopped 7 times 

	reg [7:0] rx_dbout_8f;          // rxdata input to Rx FIFO flopped 8 times  
	reg rx_eof_8f;                   // rxdata EOF input to Rx FIFO  flopped 8 times 
	reg rx_write_8f;                 // Rx FIFO write enable flopped 8 times 

	reg [7:0] rx_dbout_9f;          // rxdata input to Rx FIFO flopped 9 times  
	reg [7:0] rx_dbout_10f;          // rxdata input to Rx FIFO flopped 10 times  
	reg [7:0] rx_dbout_11f;          // rxdata input to Rx FIFO flopped 11 times  
	reg [7:0] rx_dbout_12f;          // rxdata input to Rx FIFO flopped 12 times  
	reg [7:0] rx_dbout_13f;          // rxdata input to Rx FIFO flopped 13 times  

	reg [7:0] add_swap_data;        //  data from add swap mux flopped once
 
	reg mx_ctl_1f;                   //  mux control flopped 1 time  
	reg mx_ctl_2f;                   //  mux control flopped 2 times  
	reg mx_ctl_3f;                   //  mux control flopped 3 times  
	reg mx_ctl_4f;                   //  mux control flopped 4 times  
	reg mx_ctl_5f;                   //  mux control flopped 5 times  
	reg mx_ctl_6f;                   //  mux control flopped 6 times  
	reg mx_ctl_7f;                   //  mux control flopped 7 time  
	reg mx_ctl_8f;                   //  mux control flopped 8 times  
	reg mx_ctl_9f;                   //  mux control flopped 9 times  
	reg mx_ctl_10f;                  //  mux control flopped 10 times  
	reg mx_ctl_11f;                  //  mux control flopped 11 times  
	reg mx_ctl_12f;                  //  mux control flopped 12 times  
	reg addr_detect_en;              //  address detect enable

	reg [1:0] mux_ctl;		 // address swap mux control bits 

        parameter                        
                NO_WRITE = 1'b0;         // write enable low 

        parameter [7:0]               
                NULL_DATA = 8'h00;    // NULL DATA 

        parameter 
                NULL_EOF = 1'b0;         // NO EOF 

        parameter [1:0]			 // ADD SWAP MUX SELECTIONS
	        DATA_D7  = 2'b00,
	        DATA_D1  = 2'b01,
	        DATA_D13 = 2'b10,
	        NO_SWAP  = 2'b11;




        //-------------------------------------------------------------------
        // Pipeline rx_dbout, rx_eof and rx_write  
        //-------------------------------------------------------------------
        always @(posedge clk or negedge reset_n) begin
          if (~reset_n) begin
                rx_dbout_1f <=  8'h00;
                rx_eof_1f <=  1'b0;
                rx_write_1f <=  1'b0;

                rx_dbout_2f <=  8'h00;
                rx_eof_2f <=  1'b0;
                rx_write_2f <=  1'b0;

                rx_dbout_3f <=  8'h00;
                rx_eof_3f <=  1'b0;
                rx_write_3f <=  1'b0;

                rx_dbout_4f <=  8'h00;
                rx_eof_4f <=  1'b0;
                rx_write_4f <=  1'b0;

                rx_dbout_5f <=  8'h00;
                rx_eof_5f <=  1'b0;
                rx_write_5f <=  1'b0;

                rx_dbout_6f <=  8'h00;
                rx_eof_6f <=  1'b0;
                rx_write_6f <=  1'b0;

                rx_dbout_7f <=  8'h00;
                rx_eof_7f <=  1'b0;
                rx_write_7f <=  1'b0;

                rx_dbout_8f <=  8'h00;
                rx_eof_8f <=  1'b0;
                rx_write_8f <=  1'b0;
		
                rx_dbout_9f <=  8'h00;
                rx_dbout_10f <=  8'h00;
                rx_dbout_11f <=  8'h00;
                rx_dbout_12f <=  8'h00;
                rx_dbout_13f <=  8'h00;
          end
          else if (rxmac_clk_en) begin
                rx_dbout_1f <=  rx_dbout;
                rx_eof_1f <=  rx_eof;
                rx_write_1f <=  rx_write;

                rx_dbout_2f <=  rx_dbout_1f;
                rx_eof_2f <=  rx_eof_1f;
                rx_write_2f <=  rx_write_1f;

                rx_dbout_3f <=  rx_dbout_2f;
                rx_eof_3f <=  rx_eof_2f;
                rx_write_3f <=  rx_write_2f;

                rx_dbout_4f <=  rx_dbout_3f;
                rx_eof_4f <=  rx_eof_3f;
                rx_write_4f <=  rx_write_3f;

                rx_dbout_5f <=  rx_dbout_4f;
                rx_eof_5f <=  rx_eof_4f;
                rx_write_5f <=  rx_write_4f;

                rx_dbout_6f <=  rx_dbout_5f;
                rx_eof_6f <=  rx_eof_5f;
                rx_write_6f <=  rx_write_5f;

                rx_dbout_7f <=  rx_dbout_6f;
                rx_eof_7f <=  rx_eof_6f;
                rx_write_7f <=  rx_write_6f;

                rx_write_8f <=  rx_write_7f;
                rx_eof_8f <=  rx_eof_7f;
                rx_dbout_8f <=  rx_dbout_7f;

                rx_dbout_9f <=  rx_dbout_8f;
                rx_dbout_10f <=  rx_dbout_9f;
                rx_dbout_11f <=  rx_dbout_10f;
                rx_dbout_12f <=  rx_dbout_11f;
                rx_dbout_13f <=  rx_dbout_12f;
          end // else
        end // always

        //-------------------------------------------------------------------
        // Pipelined mux control bits 
        //-------------------------------------------------------------------
        always @(posedge clk or negedge reset_n) begin
          if (~reset_n) begin
                mx_ctl_1f <=  1'b0;
                mx_ctl_2f <=  1'b0;
                mx_ctl_3f <=  1'b0;
                mx_ctl_4f <=  1'b0;
                mx_ctl_5f <=  1'b0;
                mx_ctl_6f <=  1'b0;
                mx_ctl_7f <=  1'b0;
                mx_ctl_8f <=  1'b0;
                mx_ctl_9f <=  1'b0;
                mx_ctl_10f <=  1'b0;
                mx_ctl_11f <=  1'b0;
                mx_ctl_12f <=  1'b0;
                addr_detect_en <=  1'b1;
          end
          else if (rxmac_clk_en) begin
		if (rx_write_1f & rx_write_7f) begin
	           addr_detect_en <= 0;
		end else if (rx_write_7f & rx_eof_7f) begin
	           addr_detect_en <= 1;
		end
                mx_ctl_1f <=  (rx_write_1f & !rx_write_7f & addr_detect_en);
                mx_ctl_2f <=  mx_ctl_1f;
                mx_ctl_3f <=  mx_ctl_2f;
                mx_ctl_4f <=  mx_ctl_3f;
                mx_ctl_5f <=  mx_ctl_4f;
                mx_ctl_6f <=  mx_ctl_5f;
                mx_ctl_7f <=  mx_ctl_6f;
                mx_ctl_8f <=  mx_ctl_7f;
                mx_ctl_9f <=  mx_ctl_8f;
                mx_ctl_10f <=  mx_ctl_9f;
                mx_ctl_11f <=  mx_ctl_10f;
                mx_ctl_12f <=  mx_ctl_11f;
          end // else
        end // always

        always @(add_swap, mx_ctl_12f, mx_ctl_6f) begin
           if (add_swap) begin
             mux_ctl[0] <=  mx_ctl_6f;
             mux_ctl[1] <=  mx_ctl_12f;
           end
           else begin
             mux_ctl <=  NO_SWAP;
           end
        end // always


        //-------------------------------------------------------------------
        // Pipelined address swap mux
        //-------------------------------------------------------------------
        always @(posedge clk or negedge reset_n) begin
          if (~reset_n) begin
                add_swap_data <=  8'h00;
          end
          else if (rxmac_clk_en) begin
                case (mux_ctl) 
		  DATA_D7: add_swap_data <=  rx_dbout_7f;     
		  DATA_D1: add_swap_data <=  rx_dbout_1f;   
		  DATA_D13: add_swap_data <=  rx_dbout_13f;   
		  NO_SWAP: add_swap_data <=  rx_dbout_7f;   
                endcase
          end // else
        end // always

        //-------------------------------------------------------------------
        // Pipelined muxes - loopback rx data or Null data (place holder 
	//                   for a frame buffer etc.) 
        //-------------------------------------------------------------------
        always @(posedge clk or negedge reset_n) begin
          if (~reset_n) begin
                tx_dbin <=  8'h00;
                tx_write <=  1'b0;
                tx_eof <=  1'b0;
          end
          else if (rxmac_clk_en) begin
                if (loop_enb) begin    
                  tx_dbin <=  add_swap_data;
                  tx_write <=  rx_write_8f ;
                  tx_eof <=  rx_eof_8f;
                end
                else begin
                  tx_dbin <=  NULL_DATA;
                  tx_write <=  NO_WRITE;
                  tx_eof <=  NULL_EOF;
                end
          end // else
        end // always


endmodule//
