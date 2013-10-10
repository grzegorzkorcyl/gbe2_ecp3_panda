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

entity top_pcs_core_only is port(

	-- Control Interface
	rst_n                  : in std_logic;
	signal_detect          : in std_logic;
	gbe_mode               : in std_logic;
	sgmii_mode             : in std_logic;
	force_isolate    : in std_logic;
	force_loopback   : in std_logic;
	force_unidir     : in std_logic;
	operational_rate       : in std_logic_vector(1 downto 0);
                               
	rx_compensation_err : out std_logic;
	ctc_drop_flag       : out std_logic;
	ctc_add_flag        : out std_logic;
	an_link_ok          : out std_logic;

	-- G/MII Interface
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

	-- 8-bit Interface
	tx_data                : out std_logic_vector(7 downto 0);  
	tx_kcntl               : out std_logic; 
	tx_disparity_cntl      : out std_logic; 
	xmit_autoneg     : out std_logic; 

	serdes_recovered_clk   : in std_logic; 
	rx_data                : in std_logic_vector(7 downto 0);  
	rx_kcntl               : in std_logic; 
	rx_disp_err            : in std_logic; 
	rx_cv_err              : in std_logic; 

	-- Managment Control Outputs
	mr_an_complete         : out std_logic; 
	mr_page_rx             : out std_logic; 
	mr_lp_adv_ability      : out std_logic_vector(15 downto 0); 
                               
	-- Managment Control Inputs
	mr_main_reset       : in std_logic; 
	mr_an_enable        : in std_logic; 
	mr_restart_an       : in std_logic; 
	mr_adv_ability      : in std_logic_vector(15 downto 0)  
	);
end entity;
architecture arch of top_pcs_core_only is
component sgmii_gbe_pcs36 port (
	rst_n                  : in std_logic;
	signal_detect          : in std_logic;
	gbe_mode               : in std_logic;
	sgmii_mode             : in std_logic;
	force_isolate          : in std_logic;
	force_loopback         : in std_logic;
	force_unidir           : in std_logic;
	operational_rate       : in std_logic_vector(1 downto 0);
	debug_link_timer_short : in std_logic;
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
begin

-- SGMII PCS
sgmii_gbe_pcs36_U : sgmii_gbe_pcs36 port map(
   -- Clock and Reset
   rst_n                  => rst_n                 ,
   signal_detect          => signal_detect         ,
   gbe_mode               => gbe_mode              ,
   sgmii_mode             => sgmii_mode            ,
   force_isolate          => force_isolate        ,
   force_loopback         => force_loopback       ,
   force_unidir           => force_unidir         ,
   operational_rate       => operational_rate      ,
   debug_link_timer_short => '0'                   ,
   rx_compensation_err    => rx_compensation_err  ,
   ctc_drop_flag          => ctc_drop_flag        ,
   ctc_add_flag           => ctc_add_flag         ,
   an_link_ok             => an_link_ok           ,
   tx_clk_125             => tx_clk_125            ,
   tx_clock_enable_source => tx_clock_enable_source,
   tx_clock_enable_sink   => tx_clock_enable_sink  ,
   serdes_recovered_clk   => serdes_recovered_clk  ,
   rx_clk_125             => rx_clk_125            ,
   rx_clock_enable_source => rx_clock_enable_source,
   rx_clock_enable_sink   => rx_clock_enable_sink  ,

   -- GMII TX Inputs
   tx_d                   => tx_d                 ,
   tx_en                  => tx_en                ,
   tx_er                  => tx_er                ,

   -- GMII RX Outputs
   -- To GMII/MAC interface
   rx_d                   => rx_d                 ,
   rx_dv                  => rx_dv                ,
   rx_er                  => rx_er                ,
   col                    => col                  ,
   crs                    => crs                  ,
                  
   -- 8BI TX Outputs
   tx_data                => tx_data              ,
   tx_kcntl               => tx_kcntl             ,
   tx_disparity_cntl      => tx_disparity_cntl    ,
   xmit_autoneg           => xmit_autoneg         ,

   -- 8BI RX Inputs
   rx_data                => rx_data              ,
   rx_kcntl               => rx_kcntl             ,
   rx_even                => '0'                  ,
   rx_disp_err            => rx_disp_err          ,
   rx_cv_err              => rx_cv_err            ,
   rx_err_decode_mode     => '0'                  ,

   -- Management Interface  I/O
   mr_adv_ability         => mr_adv_ability       ,
   mr_an_enable           => mr_an_enable         , 
   mr_main_reset          => mr_main_reset        ,  
   mr_restart_an          => mr_restart_an        ,   
                                              
   mr_an_complete         => mr_an_complete       ,   
   mr_lp_adv_ability      => mr_lp_adv_ability    , 
   mr_page_rx             => mr_page_rx           
   );

end architecture;
