LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.math_real.all;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 
	component trb_net16_gbe_buf is
	generic( 
		DO_SIMULATION		: integer range 0 to 1 := 1;
		USE_125MHZ_EXTCLK       : integer range 0 to 1 := 1
	);
	port(
	CLK							: in	std_logic;
	TEST_CLK					: in	std_logic; -- only for simulation!
	CLK_125_IN				: in std_logic;  -- gk 28.04.01 used only in internal 125MHz clock mode
	RESET						: in	std_logic;
	GSR_N						: in	std_logic;
	-- gk 23.04.10
	LED_PACKET_SENT_OUT          : out std_logic;
	LED_AN_DONE_N_OUT            : out std_logic;
	--SFP Connection
	SFP_RXD_P_IN				: in	std_logic;
	SFP_RXD_N_IN				: in	std_logic;
	SFP_TXD_P_OUT				: out	std_logic;
	SFP_TXD_N_OUT				: out	std_logic;
	SFP_REFCLK_P_IN				: in	std_logic;
	SFP_REFCLK_N_IN				: in	std_logic;
	SFP_PRSNT_N_IN				: in	std_logic; -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
	SFP_LOS_IN					: in	std_logic; -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
	SFP_TXDIS_OUT				: out	std_logic; -- SFP disable
	
		SCTRL_DEST_MAC_IN       : in std_logic_vector(47 downto 0);
	SCTRL_DEST_IP_IN        : in std_logic_vector(31 downto 0);
	SCTRL_DEST_UDP_IN       : in std_logic_vector(15 downto 0);

	LL_DATA_IN              : in std_logic_vector(31 downto 0);
	LL_REM_IN               : in std_logic_vector(1 downto 0);
	LL_SOF_N_IN             : in std_logic;
	LL_EOF_N_IN             : in std_logic;
	LL_SRC_READY_N_IN       : in std_logic;
	LL_DST_READY_N_OUT      : out std_logic;
	LL_READ_CLK_OUT         : out std_logic;
	
	-- interface between main_controller and hub logic
	MC_UNIQUE_ID_IN          : in std_logic_vector(63 downto 0)
);
	END COMPONENT;
	
	component local_link_dummy is
generic (
	DO_SIMULATION        : integer range 0 to 1 := 1
);
port (
	RESET_N               : in std_logic;
	LL_DATA_OUT           : out std_logic_vector(31 downto 0);
	LL_REM_OUT            : out std_logic_vector(1 downto 0);
	LL_SOF_N_OUT          : out std_logic;
	LL_EOF_N_OUT          : out std_logic;
	LL_SRC_READY_N_OUT    : out std_logic;
	LL_DST_READY_N_IN     : in std_logic;
	LL_LEN_OUT            : out std_logic_vector(15 downto 0);
	LL_LEN_READY_OUT      : out std_logic;
	LL_LEN_ERR_OUT        : out std_logic;
	LL_READ_CLK_IN        : in std_logic
);
end component;
	
	  signal ll_data : std_logic_vector(31 downto 0);
  signal ll_rem : std_logic_vector(1 downto 0);
  signal ll_sof_n, ll_eof_n, ll_src_n, ll_dst_n, ll_clk : std_logic;

	SIGNAL CLK :  std_logic;
	SIGNAL TEST_CLK :  std_logic;
	SIGNAL RESET :  std_logic;
	SIGNAL GSR_N :  std_logic;
	SIGNAL STAGE_STAT_REGS_OUT :  std_logic_vector(31 downto 0);
	SIGNAL STAGE_CTRL_REGS_IN :  std_logic_vector(31 downto 0);
	SIGNAL IP_CFG_START_IN :  std_logic;
	SIGNAL IP_CFG_BANK_SEL_IN :  std_logic_vector(3 downto 0);
	SIGNAL IP_CFG_MEM_DATA_IN :  std_logic_vector(31 downto 0);
	SIGNAL MR_RESET_IN :  std_logic;
	SIGNAL MR_MODE_IN :  std_logic;
	SIGNAL MR_RESTART_IN :  std_logic;
	SIGNAL IP_CFG_MEM_CLK_OUT :  std_logic;
	SIGNAL IP_CFG_DONE_OUT :  std_logic;
	SIGNAL IP_CFG_MEM_ADDR_OUT :  std_logic_vector(7 downto 0);
	SIGNAL CTS_NUMBER_IN :  std_logic_vector(15 downto 0);
	SIGNAL CTS_CODE_IN :  std_logic_vector(7 downto 0);
	SIGNAL CTS_INFORMATION_IN :  std_logic_vector(7 downto 0);
	SIGNAL CTS_READOUT_TYPE_IN :  std_logic_vector(3 downto 0);
	SIGNAL CTS_START_READOUT_IN :  std_logic;
	SIGNAL CTS_DATA_OUT :  std_logic_vector(31 downto 0);
	SIGNAL CTS_DATAREADY_OUT :  std_logic;
	SIGNAL CTS_READOUT_FINISHED_OUT :  std_logic;
	SIGNAL CTS_READ_IN :  std_logic;
	SIGNAL CTS_LENGTH_OUT :  std_logic_vector(15 downto 0);
	SIGNAL CTS_ERROR_PATTERN_OUT :  std_logic_vector(31 downto 0);
	SIGNAL FEE_DATA_IN :  std_logic_vector(15 downto 0);
	SIGNAL FEE_DATAREADY_IN :  std_logic;
	SIGNAL FEE_READ_OUT :  std_logic;
	SIGNAL FEE_STATUS_BITS_IN :  std_logic_vector(31 downto 0);
	SIGNAL FEE_BUSY_IN :  std_logic;
	SIGNAL SFP_RXD_P_IN :  std_logic;
	SIGNAL SFP_RXD_N_IN :  std_logic;
	SIGNAL SFP_TXD_P_OUT :  std_logic;
	SIGNAL SFP_TXD_N_OUT :  std_logic;
	SIGNAL SFP_REFCLK_P_IN :  std_logic;
	SIGNAL SFP_REFCLK_N_IN :  std_logic;
	SIGNAL SFP_PRSNT_N_IN :  std_logic;
	SIGNAL SFP_LOS_IN :  std_logic;
	SIGNAL SFP_TXDIS_OUT :  std_logic;
	SIGNAL ANALYZER_DEBUG_OUT :  std_logic_vector(63 downto 0);
	--gk 29.03.10
	signal SLV_ADDR_IN : std_logic_vector(7 downto 0);
	signal SLV_READ_IN : std_logic;
	signal SLV_WRITE_IN : std_logic;
	signal SLV_BUSY_OUT : std_logic;
	signal SLV_ACK_OUT : std_logic;
	signal SLV_DATA_IN : std_logic_vector(31 downto 0);
	signal SLV_DATA_OUT : std_logic_vector(31 downto 0);
	-- for simulation of receiving part only
	signal MAC_RX_EOF_IN		:	std_logic;
	signal MAC_RXD_IN		:	std_logic_vector(7 downto 0);
	signal MAC_RX_EN_IN		:	std_logic;

BEGIN

-- Please check and add your generic clause manually
	uut: trb_net16_gbe_buf
	GENERIC MAP( DO_SIMULATION => 1, USE_125MHZ_EXTCLK => 1 )
	PORT MAP(
		CLK => CLK,
		CLK_125_IN => test_clk,
		TEST_CLK => TEST_CLK,
		RESET => RESET,
		GSR_N => GSR_N,
	
		LED_PACKET_SENT_OUT => open,
		LED_AN_DONE_N_OUT => open,
		--------------------------
		
		SFP_RXD_P_IN => SFP_RXD_P_IN,
		SFP_RXD_N_IN => SFP_RXD_N_IN,
		SFP_TXD_P_OUT => SFP_TXD_P_OUT,
		SFP_TXD_N_OUT => SFP_TXD_N_OUT,
		SFP_REFCLK_P_IN => SFP_REFCLK_P_IN,
		SFP_REFCLK_N_IN => SFP_REFCLK_N_IN,
		SFP_PRSNT_N_IN => SFP_PRSNT_N_IN,
		SFP_LOS_IN => SFP_LOS_IN,
		SFP_TXDIS_OUT => SFP_TXDIS_OUT,
		
			  
	  SCTRL_DEST_MAC_IN       => x"0000aabbccdd",
	SCTRL_DEST_IP_IN        => x"ffffffff",
	SCTRL_DEST_UDP_IN       => x"1111",
	
	LL_DATA_IN              => ll_data,
	LL_REM_IN               => ll_rem,
	LL_SOF_N_IN             => ll_sof_n,
	LL_EOF_N_IN             => ll_eof_n,
	LL_SRC_READY_N_IN       => ll_src_n,
	LL_DST_READY_N_OUT      => ll_dst_n,
	LL_READ_CLK_OUT         => ll_clk,
		
		
		MC_UNIQUE_ID_IN          => (others => '0')	
	
	);

ll_dummy : local_link_dummy
generic map(
	DO_SIMULATION        => 1
)
port map(
	RESET_N               => gsr_n,
	LL_DATA_OUT           => ll_data,
	LL_REM_OUT            => ll_rem,
	LL_SOF_N_OUT          => ll_sof_n,
	LL_EOF_N_OUT          => ll_eof_n,
	LL_SRC_READY_N_OUT    => ll_src_n,
	LL_DST_READY_N_IN     => ll_dst_n,
	LL_LEN_OUT            => open,
	LL_LEN_READY_OUT      => open,
	LL_LEN_ERR_OUT        => open,
	LL_READ_CLK_IN        => ll_clk
);

-- 100 MHz system clock
CLOCK_GEN_PROC: process
begin
	clk <= '1'; wait for 5.0 ns;
	clk <= '0'; wait for 5.0 ns;
end process CLOCK_GEN_PROC;

-- 125 MHz MAC clock
CLOCK2_GEN_PROC: process
begin
	test_clk <= '1'; wait for 4.0 ns;
	test_clk <= '0'; wait for 3.0 ns;
end process CLOCK2_GEN_PROC;

-- Testbench
TESTBENCH_PROC: process

begin

	wait for 100 ns;
	gsr_n <= '0';
	reset <= '1';
	wait for 100 ns;
	reset <= '0';
	gsr_n <= '1';
	

	wait;	
	
end process TESTBENCH_PROC;

END;

