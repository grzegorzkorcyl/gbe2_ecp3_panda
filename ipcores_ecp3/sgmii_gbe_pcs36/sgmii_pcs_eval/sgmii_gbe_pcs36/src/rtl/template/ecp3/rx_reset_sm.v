
`timescale 1ns/1ps
//THIS MODULE IS INSTANTIATED PER RX CHANNEL
module rx_reset_sm
(
input        refclkdiv2,
input        rst_n,
input        rx_cdr_lol_ch_s,   
input        rx_los_low_ch_s,   
input        tx_pll_lol_qd_s, //IF  TX QUAD IS UNUSED, TIE THIS INPUT TO 0  
input        power_down,


output   reg    rx_pcs_rst_ch_c,      //RX Lane Reset
output   reg    rx_serdes_rst_ch_c          // QUAD Reset

);



// States of LSM
localparam   WAIT_FOR_PLOL      = 0,
             RX_SERDES_RESET       = 1,
             WAIT_FOR_TIMER1       = 2,
             CHECK_LOL_LOS       = 3,
             WAIT_FOR_TIMER2       = 4,
             NORMAL    = 5;

localparam STATEWIDTH =3; 
// Flop variables
reg [STATEWIDTH-1:0]    cs;               // current state of lsm


// Combinational logic variables
reg [STATEWIDTH-1:0]    ns;               // next state of lsm

wire rx_lol_los = rx_cdr_lol_ch_s || rx_los_low_ch_s ;


reg tx_pll_lol_qd_s_int;
reg rx_lol_los_int;
reg rx_lol_los_del;
reg     rx_pcs_rst_ch_c_int;      //RX Lane Reset
reg       rx_serdes_rst_ch_c_int;          // QUAD Reset

reg rx_los_low_int;
reg power_down_int;



//SEQUENTIAL 
always @(posedge refclkdiv2 or negedge rst_n) 
	begin
	if (rst_n == 1'b0) 
		begin
		cs <= WAIT_FOR_PLOL;
		rx_lol_los_int <= 1;
		rx_lol_los_del <= 1;
		tx_pll_lol_qd_s_int <= 1;
		rx_pcs_rst_ch_c <= 1;
		rx_serdes_rst_ch_c <= 0;
		rx_los_low_int <= 1;
		power_down_int <= 0;
		end
	else 
		begin
		cs <= ns;
		rx_lol_los_del <= rx_lol_los;
		rx_lol_los_int <= rx_lol_los_del;
		tx_pll_lol_qd_s_int <= tx_pll_lol_qd_s;
		rx_pcs_rst_ch_c <= rx_pcs_rst_ch_c_int;
		rx_serdes_rst_ch_c <= rx_serdes_rst_ch_c_int;
		rx_los_low_int <= rx_los_low_ch_s;
		power_down_int <= power_down;
		end
	end

//




reg reset_timer1, reset_timer2;


//TIMER1 = 3ns;
//Fastest REFLCK =312 MHZ, or 3 ns. We need 1 REFCLK cycles or 2 REFCLKDIV2 cycles
// A 1 bit counter  counts 2 cycles, so a 2 bit ([1:0]) counter will do if we set TIMER1 = bit[1]
localparam TIMER1WIDTH=2;
reg [TIMER1WIDTH-1:0] counter1;
reg TIMER1;

always @(posedge refclkdiv2 or posedge reset_timer1) 
	begin
	if (reset_timer1) 
		begin
		counter1 <= 0;
		TIMER1 <= 0;
		end
	else 
		begin				
		if (counter1[1] == 1)
			TIMER1 <=1;
		else
			begin
			TIMER1 <=0;
			counter1 <= counter1 + 1 ;
			end
		end
	end
	
//TIMER2 = 400,000 Refclk cycles or 200,000 REFCLKDIV2 cycles
// An 18 bit counter ([17:0]) counts 262144 cycles, so a 19 bit ([18:0]) counter will do if we set TIMER2 = bit[18]

localparam TIMER2WIDTH=20;
reg [TIMER2WIDTH-1:0] counter2;
reg TIMER2;
always @(posedge refclkdiv2 or posedge reset_timer2) 
	begin
	if (reset_timer2) 
		begin
		counter2 <= 0;
		TIMER2 <= 0;
		end
	else 
		begin
		`ifdef	SIM	//IF SIM parameter is set, define lower value
				//TO SAVE SIMULATION TIME		
		if (counter2[4] == 1)
		`else
		if (counter2[TIMER2WIDTH-1] == 1)
		`endif
			TIMER2 <=1;
		else
			begin
			TIMER2 <=0;
			counter2 <= counter2 + 1 ;
			end
		end
	end
  
always @(*) 
//always @(cs or tx_pll_lol_qd_s_int or TIMER1 or rx_lol_los_int or rx_lol_los_del or TIMER2) 
	begin : NEXT_STATE
	reset_timer1 = 0;        
	reset_timer2 = 0;        
      	case (cs)
      	
      		WAIT_FOR_PLOL: 
      			begin
			rx_pcs_rst_ch_c_int = 1;        
			rx_serdes_rst_ch_c_int = 0;        
			if (tx_pll_lol_qd_s_int || rx_los_low_int || power_down_int) //Also make sure A Signal
				ns = WAIT_FOR_PLOL;        // is Present prior to moving to the next 
			else	
				ns = RX_SERDES_RESET;
          		end
          		
      		RX_SERDES_RESET: 
      			begin
			rx_pcs_rst_ch_c_int = 1;        
			rx_serdes_rst_ch_c_int = 1;        
			reset_timer1 = 1;        
			if (power_down_int) 
            		  ns = WAIT_FOR_PLOL;
			else
            		  ns = WAIT_FOR_TIMER1;
          		end
          		
      		WAIT_FOR_TIMER1: 
      			begin
			rx_pcs_rst_ch_c_int = 1;        
			rx_serdes_rst_ch_c_int = 1;
			if (power_down_int) 
				ns = WAIT_FOR_PLOL;
			else if (TIMER1) 
				ns = CHECK_LOL_LOS;
			else	
				ns = WAIT_FOR_TIMER1;
          		end

      		CHECK_LOL_LOS: 
      			begin
			rx_pcs_rst_ch_c_int = 1;        
			rx_serdes_rst_ch_c_int = 0;        
			reset_timer2 = 1;        
			if (power_down_int) 
            		  ns = WAIT_FOR_PLOL;
			else
            		  ns = WAIT_FOR_TIMER2;
          		end
          		
      		WAIT_FOR_TIMER2: 
      			begin
			rx_pcs_rst_ch_c_int = 1;        
			rx_serdes_rst_ch_c_int = 0;
			if (power_down_int)
				begin
            			ns = WAIT_FOR_PLOL;
				end
			else if (rx_lol_los_int == rx_lol_los_del) //NO RISING OR FALLING EDGES
				begin
				if (TIMER2)
					begin
					if (rx_lol_los_int) 
						ns = WAIT_FOR_PLOL;
					else
						ns = NORMAL;
					end
				else
					ns = WAIT_FOR_TIMER2;
				end
															
			else
	            		ns = CHECK_LOL_LOS; //RESET TIMER2					
          		end

      		NORMAL: 
      			begin
			rx_pcs_rst_ch_c_int = 0;        
			rx_serdes_rst_ch_c_int = 0;
			if (rx_lol_los_int || power_down_int)
				begin 
				ns = WAIT_FOR_PLOL;
				`ifdef SIM
				$display ("rx_lol_los_int=1: %t",$time); 
				`endif
				end
			else	
				begin 
				ns = NORMAL;
				`ifdef SIM 
				 $display ("rx_lol_los_int=0: %t",$time); 
				`endif
				end
          		end



        // prevent lockup in undefined state
        	default: 
        		begin
			rx_pcs_rst_ch_c_int = 1;        
			rx_serdes_rst_ch_c_int = 0;        
            		ns = WAIT_FOR_PLOL;
            		end       
      		endcase // case 

	end //NEXT_STATE



endmodule
