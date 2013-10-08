library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
   use work.trb_net_std.all;
   use work.trb_net_components.all;
   use work.trb3_components.all;
   use work.version.all;
   use work.trb_net_gbe_components.all;
   
--Configuration is done in this file:   
   use work.config.all;
-- The description of hub ports is also there!


entity trb3_central is
  port(
    --Clocks
    CLK_EXT                        : in  std_logic_vector(4 downto 3); --from RJ45
    CLK_GPLL_LEFT                  : in  std_logic;  --Clock Manager 2/9, 200 MHz  <-- MAIN CLOCK
    CLK_GPLL_RIGHT                 : in  std_logic;  --Clock Manager 1/9, 125 MHz  <-- for GbE
    CLK_PCLK_LEFT                  : in  std_logic;  --Clock Fan-out, 200/400 MHz 
    CLK_PCLK_RIGHT                 : in  std_logic;  --Clock Fan-out, 200/400 MHz 

    --Trigger
    TRIGGER_LEFT                   : in  std_logic;  --left side trigger input from fan-out
    TRIGGER_RIGHT                  : in  std_logic;  --right side trigger input from fan-out
    TRIGGER_EXT                    : in  std_logic_vector(4 downto 2); --additional trigger from RJ45
    TRIGGER_OUT                    : out std_logic;  --trigger to second input of fan-out
    TRIGGER_OUT2                   : out std_logic;
    
    --Serdes
    CLK_SERDES_INT_LEFT            : in  std_logic;  --Clock Manager 2/0, 200 MHz, only in case of problems
    CLK_SERDES_INT_RIGHT           : in  std_logic;  --Clock Manager 1/0, off, 125 MHz possible
    
    --SFP
    SFP_RX_P                       : in  std_logic_vector(9 downto 1); 
    SFP_RX_N                       : in  std_logic_vector(9 downto 1); 
    SFP_TX_P                       : out std_logic_vector(9 downto 1); 
    SFP_TX_N                       : out std_logic_vector(9 downto 1); 
    SFP_TX_FAULT                   : in  std_logic_vector(8 downto 1); --TX broken
    SFP_RATE_SEL                   : out std_logic_vector(8 downto 1); --not supported by our SFP
    SFP_LOS                        : in  std_logic_vector(8 downto 1); --Loss of signal
    SFP_MOD0                       : in  std_logic_vector(8 downto 1); --SFP present
    SFP_MOD1                       : in  std_logic_vector(8 downto 1); --I2C interface
    SFP_MOD2                       : in  std_logic_vector(8 downto 1); --I2C interface
    SFP_TXDIS                      : out std_logic_vector(8 downto 1); --disable TX
    
    --Clock and Trigger Control
    TRIGGER_SELECT                 : out std_logic;  --trigger select for fan-out. 0: external, 1: signal from FPGA5
    CLOCK_SELECT                   : out std_logic;  --clock select for fan-out. 0: 200MHz, 1: external from RJ45
    CLK_MNGR1_USER                 : inout std_logic_vector(3 downto 0); --I/O lines to clock manager 1
    CLK_MNGR2_USER                 : inout std_logic_vector(3 downto 0); --I/O lines to clock manager 1
    
    --Inter-FPGA Communication
    FPGA1_COMM                     : inout std_logic_vector(11 downto 0);
    FPGA2_COMM                     : inout std_logic_vector(11 downto 0);
    FPGA3_COMM                     : inout std_logic_vector(11 downto 0);
    FPGA4_COMM                     : inout std_logic_vector(11 downto 0); 
                                    -- on all FPGAn_COMM:  --Bit 0/1 output, serial link TX active
                                                           --Bit 2/3 input, serial link RX active
                                                           --others yet undefined
    FPGA1_TTL                      : inout std_logic_vector(3 downto 0);
    FPGA2_TTL                      : inout std_logic_vector(3 downto 0);
    FPGA3_TTL                      : inout std_logic_vector(3 downto 0);
    FPGA4_TTL                      : inout std_logic_vector(3 downto 0);
                                    --only for not timing-sensitive signals

    --Communication to small addons
    FPGA1_CONNECTOR                : inout std_logic_vector(7 downto 0); --Bit 2-3: LED for SFP3/4
    FPGA2_CONNECTOR                : inout std_logic_vector(7 downto 0); --Bit 2-3: LED for SFP7/8
    FPGA3_CONNECTOR                : inout std_logic_vector(7 downto 0); --Bit 0-1: LED for SFP5/6 
    FPGA4_CONNECTOR                : inout std_logic_vector(7 downto 0); --Bit 0-1: LED for SFP1/2
                                                                         --Bit 0-3 connected to LED by default, two on each side
                                                                         
    --AddOn connector
    ECL_IN                         : in  std_logic_vector(3 downto 0);
    NIM_IN                         : in  std_logic_vector(1 downto 0);
    JIN1                           : in  std_logic_vector(3 downto 0);
    JIN2                           : in  std_logic_vector(3 downto 0);
    JINLVDS                        : in  std_logic_vector(15 downto 0);  --No LVDS, just TTL!
    
    DISCRIMINATOR_IN               : in  std_logic_vector(1 downto 0);
    PWM_OUT                        : out std_logic_vector(1 downto 0);
    
    JOUT1                          : out std_logic_vector(3 downto 0);
    JOUT2                          : out std_logic_vector(3 downto 0);
    JOUTLVDS                       : out std_logic_vector(7 downto 0);
    JTTL                           : inout std_logic_vector(15 downto 0);
    TRG_FANOUT_ADDON               : out std_logic;
    
    LED_BANK                       : out std_logic_vector(7 downto 0);
    LED_RJ_GREEN                   : out std_logic_vector(5 downto 0);
    LED_RJ_RED                     : out std_logic_vector(5 downto 0);
    LED_FAN_GREEN                  : out std_logic;
    LED_FAN_ORANGE                 : out std_logic;
    LED_FAN_RED                    : out std_logic;
    LED_FAN_YELLOW                 : out std_logic;
    
    --Flash ROM & Reboot
    FLASH_CLK                      : out std_logic;
    FLASH_CS                       : out std_logic;
    FLASH_DIN                      : out std_logic;
    FLASH_DOUT                     : in  std_logic;
    PROGRAMN                       : out std_logic := '1'; --reboot FPGA
    
    --Misc
    ENPIRION_CLOCK                 : out std_logic;  --Clock for power supply, not necessary, floating
    TEMPSENS                       : inout std_logic; --Temperature Sensor
    LED_CLOCK_GREEN                : out std_logic;
    LED_CLOCK_RED                  : out std_logic;
    LED_GREEN                      : out std_logic;
    LED_ORANGE                     : out std_logic; 
    LED_RED                        : out std_logic;
    LED_TRIGGER_GREEN              : out std_logic;
    LED_TRIGGER_RED                : out std_logic; 
    LED_YELLOW                     : out std_logic;

    --Test Connectors
    TEST_LINE                      : out std_logic_vector(31 downto 0)
    );


    attribute syn_useioff : boolean;
    --no IO-FF for LEDs relaxes timing constraints
    attribute syn_useioff of LED_CLOCK_GREEN    : signal is false;
    attribute syn_useioff of LED_CLOCK_RED      : signal is false;
    attribute syn_useioff of LED_TRIGGER_GREEN  : signal is false;
    attribute syn_useioff of LED_TRIGGER_RED    : signal is false;
    attribute syn_useioff of LED_GREEN          : signal is false;
    attribute syn_useioff of LED_ORANGE         : signal is false;
    attribute syn_useioff of LED_RED            : signal is false;
    attribute syn_useioff of LED_YELLOW         : signal is false;
    attribute syn_useioff of LED_FAN_GREEN      : signal is false;
    attribute syn_useioff of LED_FAN_ORANGE     : signal is false;
    attribute syn_useioff of LED_FAN_RED        : signal is false;
    attribute syn_useioff of LED_FAN_YELLOW     : signal is false;
    attribute syn_useioff of LED_BANK           : signal is false;
    attribute syn_useioff of LED_RJ_GREEN       : signal is false;
    attribute syn_useioff of LED_RJ_RED         : signal is false;
    attribute syn_useioff of FPGA1_TTL          : signal is false;
    attribute syn_useioff of FPGA2_TTL          : signal is false;
    attribute syn_useioff of FPGA3_TTL          : signal is false;
    attribute syn_useioff of FPGA4_TTL          : signal is false;
    attribute syn_useioff of SFP_TXDIS          : signal is false;
    attribute syn_useioff of PROGRAMN           : signal is false;
    
    --important signals _with_ IO-FF
    attribute syn_useioff of FLASH_CLK          : signal is true;
    attribute syn_useioff of FLASH_CS           : signal is true;
    attribute syn_useioff of FLASH_DIN          : signal is true;
    attribute syn_useioff of FLASH_DOUT         : signal is true;
    attribute syn_useioff of FPGA1_COMM         : signal is true;
    attribute syn_useioff of FPGA2_COMM         : signal is true;
    attribute syn_useioff of FPGA3_COMM         : signal is true;
    attribute syn_useioff of FPGA4_COMM         : signal is true;
    attribute syn_useioff of CLK_MNGR1_USER     : signal is false;
    attribute syn_useioff of CLK_MNGR2_USER     : signal is false;
    attribute syn_useioff of TRIGGER_SELECT     : signal is false;
    attribute syn_useioff of CLOCK_SELECT       : signal is false;
end entity;

architecture trb3_central_arch of trb3_central is
  attribute syn_keep : boolean;
  attribute syn_preserve : boolean;

  signal clk_100_i   : std_logic; --clock for main logic, 100 MHz, via Clock Manager and internal PLL
  signal clk_200_i   : std_logic; --clock for logic at 200 MHz, via Clock Manager and bypassed PLL
  signal clk_125_i   : std_logic; --125 MHz, via Clock Manager and bypassed PLL
  signal clk_20_i    : std_logic; --clock for calibrating the tdc, 20 MHz, via Clock Manager and internal PLL
  signal pll_lock    : std_logic; --Internal PLL locked. E.g. used to reset all internal logic.
  signal clear_i     : std_logic;
  signal reset_i     : std_logic;
  signal GSR_N       : std_logic;
  attribute syn_keep of GSR_N : signal is true;
  attribute syn_preserve of GSR_N : signal is true;

component pll_in200_out100 is
port (
	clk : in std_logic;
	reset : in std_logic;
	clkop : out std_logic;
	clkok : out std_logic;
	lock : out std_logic
);
end component;

component pll_in125_out20 is
port (
	clk : in std_logic;
	clkop : out std_logic;
	clkok : out std_logic;
	lock : out std_logic
);
end component;

component trb_net_reset_handler is
generic(
	reset_delay : std_logic_vector(15 downto 0) := x"1fff"
	);
port (
	CLEAR_IN : in  std_logic;
	clear_n_in : in std_logic;
	clk_in : in std_logic;
	sysclk_in : in std_logic;
	pll_locked_in : in std_logic;
	reset_in : in std_logic;
	trb_reset_in : in std_logic;
	clear_out : out std_logic;
	reset_out : out std_logic;
	debug_out : out std_logic
	);
end component;

  --FPGA Test
  signal time_counter, time_counter2 : unsigned(31 downto 0);

  --Media Interface

  --Hub
  signal my_address              : std_logic_vector (16-1 downto 0);
  signal regio_addr_out          : std_logic_vector (16-1 downto 0);
  signal regio_read_enable_out   : std_logic;
  signal regio_write_enable_out  : std_logic;
  signal regio_data_out          : std_logic_vector (32-1 downto 0);
  signal regio_data_in           : std_logic_vector (32-1 downto 0);
  signal regio_dataready_in      : std_logic;
  signal regio_no_more_data_in   : std_logic;
  signal regio_write_ack_in      : std_logic;
  signal regio_unknown_addr_in   : std_logic;
  signal regio_timeout_out       : std_logic;

  signal spictrl_read_en         : std_logic;
  signal spictrl_write_en        : std_logic;
  signal spictrl_data_in         : std_logic_vector(31 downto 0);
  signal spictrl_addr            : std_logic;
  signal spictrl_data_out        : std_logic_vector(31 downto 0);
  signal spictrl_ack             : std_logic;
  signal spictrl_busy            : std_logic;
  signal spimem_read_en          : std_logic;
  signal spimem_write_en         : std_logic;
  signal spimem_data_in          : std_logic_vector(31 downto 0);
  signal spimem_addr             : std_logic_vector(5 downto 0);
  signal spimem_data_out         : std_logic_vector(31 downto 0);
  signal spimem_ack              : std_logic;

  signal spi_bram_addr           : std_logic_vector(7 downto 0);
  signal spi_bram_wr_d           : std_logic_vector(7 downto 0);
  signal spi_bram_rd_d           : std_logic_vector(7 downto 0);
  signal spi_bram_we             : std_logic;

  signal gbe_cts_number                   : std_logic_vector(15 downto 0);
  signal gbe_cts_code                     : std_logic_vector(7 downto 0);
  signal gbe_cts_information              : std_logic_vector(7 downto 0);
  signal gbe_cts_start_readout            : std_logic;
  signal gbe_cts_readout_type             : std_logic_vector(3 downto 0);
  signal gbe_cts_readout_finished         : std_logic;
  signal gbe_cts_status_bits              : std_logic_vector(31 downto 0);
  signal gbe_fee_data                     : std_logic_vector(15 downto 0);
  signal gbe_fee_dataready                : std_logic;
  signal gbe_fee_read                     : std_logic;
  signal gbe_fee_status_bits              : std_logic_vector(31 downto 0);
  signal gbe_fee_busy                     : std_logic;

  signal stage_stat_regs              : std_logic_vector (31 downto 0);
  signal stage_ctrl_regs              : std_logic_vector (31 downto 0);

  signal mb_stat_reg_data_wr          : std_logic_vector(31 downto 0);
  signal mb_stat_reg_data_rd          : std_logic_vector(31 downto 0);
  signal mb_stat_reg_read             : std_logic;
  signal mb_stat_reg_write            : std_logic;
  signal mb_stat_reg_ack              : std_logic;
  signal mb_ip_mem_addr               : std_logic_vector(15 downto 0); -- only [7:0] in used
  signal mb_ip_mem_data_wr            : std_logic_vector(31 downto 0);
  signal mb_ip_mem_data_rd            : std_logic_vector(31 downto 0);
  signal mb_ip_mem_read               : std_logic;
  signal mb_ip_mem_write              : std_logic;
  signal mb_ip_mem_ack                : std_logic;
  signal ip_cfg_mem_clk				: std_logic;
  signal ip_cfg_mem_addr				: std_logic_vector(7 downto 0);
  signal ip_cfg_mem_data				: std_logic_vector(31 downto 0);
  signal ctrl_reg_addr                : std_logic_vector(15 downto 0);
  signal gbe_stp_reg_addr             : std_logic_vector(15 downto 0);
  signal gbe_stp_data                 : std_logic_vector(31 downto 0);
  signal gbe_stp_reg_ack              : std_logic;
  signal gbe_stp_reg_data_wr          : std_logic_vector(31 downto 0);
  signal gbe_stp_reg_read             : std_logic;
  signal gbe_stp_reg_write            : std_logic;
  signal gbe_stp_reg_data_rd          : std_logic_vector(31 downto 0);

  signal debug : std_logic_vector(63 downto 0);

  signal next_reset, make_reset_via_network_q : std_logic;
  signal reset_counter : std_logic_vector(11 downto 0);
  signal link_ok : std_logic;

  signal gsc_init_data, gsc_reply_data : std_logic_vector(15 downto 0);
  signal gsc_init_read, gsc_reply_read : std_logic;
  signal gsc_init_dataready, gsc_reply_dataready : std_logic;
  signal gsc_init_packet_num, gsc_reply_packet_num : std_logic_vector(2 downto 0);
  signal gsc_busy : std_logic;
  signal mc_unique_id  : std_logic_vector(63 downto 0);
  signal trb_reset_in  : std_logic;
  signal reset_via_gbe : std_logic;
  
  signal reset_ctr : std_logic_vector(31 downto 0);


begin

GSR_N   <= pll_lock;
  
reset_i <= not pll_lock;

---------------------------------------------------------------------------
-- Clock Handling
---------------------------------------------------------------------------
THE_MAIN_PLL : pll_in200_out100
  port map(
    CLK    => CLK_GPLL_LEFT,
    RESET  => '0',
    CLKOP  => clk_100_i,
    CLKOK  => clk_200_i,
    LOCK   => pll_lock
    );

-- generates hits for calibration uncorrelated with tdc clk
THE_CALIBRATION_PLL : pll_in125_out20
	port map (
		CLK   => CLK_GPLL_RIGHT,
		CLKOP => clk_20_i,
		CLKOK => clk_125_i,
		LOCK  => open);

THE_RESET_HANDLER : trb_net_reset_handler
  generic map(
    RESET_DELAY     => x"FEEE"
    )
  port map(
    CLEAR_IN        => '0',             -- reset input (high active, async)
    CLEAR_N_IN      => '1',             -- reset input (low active, async)
    CLK_IN          => clk_200_i,       -- raw master clock, NOT from PLL/DLL!
    SYSCLK_IN       => clk_100_i,       -- PLL/DLL remastered clock
    PLL_LOCKED_IN   => pll_lock,        -- master PLL lock signal (async)
    RESET_IN        => '0',             -- general reset signal (SYSCLK)
    TRB_RESET_IN    => '0',    -- TRBnet reset signal (SYSCLK)
    CLEAR_OUT       => clear_i,         -- async reset out, USE WITH CARE!
    RESET_OUT       => reset_i,    -- synchronous reset out (SYSCLK)
    DEBUG_OUT       => open
  );

  ---------------------------------------------------------------------
  -- The GbE machine for blasting out data from TRBnet
  ---------------------------------------------------------------------
SFP_TXDIS <= (others => '0');

  GBE: trb_net16_gbe_buf
  generic map( 
	  DO_SIMULATION               => 0,
	  USE_125MHZ_EXTCLK           => 0
  )
  port map( 
	  CLK                         => clk_100_i,
	  TEST_CLK                    => '0',
	  CLK_125_IN                  => clk_125_i,
	  RESET                       => reset_i,
	  GSR_N                       => gsr_n,
	  --gk 23.04.10
	  LED_PACKET_SENT_OUT         => open, --buf_SFP_LED_ORANGE(17),
	  LED_AN_DONE_N_OUT           => link_ok, --buf_SFP_LED_GREEN(17),
    --CTS interface
	  --SFP   Connection
	  SFP_RXD_P_IN                => SFP_RX_P(9), --these ports are don't care
	  SFP_RXD_N_IN                => SFP_RX_N(9),
	  SFP_TXD_P_OUT               => SFP_TX_P(9),
	  SFP_TXD_N_OUT               => SFP_TX_N(9),
	  SFP_REFCLK_P_IN             => open, --SFP_REFCLKP(2),
	  SFP_REFCLK_N_IN             => open, --SFP_REFCLKN(2),
	  SFP_PRSNT_N_IN              => SFP_MOD0(8), -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
	  SFP_LOS_IN                  => SFP_LOS(8), -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
	  SFP_TXDIS_OUT               => SFP_TXDIS(8),  -- SFP disable

    -- interface between main_controller and hub logic
    MC_UNIQUE_ID_IN          => mc_unique_id
  );

  FPGA1_TTL <= (others => 'Z');
  FPGA2_TTL <= (others => 'Z');
  FPGA3_TTL <= (others => 'Z');
  FPGA4_TTL <= (others => 'Z');

  FPGA1_CONNECTOR <= (others => 'Z');
  FPGA2_CONNECTOR <= (others => 'Z');
  FPGA3_CONNECTOR <= (others => 'Z');
  FPGA4_CONNECTOR <= (others => 'Z');


---------------------------------------------------------------------------
-- AddOn Connector
---------------------------------------------------------------------------
    PWM_OUT                        <= "00";
    
    JOUT1                          <= x"0";
    JOUT2                          <= x"0";
    JOUTLVDS                       <= x"00";
    JTTL                           <= x"0000";
    TRG_FANOUT_ADDON               <= '0';
    
    LED_BANK                       <= x"FF";
    LED_RJ_GREEN                   <= "111111";
    LED_RJ_RED                     <= "111111";
    LED_FAN_GREEN                  <= '1';
    LED_FAN_ORANGE                 <= '1';
    LED_FAN_RED                    <= '1';
    LED_FAN_YELLOW                 <= '1';


---------------------------------------------------------------------------
-- LED
---------------------------------------------------------------------------


LED_GREEN <= debug(0);
LED_ORANGE <= debug(1);
LED_RED <= debug(2);
LED_YELLOW <= link_ok; --debug(3);


end architecture;