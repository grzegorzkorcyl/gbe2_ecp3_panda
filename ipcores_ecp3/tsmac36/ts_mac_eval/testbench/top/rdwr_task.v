// ===========================================================================
// Verilog module generated by IPexpress
// Filename: rdwr_task.v  
// Copyright 2005 (c) Lattice Semiconductor Corporation. All rights reserved.
// ===========================================================================

// MPI Write
task orc_write;
input [17:0]   address;
input  [7:0]   data;
reg            ret_status;
begin
orcastra_drv.single_write(address,data,ret_status);
end
endtask

// MPI Read
task orc_read;
input  [17:0]  address;
output  [7:0]  data;
reg            ret_status;
reg    [7:0]   read_data;
begin
orcastra_drv.single_read(address,read_data,ret_status);
data = read_data[7:0];
$display(" READ at address: %h at time: %t data is : %h", address, $time, data ) ;
end
endtask

// Register Write
task reg_wr;
input [17:0]   waddr;
input  [7:0]   wdata;
begin
   orc_write(waddr,wdata);
end
endtask

// Register Read
task reg_rd;
input [17:0]   raddr;
output [7:0]   rdata;
reg    [7:0]   read_data;
begin
   orc_read(raddr,read_data);
   rdata = read_data;
end
endtask


