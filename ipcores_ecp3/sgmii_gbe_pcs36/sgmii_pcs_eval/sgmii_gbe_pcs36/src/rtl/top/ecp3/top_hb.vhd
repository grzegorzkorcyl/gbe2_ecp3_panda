--**************************************************************************
-- *************************************************************************
-- *                LATTICE SEMICONDUCTOR CONFIDENTIAL                     *
-- *                         PROPRIETARY NOTE                              *
-- *                                                                       *
-- *  This software contains information confidential and proprietary      *
-- *  to Lattice Semiconductor Corporation.  It shall not be reproduced    *
-- *  in whole or in part, or transferred to other documents, or disclosed *
-- *  to third parties, or used for any purpose other than that for which  *
-- *  it was obtained, without the prior written consent of Lattice        *
-- *  Semiconductor Corporation.  All rights reserved.                     *
-- *                                                                       *
-- *************************************************************************
--**************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity top_hb is port(

	-- G/MII Interface
	data_in_mii  : in std_logic_vector(7 downto 0) ;-- G/MII Incoming Data           
	en_in_mii    : in std_logic ;                   -- G/MII Incoming Data Valid     
	err_in_mii   : in std_logic ;                   -- G/MII Incoming Error          
                     
	data_out_mii : out std_logic_vector(7 downto 0) ;-- G/MII Outgoing Data        
	dv_out_mii   : out std_logic;                    -- G/MII Outgoing Data Valid  
	err_out_mii  : out std_logic;                    -- G/MII Outgoing Error       
	col_out_mii  : out std_logic;                    -- G/MII Collision Detect     
	crs_out_mii  : out std_logic;                    -- G/MII Carrier Sense Detect 

	-- GB Timing References
	in_clk_125   : in std_logic ; -- GMII Reference clock 125Mhz     
	in_ce_sink   : in std_logic ;
	in_ce_source : out std_logic;
	out_clk_125  : in std_logic ; -- GMII Reference clock 125Mhz       
	out_ce_sink  : in std_logic ;  
	out_ce_source: out std_logic; 

	-- SERIAL GMII Interface 
	refclkp      : in std_logic ;-- SERDES Reference Clock
	refclkn      : in std_logic ;-- SERDES Reference Clock
	hdinp0       : in std_logic ;-- Incoming SGMII (on SERDES)  
	hdinn0       : in std_logic ;-- Incoming SGMII (on SERDES)  
	hdoutp0      : out std_logic;-- Outgoing SGMII (on SERDES)    
	hdoutn0      : out std_logic;-- Outgoing SGMII (on SERDES)   

	-- Control Interface
	gbe_mode     : in std_logic; -- GBE Mode       (0=SGMII  1=GBE)
	sgmii_mode   : in std_logic; -- SGMII PCS Mode (0=MAC    1=PHY)
	rst_n        : in std_logic; -- System Reset, Active Low

	-- Host Bus
	hclk         : in std_logic;
	hcs_n        : in std_logic;
	hwrite_n     : in std_logic;
	haddr        : in std_logic_vector(5 downto 0);
	hdatain      : in std_logic_vector(7 downto 0);
                     
	hdataout     : out std_logic_vector(7 downto 0);
	hready_n     : out std_logic;
	
	--Debug Port
        debug_link_timer_short : in std_logic;
        mr_an_complete         : out std_logic
	);
end entity;

architecture arch of top_hb is
component sgmii_gbe_pcs36 port (
	rst_n                  : in std_logic;
	signal_detect          : in std_logic;
	gbe_mode               : in std_logic;
	sgmii_mode             : in std_logic;
	operational_rate       : in std_logic_vector(1 downto 0);
	debug_link_timer_short : in std_logic;
	force_isolate          : in std_logic;
	force_loopback         : in std_logic;
	force_unidir           : in std_logic;
	rx_compensation_err    : out std_logic;
	ctc_drop_flag          : out std_logic;
	ctc_add_flag           : out std_logic;
	an_link_ok             : out std_logic;
	tx_clk_125             : in std_logic;                    
        tx_clock_enable_source : out std_logic;
        tx_clock_enable_sink   : in std_logic;          
	tx_d                   : in std_logic_vector(7 downto 0); 
	tx_en                  : in std_logic;       
	tx_er                  : in std_logic;       
	rx_clk_125             : in std_logic; 
        rx_clock_enable_source : out std_logic;
        rx_clock_enable_sink   : in std_logic;          
	rx_d                   : out std_logic_vector(7 downto 0);       
	rx_dv                  : out std_logic;  
	rx_er                  : out std_logic; 
	col                    : out std_logic;  
	crs                    : out std_logic;  
	tx_data                : out std_logic_vector(7 downto 0);  
	tx_kcntl               : out std_logic; 
	tx_disparity_cntl      : out std_logic; 
	xmit_autoneg           : out std_logic; 
	serdes_recovered_clk   : in std_logic; 
	rx_data                : in std_logic_vector(7 downto 0);  
	rx_even                : in std_logic;  
	rx_kcntl               : in std_logic; 
	rx_disp_err            : in std_logic; 
	rx_cv_err              : in std_logic; 
	rx_err_decode_mode     : in std_logic; 
	mr_an_complete         : out std_logic; 
	mr_page_rx             : out std_logic; 
	mr_lp_adv_ability      : out std_logic_vector(15 downto 0); 
	mr_main_reset          : in std_logic; 
	mr_an_enable           : in std_logic; 
	mr_restart_an          : in std_logic; 
	mr_adv_ability         : in std_logic_vector(15 downto 0) 
   );
end component;
component register_interface_hb port (
	rst_n                  : in std_logic;
	hclk                   : in std_logic;
	gbe_mode               : in std_logic;
	sgmii_mode             : in std_logic;
	hcs_n                  : in std_logic;
	hwrite_n               : in std_logic;
	haddr                  : in std_logic_vector(5 downto 0);
	hdatain                : in std_logic_vector(7 downto 0);
	hdataout               : out std_logic_vector(7 downto 0);   
	hready_n               : out std_logic;
	mr_stat_1000base_x_fd  : in std_logic; 
	mr_stat_1000base_x_hd  : in std_logic; 
	mr_stat_1000base_t_fd  : in std_logic; 
	mr_stat_1000base_t_hd  : in std_logic; 
	mr_stat_100base_t4     : in std_logic; 
	mr_stat_100base_x_fd   : in std_logic; 
	mr_stat_100base_x_hd   : in std_logic; 
	mr_stat_10mbps_fd      : in std_logic; 
	mr_stat_10mbps_hd      : in std_logic; 
	mr_stat_100base_t2_fd  : in std_logic; 
	mr_stat_100base_t2_hd  : in std_logic; 
	mr_stat_extended_stat  : in std_logic; 
	mr_stat_unidir_able    : in std_logic; 
	mr_stat_preamb_supr    : in std_logic; 
	mr_stat_an_complete         : in std_logic; 
	mr_stat_remote_fault  : in std_logic; 
	mr_stat_an_able        : in std_logic; 
	mr_stat_link_stat      : in std_logic; 
	mr_stat_jab_det        : in std_logic; 
	mr_stat_extended_cap   : in std_logic; 
	mr_page_rx             : in std_logic; 
	mr_lp_adv_ability      : in std_logic_vector(15 downto 0); 
	mr_main_reset          : out std_logic; 
	mr_loopback_enable     : out std_logic; 
	mr_speed_selection     : out std_logic_vector(1 downto 0); 
	mr_an_enable           : out std_logic; 
	mr_power_down          : out std_logic; 
	mr_isolate             : out std_logic; 
	mr_restart_an          : out std_logic; 
	mr_duplex_mode         : out std_logic; 
	mr_col_test            : out std_logic; 
	mr_unidir_enable       : out std_logic; 
	mr_adv_ability         : out std_logic_vector(15 downto 0) 
   );
end component;
component rate_resolution port (
	gbe_mode               : in std_logic;
	sgmii_mode             : in std_logic;
	an_enable              : in std_logic; 
	advertised_rate        : in std_logic_vector(1 downto 0);
	link_partner_rate      : in std_logic_vector(1 downto 0);
	non_an_rate            : in std_logic_vector(1 downto 0);
	operational_rate       : out std_logic_vector(1 downto 0)  
   );
end component;
component pcs_serdes port (
        refclkp               : in std_logic; 
        refclkn               : in std_logic; 
        hdinp_ch0             : in std_logic; 
        hdinn_ch0             : in std_logic; 
        hdoutp_ch0            : out std_logic; 
        hdoutn_ch0            : out std_logic; 
        refclk2fpga           : out std_logic; 
        rxiclk_ch0            : in std_logic; 
        txiclk_ch0            : in std_logic; 
        txdata_ch0            : in std_logic_vector(7 downto 0);
        rxdata_ch0            : out std_logic_vector(7 downto 0);             
        tx_k_ch0              : in std_logic;
        rx_k_ch0              : out std_logic; 
        rx_full_clk_ch0       : out std_logic; 
        rx_half_clk_ch0       : out std_logic; 
        xmit_ch0              : in std_logic;
        tx_disp_correct_ch0   : in std_logic;
        rx_disp_err_ch0       : out std_logic; 
        rx_cv_err_ch0         : out std_logic; 
        rx_serdes_rst_ch0_c   : in std_logic;
        tx_pcs_rst_ch0_c      : in std_logic;
        rx_pcs_rst_ch0_c      : in std_logic;
        tx_pwrup_ch0_c        : in std_logic;
        rx_pwrup_ch0_c        : in std_logic;
        rx_los_low_ch0_s      : out std_logic; 
        lsm_status_ch0_s      : out std_logic; 
        rx_cdr_lol_ch0_s      : out std_logic; 
        rst_qd_c              : in std_logic;
        serdes_rst_qd_c       : in std_logic;
        tx_serdes_rst_c       : in std_logic;
        tx_full_clk_ch0       : out std_logic; 
        tx_half_clk_ch0       : out std_logic; 
        tx_pll_lol_qd_s       : out std_logic
   );
end component;
component tx_reset_sm port (
	rst_n                 : in std_logic;
	refclkdiv2            : in std_logic;
	tx_pll_lol_qd_s       : in std_logic; 
        rst_qd_c              : out std_logic; 
        tx_pcs_rst_ch_c       : out std_logic_vector(3 downto 0) 
   );
end component;
component rx_reset_sm port (
	rst_n                 : in std_logic;
	refclkdiv2            : in std_logic;
	power_down            : in std_logic; 
	rx_cdr_lol_ch_s       : in std_logic; 
	rx_los_low_ch_s       : in std_logic; 
	tx_pll_lol_qd_s       : in std_logic; 
        rx_pcs_rst_ch_c       : out std_logic;
        rx_serdes_rst_ch_c    : out std_logic
   );
end component;

attribute NOPAD : boolean;
attribute NOPAD of hdinp0  : signal is true;
attribute NOPAD of hdinn0  : signal is true;
attribute NOPAD of hdoutp0 : signal is true;
attribute NOPAD of hdoutn0 : signal is true;

-- G/MII Signals from input latches to SGMII channel
signal data_buf2chan : std_logic_vector(7 downto 0);
signal en_buf2chan   : std_logic;
signal err_buf2chan  : std_logic;

-- G/MII Signals from SGMII channel to output latches
signal data_chan2buf : std_logic_vector(7 downto 0); 
signal dv_chan2buf   : std_logic;                    
signal err_chan2buf  : std_logic;                    
signal col_chan2buf  : std_logic; 
signal crs_chan2buf  : std_logic; 

--  8-bit Interface Signals from SGMII channel to QuadPCS/SERDES
signal data_chan2quad          : std_logic_vector(7 downto 0);   
signal kcntl_chan2quad         : std_logic;
signal disparity_cntl_chan2quad: std_logic;

--  8-bit Interface Signals from QuadPCS/SERDES to SGMII channel
signal data_quad2chan          : std_logic_vector(7 downto 0);      
signal kcntl_quad2chan         : std_logic;
signal disp_err_quad2chan      : std_logic;
signal cv_err_quad2chan        : std_logic;
signal link_status             : std_logic;
signal serdes_recovered_clk    : std_logic;

-- Misc Signals
signal mdin    : std_logic;  
signal mdout   : std_logic;  
signal mdout_en: std_logic;  

signal operational_rate      : std_logic_vector(1 downto 0);           
signal rst                   : std_logic;  
signal power_up              : std_logic;  

signal mr_an_enable          : std_logic; 
signal mr_restart_an         : std_logic; 
signal mr_adv_ability        : std_logic_vector(15 downto 0);  
signal mr_an_complete_int    : std_logic; 
signal mr_page_rx            : std_logic; 
signal mr_lp_adv_ability     : std_logic_vector(15 downto 0); 
signal mr_main_reset         : std_logic; 

signal tx_pll_lol            : std_logic; 
signal rx_cdr_lol            : std_logic; 
signal quad_rst              : std_logic; 
signal tx_pcs_rst            : std_logic_vector(3 downto 0); 
signal rx_pcs_rst            : std_logic; 
signal rx_serdes_rst         : std_logic; 
signal refclk2fpga           : std_logic; 
signal xmit_autoneg          : std_logic; 
signal mr_loopback_enable    : std_logic; 
signal mr_speed_selection    : std_logic_vector(1 downto 0);           
signal mr_power_down         : std_logic; 
signal mr_isolate            : std_logic; 
signal mr_duplex_mode        : std_logic; 
signal mr_col_test           : std_logic; 
signal mr_unidir_enable      : std_logic; 
signal an_link_ok            : std_logic; 

begin

--  Active High Reset
rst <= not rst_n;
power_up <= not mr_power_down;
mr_an_complete <= mr_an_complete_int;

u0_tx_reset_sm : tx_reset_sm port map(
	rst_n           => rst_n,
	refclkdiv2      => in_clk_125,
	tx_pll_lol_qd_s => tx_pll_lol,
	rst_qd_c        => quad_rst,
	tx_pcs_rst_ch_c  => tx_pcs_rst
);

u0_rx_reset_sm : rx_reset_sm port map(
	rst_n           => rst_n,
	refclkdiv2         => in_clk_125,
	power_down         => mr_power_down,
	rx_cdr_lol_ch_s    => rx_cdr_lol,
	rx_los_low_ch_s    => '0', 
	tx_pll_lol_qd_s    => tx_pll_lol, 
	rx_pcs_rst_ch_c    => rx_pcs_rst, 
	rx_serdes_rst_ch_c => rx_serdes_rst
);


-- Buffer Incoming MII Data at Primary I/O
process (rst_n, in_clk_125)
begin
 if (rst_n = '0') then
     data_buf2chan <= (others => '0');
     en_buf2chan   <= '0';
     err_buf2chan  <= '0';
 elsif  rising_edge(in_clk_125) then
     data_buf2chan <= data_in_mii;
     en_buf2chan   <= en_in_mii;
     err_buf2chan  <= err_in_mii;
 end if;
end process;

-- Buffer Outgoing MII Data at Primary I/O
process (rst_n, out_clk_125)
begin
 if (rst_n = '0') then
     data_out_mii <= (others => '0');
     dv_out_mii   <= '0';
     err_out_mii  <= '0';
     col_out_mii  <= '0';
     crs_out_mii  <= '0';
 elsif  rising_edge(out_clk_125) then
     data_out_mii <= data_chan2buf;
     dv_out_mii   <= dv_chan2buf;
     err_out_mii  <= err_chan2buf;
     col_out_mii  <= col_chan2buf;
     crs_out_mii  <= crs_chan2buf;
 end if;
end process;

-- Instantiate SGMII IP Core
u1_dut : sgmii_gbe_pcs36 port map(
   -- Clock and Reset
   rst_n                   => rst_n        ,
   tx_clk_125              => in_clk_125   ,
   tx_clock_enable_sink    => in_ce_sink   ,
   tx_clock_enable_source  => in_ce_source ,
   rx_clk_125              => out_clk_125  ,
   rx_clock_enable_sink    => out_ce_sink  ,
   rx_clock_enable_source  => out_ce_source,
  
   -- Control
   gbe_mode                => gbe_mode     ,
   sgmii_mode              => sgmii_mode   ,
   debug_link_timer_short  => debug_link_timer_short, 
   force_isolate           => mr_isolate, 
   force_loopback          => mr_loopback_enable, 
   force_unidir            => mr_unidir_enable, 
   operational_rate        => operational_rate,
   rx_compensation_err     => open,
   ctc_drop_flag           => open,
   ctc_add_flag            => open,
   an_link_ok              => an_link_ok,
   
   -- (G)MII TX Port
   tx_d                    => data_buf2chan,
   tx_en                   => en_buf2chan  ,
   tx_er                   => err_buf2chan ,
   
   -- (G)MII RX Port
   rx_d                    => data_chan2buf,
   rx_dv                   => dv_chan2buf  ,
   rx_er                   => err_chan2buf ,
   col                     => col_chan2buf ,
   crs                     => crs_chan2buf ,
             
   -- 8BI TX Port
   tx_data                 => data_chan2quad,
   tx_kcntl                => kcntl_chan2quad,  
   tx_disparity_cntl       => disparity_cntl_chan2quad,
   xmit_autoneg            => xmit_autoneg,
   
   -- 8BI RX Port
   signal_detect           => link_status,
   serdes_recovered_clk    => serdes_recovered_clk,
   rx_data                 => data_quad2chan,
   rx_kcntl                => kcntl_quad2chan,
   rx_even                 => '0', -- Signal Not Used in Normal Mode
   rx_disp_err             => disp_err_quad2chan,
   rx_cv_err               => cv_err_quad2chan,
   rx_err_decode_mode      => '0', -- 0= Normal Mode, always tie low for SC Familiy
   
   -- Management Interface  I/O
   mr_adv_ability          => mr_adv_ability,
   mr_an_enable            => mr_an_enable  , 
   mr_main_reset           => mr_main_reset ,  
   mr_restart_an           => mr_restart_an ,   
                            
   mr_an_complete          => mr_an_complete_int,   
   mr_lp_adv_ability       => mr_lp_adv_ability, 
   mr_page_rx              => mr_page_rx
 );



-- Host Bus Register Interface for SGMII IP Core
u0_ri : register_interface_hb port map(
	-- Control Signals
	rst_n      => rst_n,
	hclk       => hclk,
	gbe_mode   => gbe_mode,
	sgmii_mode => sgmii_mode,
                   
	-- Host Bus
	hcs_n      => hcs_n,
	hwrite_n   => hwrite_n,
	haddr      => haddr,
	hdatain    => hdatain,
                   
	hdataout   => hdataout,
	hready_n   => hready_n,

	-- Register Outputs
	mr_main_reset      => mr_main_reset,
	mr_loopback_enable => mr_loopback_enable,
	mr_speed_selection => mr_speed_selection,
	mr_an_enable   => mr_an_enable,
	mr_power_down      => mr_power_down,
	mr_isolate         => mr_isolate,
	mr_restart_an  => mr_restart_an,
	mr_duplex_mode     => mr_duplex_mode,
	mr_col_test        => mr_col_test,
	mr_unidir_enable   => mr_unidir_enable,
	mr_adv_ability => mr_adv_ability,

	-- Register Inputs
	mr_stat_1000base_x_fd  => '1',
	mr_stat_1000base_x_hd  => '0',
	mr_stat_1000base_t_fd  => '0',
	mr_stat_1000base_t_hd  => '0',

	mr_stat_100base_t4     => '0',
	mr_stat_100base_x_fd   => '0',
	mr_stat_100base_x_hd   => '0',
	mr_stat_10mbps_fd      => '0',
	mr_stat_10mbps_hd      => '0',
	mr_stat_100base_t2_fd  => '0',
	mr_stat_100base_t2_hd  => '0',

	mr_stat_extended_stat  => '1',
	mr_stat_unidir_able    => mr_unidir_enable,
	mr_stat_preamb_supr    => '0',
	mr_stat_an_complete    => mr_an_complete_int,
	mr_stat_remote_fault  => '0',
	mr_stat_an_able        => '1',
	mr_stat_link_stat      =>  an_link_ok,
	mr_stat_jab_det        => '0',
	mr_stat_extended_cap   => '0',

	mr_page_rx         => mr_page_rx,
	mr_lp_adv_ability  => mr_lp_adv_ability
	);

-- (G)MII Rate Resolution for SGMII IP Core
u0_rate_resolution : rate_resolution port map(
	gbe_mode          => gbe_mode,
	sgmii_mode        => sgmii_mode,
	an_enable         => mr_an_enable,
	advertised_rate   => mr_adv_ability(11 downto 10),
	link_partner_rate => mr_lp_adv_ability(11 downto 10),
	non_an_rate       => mr_speed_selection, -- speed selected when auto-negotiation disabled
                          
	operational_rate  => operational_rate
);

-- QUAD ASB 8B10B + SERDES
u0_pcs_serdes : pcs_serdes port map(

-- Global Clocks and Resets
	-- inputs
	refclkp  => refclkp, 
	refclkn  => refclkn, 
	rst_qd_c        => quad_rst, 
	serdes_rst_qd_c => '0', 
	tx_serdes_rst_c     => '0',
	refclk2fpga  => open, 



-- fpga tx datapath signals
	-- inputs
	tx_pcs_rst_ch0_c    => tx_pcs_rst(0), 
	txiclk_ch0          => in_clk_125, 
	txdata_ch0          => data_chan2quad, 
	tx_k_ch0            => kcntl_chan2quad, 
	tx_disp_correct_ch0 => disparity_cntl_chan2quad, 

	-- outputs
	tx_full_clk_ch0 => open, 
	tx_half_clk_ch0 => open, 

-- fpga rx datapath signals
	-- inputs
	rx_pcs_rst_ch0_c => rx_pcs_rst, 
	rxiclk_ch0       => serdes_recovered_clk, 
	xmit_ch0         => xmit_autoneg, 

	-- outputs
	rx_full_clk_ch0   => serdes_recovered_clk,
	rx_half_clk_ch0   => open,
	rxdata_ch0        => data_quad2chan, 
	rx_k_ch0          => kcntl_quad2chan, 
	rx_disp_err_ch0   => disp_err_quad2chan, 
	rx_cv_err_ch0     => cv_err_quad2chan, 
	lsm_status_ch0_s  => link_status, 
	rx_los_low_ch0_s  => open, 
	rx_cdr_lol_ch0_s  => rx_cdr_lol, 

-- serdes signals
	-- inputs
	rx_serdes_rst_ch0_c => rx_serdes_rst, 

	hdinp_ch0  => hdinp0, 
	hdinn_ch0  => hdinn0, 

	-- outputs
	hdoutp_ch0 => hdoutp0, 
	hdoutn_ch0 => hdoutn0, 

-- misc control signals
	-- inputs
	tx_pwrup_ch0_c => power_up,	-- powerup tx channel
	rx_pwrup_ch0_c => power_up,	-- power up rx channel

	-- outputs
	tx_pll_lol_qd_s => tx_pll_lol
);

end architecture;

