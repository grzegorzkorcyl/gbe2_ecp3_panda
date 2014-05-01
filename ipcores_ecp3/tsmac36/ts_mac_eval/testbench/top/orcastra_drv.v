// ===========================================================================
// Verilog module generated by IPexpress
// Filename: orcastra_drv.v  
// Copyright 2005 (c) Lattice Semiconductor Corporation. All rights reserved.
// ===========================================================================
//
`timescale 1 ns/100 ps

`define FAIL  1'b1
`define PASS  1'b0
`define SYS_DATA	8  // system bus data bus size
`define SYS_ADDR	18  // system bus address bus size
`define SYS_SIZE	2  // system bus transfer size
`define half_period	10  // pc_clk half period = 200 ns  

module orcastra_drv(
   pc_clk,
   pc_datain,
   pc_dataout,
   pc_retry,
   pc_error,
   pc_ready,
   pc_ack
);

output             pc_clk;
output             pc_datain;
output             pc_ready;
input              pc_ack;
input              pc_dataout;
input              pc_retry;
input              pc_error;

reg             pc_clk;
reg             pc_ready;
reg             wr;
reg             da;
reg             a;

initial begin
   pc_clk = 1'b0;
   pc_ready = 1'b0;
   wr = 1'b0;
end

assign pc_datain = (wr) ? da:a; 

task single_write;

input [`SYS_ADDR-1:0] address;
input [`SYS_DATA-1:0] data;
inout ret_status;

integer i;

reg status;
reg ret_status;

begin
   
   status = `PASS;
   
   if (!status) begin
    
      wr = 1'b1;

      da = 0;
      #`half_period

      // serial data phase
      for (i=0;i<8;i=i+1) begin

        pc_clk = 1;
        da = data[i];
        #`half_period;
        pc_clk = 0;
        #`half_period;

      end

      #`half_period;
      #`half_period;
      #`half_period;
      #`half_period;
      #`half_period;


      // serial address phase 
      for (i=17;i>=0;i=i-1) begin

        pc_clk = 1;
        da = address[i];
        #`half_period;
        pc_clk = 0;
        #`half_period;

      end

      da = 0;        // WRITE

      pc_ready = 1;      
      //#`half_period;
      //#`half_period;
      //#`half_period;
      //#`half_period;
      //pc_ready = 0;      

      // wait for an acknowledge and then wait ten clocks (simulate PC)
      @(posedge pc_ack);

      for (i=10;i>=0;i=i-1) begin
        #`half_period;
        #`half_period;
      end
      
      pc_ready = 0;  // bring pc_ready low
      
      wr = 1'b0;
      status = 	`PASS;
                  
   end
   
   ret_status = ret_status | status;
   
end

endtask

task single_read;

input [`SYS_ADDR-1:0] address;
output [`SYS_DATA-1:0] data;
inout ret_status;

reg status;
reg ret_status;
reg [7:0] data;

integer i;

begin
   
   status = `PASS;
   
   if (!status) begin

      a = 0;
      #`half_period
   
      // serial address phase 
      for (i=17;i>=0;i=i-1) begin

        pc_clk = 1;
        a = address[i];
        #`half_period;
        pc_clk = 0;
        #`half_period;

      end
      
      a = 1;        // READ

      pc_ready = 1;      
      //#`half_period;
      //#`half_period;
      //#`half_period;
      //#`half_period;
      //pc_ready = 0;      

      // wait for an acknowledge and then wait ten clocks (simulate PC)
      @(posedge pc_ack);
      
      for (i=10;i>=0;i=i-1) begin
        #`half_period;
        #`half_period;
      end
      
      pc_ready = 0;  // bring pc_ready low

      // extra clock ???????
      pc_clk = 1;
      #`half_period;
      pc_clk = 0;
      #`half_period;

      // serial data phase - read data
      for (i=0;i<8;i=i+1) begin

        pc_clk = 1;
        #`half_period;
        pc_clk = 0;
	data[i] = pc_dataout;
        #`half_period;

      end

      #`half_period;
      #`half_period;
      
      status = `PASS;
            
   end
   
   ret_status = ret_status | status;
   
end

endtask

endmodule