//=============================================================================
// Verilog module generated by IPExpress    
// Filename: USERNAME.v                                          
// Copyright(c) 2006 Lattice Semiconductor Corporation. All rights reserved.   
//=============================================================================

/* WARNING - Changes to this file should be performed by re-running IPexpress
or modifying the .LPC file and regenerating the core.  Other changes may lead
to inconsistent simulation and/or implemenation results */
module tsmac35 (
       // clock and reset
       hclk,
       txmac_clk,
       rxmac_clk,
       reset_n,
       txmac_clk_en,
       rxmac_clk_en,

       // Input signals to the GMII
       rxd,
       rx_dv,
       rx_er,
       col,
       crs,
       // Input signals to the CPU Interface
       haddr,
       hdatain,
       hcs_n,
       hwrite_n,
       hread_n,
       
       // Input signals to the MII Management Interface
     
       // Input signals to the Tx MAC FIFO Interface
       tx_fifodata,
       tx_fifoavail,
       tx_fifoeof,
       tx_fifoempty,
       tx_sndpaustim,
       tx_sndpausreq,
       tx_fifoctrl,
     
       // Input signals to the Rx MAC FIFO Interface
       rx_fifo_full,
       ignore_pkt,
     
       // Output signals from the GMII
       txd,
       tx_en,
       tx_er,
     
       // Output signals from the CPU Interface
       hdataout,
       hdataout_en_n,
       hready_n,
       cpu_if_gbit_en,
     
       // Output signals from the MII Management Interface
     
       // Output signals from the Tx MAC FIFO Interface
       tx_macread,
       tx_discfrm,
       tx_staten,
       tx_statvec,
       tx_done,
     
       // Output signals from the Rx MAC FIFO Interface
       rx_fifo_error,
       rx_stat_vector,
       rx_dbout,
       rx_write,
       rx_stat_en,
       rx_eof,
       rx_error
     );
     
     // ------------------------- clock and reset inputs ---------------------
     input                            hclk;               // clock to the CPU I/F
     input                            txmac_clk;          // clock to the Tx MAC
     input                            rxmac_clk;          // clock to the RX MAC
     input                            reset_n;            // Global reset
     input                            txmac_clk_en;       // clock enable to the Tx MAC
     input                            rxmac_clk_en;       // clock enable to the RX MAC
     
     // ----------------------- Input signals to the GMII -------------------
     input  [7:0]                     rxd;                // Receive data
     input                            rx_dv;              // Receive data valid
     input                            rx_er;              // Receive data error
     input                            col;                // Collision detect
     input                            crs;                // Carrier Sense
     // -------------------- Input signals to the CPU I/F -------------------
     input  [7:0]                     haddr;              // Address Bus
     input  [7:0]                     hdatain;            // Input data Bus
     input                            hcs_n;              // Chip select
     input                            hwrite_n;           // Register write
     input                            hread_n;            // Register read
     
     // -------------------- Input signals to the MII I/F -------------------

     
     // ---------------- Input signals to the Tx MAC FIFO I/F ---------------
     input  [7:0]                     tx_fifodata;        // Data Input from FIFO
     input                            tx_fifoavail;       // Data Available in FIFO
     input                            tx_fifoeof;         // End of Frame
     input                            tx_fifoempty;       // FIFO Empty
     input  [15:0]                    tx_sndpaustim;      // Pause frame parameter
     input                            tx_sndpausreq;      // Transmit PAUSE frame
     input                            tx_fifoctrl;        // Control frame or Not
     
     // ---------------- Input signals to the Rx MAC FIFO I/F ---------------
     input                            rx_fifo_full;       // Receive FIFO Full
     input                            ignore_pkt;         // Ignore the frame
     
     // -------------------- Output signals from the GMII -----------------------
     output [7:0]                     txd;                // Transmit data
     output                           tx_en;              // Transmit Enable
     output                           tx_er;              // Transmit Error
     
     // -------------------- Output signals from the CPU I/F -------------------
     output [7:0]                     hdataout;           // Output data Bus
     output                           hdataout_en_n;      // Data Out Enable
     output                           hready_n;           // Ready signal
     output                           cpu_if_gbit_en;     // Gig or 10/100 mode
     
     // -------------------- Output signals from the MII I/F -------------------

     
     // ---------------- Output signals from the Tx MAC FIFO I/F ---------------
     output                           tx_macread;         // Read FIFO
     output                           tx_discfrm;         // Discard Frame
     output                           tx_staten;          // Status Vector Valid
     output                           tx_done;            // Transmit of Frame done
     output [30:0]                    tx_statvec;         // Tx Status Vector
     
     // ---------------- Output signals from the Rx MAC FIFO I/F ---------------
     output                           rx_fifo_error;      // FIFO full detected
     output [31:0]                    rx_stat_vector;     // Rx Status Vector
     output [7:0]                     rx_dbout;           // Data Output to FIFO
     output                           rx_write;           // Write FIFO
     output                           rx_stat_en;         // Status Vector Valid
     output                           rx_eof;             // Entire frame written
     output                           rx_error;           // Erroneous frame
     
     tsmac_core U1_LSC_ts_mac_core ( 

     	  // clock and reset
         .hclk(hclk),
         .txmac_clk(txmac_clk),
         .rxmac_clk(rxmac_clk),
         .reset_n(reset_n),
         .txmac_clk_en(txmac_clk_en),
         .rxmac_clk_en(rxmac_clk_en),
     
         // Input signals to the GMII
         .rxd(rxd),
         .rx_dv(rx_dv),
         .rx_er(rx_er),
         .col(col),
         .crs(crs),
         // Input signals to the CPU Interface
         .haddr(haddr),
         .hdatain(hdatain),
         .hcs_n(hcs_n),
         .hwrite_n(hwrite_n),
         .hread_n(hread_n),
     
         // Input signals to the MII Management Interface
     
         // Input signals to the Tx MAC FIFO Interface
         .tx_fifodata(tx_fifodata),
         .tx_fifoavail(tx_fifoavail),
         .tx_fifoeof(tx_fifoeof),
         .tx_fifoempty(tx_fifoempty),
         .tx_sndpaustim(tx_sndpaustim),
         .tx_sndpausreq(tx_sndpausreq),
         .tx_fifoctrl(tx_fifoctrl),
     
         // Input signals to the Rx MAC FIFO Interface
         .rx_fifo_full(rx_fifo_full),
         .ignore_pkt(ignore_pkt),
     
         // Output signals from the GMII
         .txd(txd),
         .tx_en(tx_en),
         .tx_er(tx_er),
     
         // Output signals from the CPU Interface
         .hdataout(hdataout),
         .hdataout_en_n(hdataout_en_n),
         .hready_n(hready_n),
         .cpu_if_gbit_en(cpu_if_gbit_en),
     
         // Output signals from the MII Management Interface
     
         // Output signals from the Tx MAC FIFO Interface
         .tx_macread(tx_macread),
         .tx_discfrm(tx_discfrm),
         .tx_staten(tx_staten),
         .tx_statvec(tx_statvec),
         .tx_done(tx_done),
     
         // Output signals from the Rx MAC FIFO Interface
         .rx_fifo_error(rx_fifo_error),
         .rx_stat_vector(rx_stat_vector),
         .rx_dbout(rx_dbout),
         .rx_write(rx_write),
         .rx_stat_en(rx_stat_en),
         .rx_eof(rx_eof),
         .rx_error(rx_error)
     );
endmodule
