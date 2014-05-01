LIBRARY ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
use IEEE.std_logic_arith.all;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb_net16_hub_func.all;

use work.trb_net_gbe_components.all;
use work.trb_net_gbe_protocols.all;
--use work.version.all;

entity trb_net16_gbe_buf is
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
end entity trb_net16_gbe_buf;

architecture trb_net16_gbe_buf of trb_net16_gbe_buf is

-- Placer Directives
--attribute HGROUP : string;
-- for whole architecture
--attribute HGROUP of trb_net16_gbe_buf : architecture is "GBE_BUF_group";


component tsmac36 --tsmac35
port(
	--------------- clock and reset port declarations ------------------
	hclk					: in	std_logic;
	txmac_clk				: in	std_logic;
	rxmac_clk				: in	std_logic;
	reset_n					: in	std_logic;
	txmac_clk_en			: in	std_logic;
	rxmac_clk_en			: in	std_logic;
	------------------- Input signals to the GMII ----------------
	rxd						: in	std_logic_vector(7 downto 0);
	rx_dv					: in	std_logic;
	rx_er					: in	std_logic;
	col						: in	std_logic;
	crs						: in	std_logic;
	-------------------- Input signals to the CPU I/F -------------------
	haddr					: in	std_logic_vector(7 downto 0);
	hdatain					: in	std_logic_vector(7 downto 0);
	hcs_n					: in	std_logic;
	hwrite_n				: in	std_logic;
	hread_n					: in	std_logic;
	---------------- Input signals to the Tx MAC FIFO I/F ---------------
	tx_fifodata				: in	std_logic_vector(7 downto 0);
	tx_fifoavail			: in	std_logic;
	tx_fifoeof				: in	std_logic;
	tx_fifoempty			: in	std_logic;
	tx_sndpaustim			: in	std_logic_vector(15 downto 0);
	tx_sndpausreq			: in	std_logic;
	tx_fifoctrl				: in	std_logic;
	---------------- Input signals to the Rx MAC FIFO I/F --------------- 
	rx_fifo_full			: in	std_logic;
	ignore_pkt				: in	std_logic;
	-------------------- Output signals from the GMII -----------------------
	txd						: out	std_logic_vector(7 downto 0);  
	tx_en					: out	std_logic;
	tx_er					: out	std_logic;
	-------------------- Output signals from the CPU I/F -------------------
	hdataout				: out	std_logic_vector(7 downto 0);
	hdataout_en_n			: out	std_logic;
	hready_n				: out	std_logic;
	cpu_if_gbit_en			: out	std_logic;
	---------------- Output signals from the Tx MAC FIFO I/F --------------- 
	tx_macread				: out	std_logic;
	tx_discfrm				: out	std_logic;
	tx_staten				: out	std_logic;
	tx_done					: out	std_logic;
	tx_statvec				: out	std_logic_vector(30 downto 0);
	---------------- Output signals from the Rx MAC FIFO I/F ---------------   
	rx_fifo_error			: out	std_logic;
	rx_stat_vector			: out	std_logic_vector(31 downto 0);
	rx_dbout				: out	std_logic_vector(7 downto 0);
	rx_write				: out	std_logic;
	rx_stat_en				: out	std_logic;
	rx_eof					: out	std_logic;
	rx_error				: out	std_logic
);
end component; 

signal fc_dest_mac				: std_logic_vector(47 downto 0);
signal fc_dest_ip				: std_logic_vector(31 downto 0);
signal fc_dest_udp				: std_logic_vector(15 downto 0);
signal fc_src_mac				: std_logic_vector(47 downto 0);
signal fc_src_ip				: std_logic_vector(31 downto 0);
signal fc_src_udp				: std_logic_vector(15 downto 0);
signal fc_type					: std_logic_vector(15 downto 0);
signal fc_ihl_version			: std_logic_vector(7 downto 0);
signal fc_tos					: std_logic_vector(7 downto 0);
signal fc_ttl					: std_logic_vector(7 downto 0);
signal fc_protocol				: std_logic_vector(7 downto 0);
signal fc_bsm_constr			: std_logic_vector(7 downto 0);
signal fc_bsm_trans				: std_logic_vector(3 downto 0);

signal ft_data					: std_logic_vector(8 downto 0);-- gk 04.05.10
signal ft_tx_empty				: std_logic;
signal ft_start_of_packet		: std_logic;
signal ft_bsm_init				: std_logic_vector(3 downto 0);
signal ft_bsm_mac				: std_logic_vector(3 downto 0);
signal ft_bsm_trans				: std_logic_vector(3 downto 0);

signal mac_haddr				: std_logic_vector(7 downto 0);
signal mac_hdataout				: std_logic_vector(7 downto 0);
signal mac_hcs					: std_logic;
signal mac_hwrite				: std_logic;
signal mac_hread				: std_logic;
signal mac_fifoavail			: std_logic;
signal mac_fifoempty			: std_logic;
signal mac_fifoeof				: std_logic;
signal mac_hready				: std_logic;
signal mac_hdata_en				: std_logic;
signal mac_tx_done				: std_logic;
signal mac_tx_read				: std_logic;

signal serdes_clk_125			: std_logic;
signal mac_tx_clk_en			: std_logic;
signal mac_rx_clk_en			: std_logic;
signal mac_col					: std_logic;
signal mac_crs					: std_logic;
signal pcs_txd					: std_logic_vector(7 downto 0);
signal pcs_tx_en				: std_logic;
signal pcs_tx_er				: std_logic;
signal pcs_an_lp_ability		: std_logic_vector(15 downto 0);
signal pcs_an_complete			: std_logic;
signal pcs_an_page_rx			: std_logic;

signal pcs_stat_debug			: std_logic_vector(63 downto 0); 

signal dbg_fc1                       : std_logic_vector(31 downto 0);
signal dbg_fc2                       : std_logic_vector(31 downto 0);
-- gk 08.06.10
signal mac_tx_staten                 : std_logic;
signal mac_tx_statevec               : std_logic_vector(30 downto 0);
signal mac_tx_discfrm                : std_logic;

signal dbg_q                         : std_logic_vector(15 downto 0);

signal link_ok                       : std_logic;

-- gk 09.12.10
signal frame_delay                   : std_logic_vector(31 downto 0);

-- gk 13.02.11
signal pcs_rxd                       : std_logic_vector(7 downto 0);
signal pcs_rx_en                     : std_logic;
signal pcs_rx_er                     : std_logic;
signal mac_rx_eof                    : std_logic;
signal mac_rx_er                     : std_logic;
signal mac_rxd                       : std_logic_vector(7 downto 0);
signal mac_rx_fifo_err               : std_logic;
signal mac_rx_fifo_full              : std_logic;
signal mac_rx_en                     : std_logic;
signal mac_rx_stat_en                : std_logic;
signal mac_rx_stat_vec               : std_logic_vector(31 downto 0);
signal fr_q                          : std_logic_vector(8 downto 0);
signal fr_rd_en                      : std_logic;
signal fr_frame_valid                : std_logic;
signal rc_rd_en                      : std_logic;
signal rc_q                          : std_logic_vector(8 downto 0);
signal rc_frames_rec_ctr             : std_logic_vector(31 downto 0);
signal mc_data                       : std_logic_vector(8 downto 0);
signal mc_wr_en                      : std_logic;
signal fc_wr_en                      : std_logic;
signal fc_data                       : std_logic_vector(7 downto 0);
signal fc_ip_size                    : std_logic_vector(15 downto 0);
signal fc_udp_size                   : std_logic_vector(15 downto 0);
signal fc_ident                      : std_logic_vector(15 downto 0);
signal fc_flags_offset               : std_logic_vector(15 downto 0);
signal fc_sod                        : std_logic;
signal fc_eod                        : std_logic;
signal fc_h_ready                    : std_logic;
signal fc_ready                      : std_logic;
signal rc_frame_ready                : std_logic;
signal allow_rx                      : std_logic;
signal fr_frame_size                 : std_logic_vector(15 downto 0);
signal rc_frame_size                 : std_logic_vector(15 downto 0);
signal mc_frame_size                 : std_logic_vector(15 downto 0);
signal rc_bytes_rec                  : std_logic_vector(31 downto 0);
signal rc_debug                      : std_logic_vector(63 downto 0);
signal tsmac_gbit_en                 : std_logic;
signal mc_transmit_ctrl              : std_logic;
signal rc_loading_done               : std_logic;
signal fr_get_frame                  : std_logic;
signal mc_transmit_done              : std_logic;

signal dbg_fr                        : std_logic_vector(95 downto 0);
signal dbg_mc                        : std_logic_vector(63 downto 0);
signal dbg_tc                        : std_logic_vector(63 downto 0);

signal fr_frame_proto                : std_logic_vector(15 downto 0);
signal rc_frame_proto                : std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0);

signal dbg_select_rec                : std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);
signal dbg_select_sent               : std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);
signal dbg_select_protos             : std_logic_vector(c_MAX_PROTOCOLS * 64 - 1 downto 0);
	
signal serdes_rx_clk                 : std_logic;

signal vlan_id                       : std_logic_vector(31 downto 0);
signal mc_type                       : std_logic_vector(15 downto 0);
signal fr_src_mac                : std_logic_vector(47 downto 0);
signal fr_dest_mac               : std_logic_vector(47 downto 0);
signal fr_src_ip                 : std_logic_vector(31 downto 0);
signal fr_dest_ip                : std_logic_vector(31 downto 0);
signal fr_src_udp                : std_logic_vector(15 downto 0);
signal fr_dest_udp               : std_logic_vector(15 downto 0);
signal rc_src_mac                : std_logic_vector(47 downto 0);
signal rc_dest_mac               : std_logic_vector(47 downto 0);
signal rc_src_ip                 : std_logic_vector(31 downto 0);
signal rc_dest_ip                : std_logic_vector(31 downto 0);
signal rc_src_udp                : std_logic_vector(15 downto 0);
signal rc_dest_udp               : std_logic_vector(15 downto 0);

signal mc_dest_mac			: std_logic_vector(47 downto 0);
signal mc_dest_ip			: std_logic_vector(31 downto 0);
signal mc_dest_udp			: std_logic_vector(15 downto 0);
signal mc_src_mac			: std_logic_vector(47 downto 0);
signal mc_src_ip			: std_logic_vector(31 downto 0);
signal mc_src_udp			: std_logic_vector(15 downto 0);

signal dbg_ft                        : std_logic_vector(63 downto 0);

signal fr_ip_proto                   : std_logic_vector(7 downto 0);
signal mc_ip_proto                   : std_logic_vector(7 downto 0);

attribute syn_preserve : boolean;
attribute syn_keep : boolean;
attribute syn_keep of pcs_rxd, pcs_txd, pcs_rx_en, pcs_tx_en, pcs_rx_er, pcs_tx_er : signal is true;
attribute syn_preserve of pcs_rxd, pcs_txd, pcs_rx_en, pcs_tx_en, pcs_rx_er, pcs_tx_er : signal is true;

signal pcs_txd_q, pcs_rxd_q : std_logic_vector(7 downto 0);
signal pcs_tx_en_q, pcs_tx_er_q, pcs_rx_en_q, pcs_rx_er_q : std_logic;

signal pcs_txd_qq, pcs_rxd_qq : std_logic_vector(7 downto 0);
signal pcs_tx_en_qq, pcs_tx_er_qq, pcs_rx_en_qq, pcs_rx_er_qq : std_logic;

signal timeout_noticed : std_Logic;
attribute syn_keep of timeout_noticed : signal is true;
attribute syn_preserve of timeout_noticed : signal is true;

signal idle_too_long : std_logic;

signal mc_ident : std_logic_vector(15 downto 0);


begin
-- gk 23.04.10
LED_PACKET_SENT_OUT <= '0'; --timeout_noticed; --pc_ready;
LED_AN_DONE_N_OUT   <= '0'; --not link_ok; --not pcs_an_complete;

fc_ihl_version      <= x"45";
fc_tos              <= x"10";
fc_ttl              <= x"ff";

MAIN_CONTROL : trb_net16_gbe_main_control
  port map(
	  CLK			=> CLK,
	  CLK_125		=> serdes_clk_125,
	  RESET			=> RESET,

	  MC_LINK_OK_OUT	=> link_ok,
	  MC_RESET_LINK_IN	=> '0',
	  MC_IDLE_TOO_LONG_OUT => idle_too_long,

  -- signals to/from receive controller
	  RC_FRAME_WAITING_IN	=> rc_frame_ready,
	  RC_LOADING_DONE_OUT	=> rc_loading_done,
	  RC_DATA_IN		=> rc_q,
	  RC_RD_EN_OUT		=> rc_rd_en,
	  RC_FRAME_SIZE_IN	=> rc_frame_size,
	  RC_FRAME_PROTO_IN	=> rc_frame_proto,

	  RC_SRC_MAC_ADDRESS_IN	=> rc_src_mac,
	  RC_DEST_MAC_ADDRESS_IN  => rc_dest_mac,
	  RC_SRC_IP_ADDRESS_IN	=> rc_src_ip,
	  RC_DEST_IP_ADDRESS_IN	=> rc_dest_ip,
	  RC_SRC_UDP_PORT_IN	=> rc_src_udp,
	  RC_DEST_UDP_PORT_IN	=> rc_dest_udp,

  -- signals to/from transmit controller
	  TC_TRANSMIT_CTRL_OUT	=> mc_transmit_ctrl,
	  TC_DATA_OUT		=> mc_data,
	  TC_RD_EN_IN		=> mc_wr_en,
	  --TC_DATA_NOT_VALID_OUT => tc_data_not_valid,
	  TC_FRAME_SIZE_OUT	=> mc_frame_size,
	  TC_FRAME_TYPE_OUT	=> mc_type,
	  TC_IP_PROTOCOL_OUT	=> mc_ip_proto,
	  TC_IDENT_OUT          => mc_ident,
	  
	  TC_DEST_MAC_OUT	=> mc_dest_mac,
	  TC_DEST_IP_OUT	=> mc_dest_ip,
	  TC_DEST_UDP_OUT	=> mc_dest_udp,
	  TC_SRC_MAC_OUT	=> mc_src_mac,
	  TC_SRC_IP_OUT		=> mc_src_ip,
	  TC_SRC_UDP_OUT	=> mc_src_udp,
	  TC_TRANSMIT_DONE_IN   => mc_transmit_done,

  -- signals to/from sgmii/gbe pcs_an_complete
	  PCS_AN_COMPLETE_IN	=> pcs_an_complete,

  -- signals to/from hub
	  MC_UNIQUE_ID_IN	=> MC_UNIQUE_ID_IN,
	  
	CFG_GBE_ENABLE_IN           => '1',
	CFG_IPU_ENABLE_IN           => '1',
	CFG_MULT_ENABLE_IN          => '1',
	
	SCTRL_DEST_MAC_IN       => SCTRL_DEST_MAC_IN,
	SCTRL_DEST_IP_IN        => SCTRL_DEST_IP_IN,
	SCTRL_DEST_UDP_IN       => SCTRL_DEST_UDP_IN,

	LL_DATA_IN              => LL_DATA_IN,
	LL_REM_IN               => LL_REM_IN,
	LL_SOF_N_IN             => LL_SOF_N_IN,
	LL_EOF_N_IN             => LL_EOF_N_IN,
	LL_SRC_READY_N_IN       => LL_SRC_READY_N_IN,
	LL_DST_READY_N_OUT      => LL_DST_READY_N_OUT,
	LL_READ_CLK_OUT         => LL_READ_CLK_OUT,
	

  -- signal to/from Host interface of TriSpeed MAC
	  TSM_HADDR_OUT		=> mac_haddr,
	  TSM_HDATA_OUT		=> mac_hdataout,
	  TSM_HCS_N_OUT		=> mac_hcs,
	  TSM_HWRITE_N_OUT	=> mac_hwrite,
	  TSM_HREAD_N_OUT	=> mac_hread,
	  TSM_HREADY_N_IN	=> mac_hready,
	  TSM_HDATA_EN_N_IN	=> mac_hdata_en,
	  TSM_RX_STAT_VEC_IN  => mac_rx_stat_vec,
	  TSM_RX_STAT_EN_IN   => mac_rx_stat_en,
	  
	  SELECT_REC_FRAMES_OUT		=> dbg_select_rec,
	  SELECT_SENT_FRAMES_OUT	=> dbg_select_sent,
	  SELECT_PROTOS_DEBUG_OUT	=> dbg_select_protos,

	  DEBUG_OUT		=> dbg_mc
  );


TRANSMIT_CONTROLLER : trb_net16_gbe_transmit_control2
port map(
	CLK			=> CLK,
	RESET			=> RESET,

-- signal to/from main controller
	TC_DATAREADY_IN        => mc_transmit_ctrl,
	TC_RD_EN_OUT		   => mc_wr_en,
	TC_DATA_IN		       => mc_data(7 downto 0),
	TC_FRAME_SIZE_IN	   => mc_frame_size,
	TC_FRAME_TYPE_IN	   => mc_type,
	TC_IP_PROTOCOL_IN	   => mc_ip_proto,	
	TC_DEST_MAC_IN		   => mc_dest_mac,
	TC_DEST_IP_IN		   => mc_dest_ip,
	TC_DEST_UDP_IN		   => mc_dest_udp,
	TC_SRC_MAC_IN		   => mc_src_mac,
	TC_SRC_IP_IN		   => mc_src_ip,
	TC_SRC_UDP_IN		   => mc_src_udp,
	TC_TRANSMISSION_DONE_OUT => mc_transmit_done,
	TC_IDENT_IN            => mc_ident,

-- signal to/from frame constructor
	FC_DATA_OUT		=> fc_data,
	FC_WR_EN_OUT		=> fc_wr_en,
	FC_READY_IN		=> fc_ready,
	FC_H_READY_IN		=> fc_h_ready,
	FC_FRAME_TYPE_OUT	=> fc_type,
	FC_IP_SIZE_OUT		=> fc_ip_size,
	FC_UDP_SIZE_OUT		=> fc_udp_size,
	FC_IDENT_OUT		=> fc_ident,
	FC_FLAGS_OFFSET_OUT	=> fc_flags_offset,
	FC_SOD_OUT		=> fc_sod,
	FC_EOD_OUT		=> fc_eod,
	FC_IP_PROTOCOL_OUT	=> fc_protocol,

	DEST_MAC_ADDRESS_OUT    => fc_dest_mac,
	DEST_IP_ADDRESS_OUT     => fc_dest_ip,
	DEST_UDP_PORT_OUT       => fc_dest_udp,
	SRC_MAC_ADDRESS_OUT     => fc_src_mac,
	SRC_IP_ADDRESS_OUT      => fc_src_ip,
	SRC_UDP_PORT_OUT        => fc_src_udp,

-- debug
	MONITOR_TX_PACKETS_OUT		=> open
);

-- Third stage: Frame Constructor
FRAME_CONSTRUCTOR: trb_net16_gbe_frame_constr
port map( 
	-- ports for user logic
	RESET				=> RESET,
	CLK				=> CLK,
	LINK_OK_IN			=> link_ok, --pcs_an_complete,  -- gk 03.08.10  -- gk 30.09.10
	--
	WR_EN_IN			=> fc_wr_en,
	DATA_IN				=> fc_data,
	START_OF_DATA_IN		=> fc_sod,
	END_OF_DATA_IN			=> fc_eod,
	IP_F_SIZE_IN			=> fc_ip_size,
	UDP_P_SIZE_IN			=> fc_udp_size,
	HEADERS_READY_OUT		=> fc_h_ready,
	READY_OUT			=> fc_ready,
	DEST_MAC_ADDRESS_IN		=> fc_dest_mac,
	DEST_IP_ADDRESS_IN		=> fc_dest_ip,
	DEST_UDP_PORT_IN		=> fc_dest_udp,
	SRC_MAC_ADDRESS_IN		=> fc_src_mac,
	SRC_IP_ADDRESS_IN		=> fc_src_ip,
	SRC_UDP_PORT_IN			=> fc_src_udp,
	FRAME_TYPE_IN			=> fc_type,
	IHL_VERSION_IN			=> fc_ihl_version,
	TOS_IN				=> fc_tos,
	IDENTIFICATION_IN		=> fc_ident,
	FLAGS_OFFSET_IN			=> fc_flags_offset,
	TTL_IN				=> fc_ttl,
	PROTOCOL_IN			=> fc_protocol,
	FRAME_DELAY_IN			=> frame_delay, -- gk 09.12.10
	-- ports for packetTransmitter
	RD_CLK				=> serdes_clk_125,
	FT_DATA_OUT 			=> ft_data,
	--FT_EOD_OUT			=> ft_eod, -- gk 04.05.10
	FT_TX_EMPTY_OUT			=> ft_tx_empty,
	FT_TX_RD_EN_IN			=> mac_tx_read,
	FT_START_OF_PACKET_OUT		=> ft_start_of_packet,
	FT_TX_DONE_IN			=> mac_tx_done,
	FT_TX_DISCFRM_IN		=> mac_tx_discfrm,
	-- debug ports
	MONITOR_TX_BYTES_OUT    => open,
	MONITOR_TX_FRAMES_OUT   => open
);


RECEIVE_CONTROLLER : trb_net16_gbe_receive_control
port map(
	CLK			=> CLK,
	RESET			=> RESET,

-- signals to/from frame_receiver
	RC_DATA_IN		=> fr_q,
	FR_RD_EN_OUT		=> fr_rd_en,
	FR_FRAME_VALID_IN	=> fr_frame_valid,
	FR_GET_FRAME_OUT	=> fr_get_frame,
	FR_FRAME_SIZE_IN	=> fr_frame_size,
	FR_FRAME_PROTO_IN	=> fr_frame_proto,
	FR_IP_PROTOCOL_IN	=> fr_ip_proto,
	
	FR_SRC_MAC_ADDRESS_IN	=> fr_src_mac,
	FR_DEST_MAC_ADDRESS_IN  => fr_dest_mac,
	FR_SRC_IP_ADDRESS_IN	=> fr_src_ip,
	FR_DEST_IP_ADDRESS_IN	=> fr_dest_ip,
	FR_SRC_UDP_PORT_IN	=> fr_src_udp,
	FR_DEST_UDP_PORT_IN	=> fr_dest_udp,

-- signals to/from main controller
	RC_RD_EN_IN		=> rc_rd_en,
	RC_Q_OUT		=> rc_q,
	RC_FRAME_WAITING_OUT	=> rc_frame_ready,
	RC_LOADING_DONE_IN	=> rc_loading_done,
	RC_FRAME_SIZE_OUT	=> rc_frame_size,
	RC_FRAME_PROTO_OUT	=> rc_frame_proto,
	
	RC_SRC_MAC_ADDRESS_OUT	=> rc_src_mac,
	RC_DEST_MAC_ADDRESS_OUT => rc_dest_mac,
	RC_SRC_IP_ADDRESS_OUT	=> rc_src_ip,
	RC_DEST_IP_ADDRESS_OUT	=> rc_dest_ip,
	RC_SRC_UDP_PORT_OUT	=> rc_src_udp,
	RC_DEST_UDP_PORT_OUT	=> rc_dest_udp,

-- statistics
	FRAMES_RECEIVED_OUT	=> rc_frames_rec_ctr,
	BYTES_RECEIVED_OUT      => rc_bytes_rec,


	DEBUG_OUT		=> rc_debug
);
dbg_q(15 downto 9) <= (others  => '0');

FRAME_TRANSMITTER: trb_net16_gbe_frame_trans
port map( 
	CLK				=> CLK,
	RESET				=> RESET,
	LINK_OK_IN			=> link_ok, --pcs_an_complete,  -- gk 03.08.10  -- gk 30.09.10
	TX_MAC_CLK			=> serdes_clk_125,
	TX_EMPTY_IN			=> ft_tx_empty,
	START_OF_PACKET_IN		=> ft_start_of_packet,
	DATA_ENDFLAG_IN			=> ft_data(8),  -- ft_eod -- gk 04.05.10
	
	TX_FIFOAVAIL_OUT		=> mac_fifoavail,
	TX_FIFOEOF_OUT			=> mac_fifoeof,
	TX_FIFOEMPTY_OUT		=> mac_fifoempty,
	TX_DONE_IN			=> mac_tx_done,	
	TX_STAT_EN_IN			=> mac_tx_staten,
	TX_STATVEC_IN			=> mac_tx_statevec,
	TX_DISCFRM_IN			=> mac_tx_discfrm,
	-- Debug
	BSM_INIT_OUT			=> ft_bsm_init,
	BSM_MAC_OUT			=> ft_bsm_mac,
	BSM_TRANS_OUT			=> ft_bsm_trans,
	DBG_RD_DONE_OUT			=> open,
	DBG_INIT_DONE_OUT		=> open,
	DBG_ENABLED_OUT			=> open,
	DEBUG_OUT			=> dbg_ft
	--DEBUG_OUT(31 downto 0)		=> open,
	--DEBUG_OUT(63 downto 32)		=> open
);  

  FRAME_RECEIVER : trb_net16_gbe_frame_receiver
  port map(
	  CLK			=> CLK,
	  RESET			=> RESET,
	  LINK_OK_IN		=> link_ok,
	  ALLOW_RX_IN		=> '1',
	  RX_MAC_CLK		=> serdes_rx_clk, --serdes_clk_125,

  -- input signals from TS_MAC
	  MAC_RX_EOF_IN		=> mac_rx_eof,
	  MAC_RX_ER_IN		=> mac_rx_er,
	  MAC_RXD_IN		=> mac_rxd,
	  MAC_RX_EN_IN		=> mac_rx_en,
	  MAC_RX_FIFO_ERR_IN	=> mac_rx_fifo_err,
	  MAC_RX_FIFO_FULL_OUT	=> mac_rx_fifo_full,
	  MAC_RX_STAT_EN_IN	=> mac_rx_stat_en,
	  MAC_RX_STAT_VEC_IN	=> mac_rx_stat_vec,
  -- output signal to control logic
	  FR_Q_OUT		=> fr_q,
	  FR_RD_EN_IN		=> fr_rd_en,
	  FR_FRAME_VALID_OUT	=> fr_frame_valid,
	  FR_GET_FRAME_IN	=> fr_get_frame,
	  FR_FRAME_SIZE_OUT	=> fr_frame_size,
	  FR_FRAME_PROTO_OUT	=> fr_frame_proto,
	  FR_IP_PROTOCOL_OUT	=> fr_ip_proto,
	  FR_ALLOWED_TYPES_IN   => (others => '1'),
	  FR_ALLOWED_IP_IN      => (others => '1'),
	  FR_ALLOWED_UDP_IN     => (others => '1'),
	  FR_VLAN_ID_IN		=> (others => '0'),
	
	FR_SRC_MAC_ADDRESS_OUT	=> fr_src_mac,
	FR_DEST_MAC_ADDRESS_OUT => fr_dest_mac,
	FR_SRC_IP_ADDRESS_OUT	=> fr_src_ip,
	FR_DEST_IP_ADDRESS_OUT	=> fr_dest_ip,
	FR_SRC_UDP_PORT_OUT	=> fr_src_udp,
	FR_DEST_UDP_PORT_OUT	=> fr_dest_udp,

	MONITOR_RX_BYTES_OUT  => open,
	MONITOR_RX_FRAMES_OUT => open,
	MONITOR_DROPPED_OUT   => open
  );	

imp_gen : if (USE_125MHZ_EXTCLK = 0) generate	
	-- MAC part
	MAC: tsmac36 --tsmac35
	port map(
	----------------- clock and reset port declarations ------------------
		hclk				=> CLK,
		txmac_clk			=> serdes_clk_125,
		rxmac_clk			=> serdes_rx_clk, --serdes_clk_125,
		reset_n				=> GSR_N,
		txmac_clk_en			=> mac_tx_clk_en,
		rxmac_clk_en			=> mac_rx_clk_en,
	------------------- Input signals to the GMII ----------------  NOT USED
		rxd				=> pcs_rxd_qq, --x"00",
		rx_dv 				=> pcs_rx_en_qq, --'0',
		rx_er				=> pcs_rx_er_qq, --'0',
		col				=> mac_col,
		crs				=> mac_crs,
	-------------------- Input signals to the CPU I/F -------------------
		haddr				=> mac_haddr,
		hdatain				=> mac_hdataout,
		hcs_n				=> mac_hcs,
		hwrite_n			=> mac_hwrite,
		hread_n				=> mac_hread,
	---------------- Input signals to the Tx MAC FIFO I/F ---------------
		tx_fifodata			=> ft_data(7 downto 0),
		tx_fifoavail			=> mac_fifoavail,
		tx_fifoeof			=> mac_fifoeof,
		tx_fifoempty			=> mac_fifoempty,
		tx_sndpaustim			=> x"0000",
		tx_sndpausreq			=> '0',
		tx_fifoctrl			=> '0',  -- always data frame
	---------------- Input signals to the Rx MAC FIFO I/F --------------- 
		rx_fifo_full			=> mac_rx_fifo_full, --'0',
		ignore_pkt			=> '0',
	---------------- Output signals from the GMII -----------------------
		txd				=> pcs_txd,
		tx_en				=> pcs_tx_en,
		tx_er				=> pcs_tx_er,
	----------------- Output signals from the CPU I/F -------------------
		hdataout			=> open,
		hdataout_en_n			=> mac_hdata_en,
		hready_n			=> mac_hready,
		cpu_if_gbit_en			=> tsmac_gbit_en,
	------------- Output signals from the Tx MAC FIFO I/F --------------- 
		tx_macread			=> mac_tx_read,
		tx_discfrm			=> mac_tx_discfrm,
		tx_staten			=> mac_tx_staten,  -- gk 08.06.10
		tx_statvec			=> mac_tx_statevec,  -- gk 08.06.10
		tx_done				=> mac_tx_done,
	------------- Output signals from the Rx MAC FIFO I/F ---------------   
		rx_fifo_error			=> mac_rx_fifo_err, --open,
		rx_stat_vector			=> mac_rx_stat_vec, --open,
		rx_dbout			=> mac_rxd, --open,
		rx_write			=> mac_rx_en, --open,
		rx_stat_en			=> mac_rx_stat_en, --open,
		rx_eof				=> mac_rx_eof, --open,
		rx_error			=> mac_rx_er --open
	);
	
	SYNC_GMII_RX_PROC : process(serdes_rx_clk)
	begin
		if rising_edge(serdes_rx_clk) then
			pcs_rxd_q   <= pcs_rxd;
			pcs_rx_en_q <= pcs_rx_en;
			pcs_rx_er_q <= pcs_rx_er;
			
			pcs_rxd_qq   <= pcs_rxd_q;
			pcs_rx_en_qq <= pcs_rx_en_q;
			pcs_rx_er_qq <= pcs_rx_er_q;
		end if;
	end process SYNC_GMII_RX_PROC;
	
	SYNC_GMII_TX_PROC : process(serdes_clk_125)
	begin
		if rising_edge(serdes_clk_125) then
			pcs_txd_q   <= pcs_txd;
			pcs_tx_en_q <= pcs_tx_en;
			pcs_tx_er_q <= pcs_tx_er;
			
			pcs_txd_qq   <= pcs_txd_q;
			pcs_tx_en_qq <= pcs_tx_en_q;
			pcs_tx_er_qq <= pcs_tx_er_q; 
		end if;
	end process SYNC_GMII_TX_PROC;

	serdes_intclk_gen: if (USE_125MHZ_EXTCLK = 0) generate
		-- PHY part
		PCS_SERDES : trb_net16_med_ecp_sfp_gbe_8b
		generic map(
			USE_125MHZ_EXTCLK		=> 0
		)
		port map(
			RESET				=> RESET,
			GSR_N				=> GSR_N,
			CLK_125_OUT			=> serdes_clk_125,
			CLK_125_RX_OUT			=> serdes_rx_clk,
			CLK_125_IN			=> CLK_125_IN,
			FT_TX_CLK_EN_OUT		=> mac_tx_clk_en,
			FT_RX_CLK_EN_OUT		=> mac_rx_clk_en,
			--connection to frame transmitter (tsmac)
			FT_COL_OUT			=> mac_col,
			FT_CRS_OUT			=> mac_crs,
			FT_TXD_IN			=> pcs_txd_qq,
			FT_TX_EN_IN			=> pcs_tx_en_qq,
			FT_TX_ER_IN			=> pcs_tx_er_qq,
			FT_RXD_OUT			=> pcs_rxd,
			FT_RX_EN_OUT			=> pcs_rx_en,
			FT_RX_ER_OUT			=> pcs_rx_er,
			--SFP Connection
			SD_RXD_P_IN			=> SFP_RXD_P_IN,
			SD_RXD_N_IN			=> SFP_RXD_N_IN,
			SD_TXD_P_OUT			=> SFP_TXD_P_OUT,
			SD_TXD_N_OUT			=> SFP_TXD_N_OUT,
			SD_REFCLK_P_IN			=> SFP_REFCLK_P_IN,
			SD_REFCLK_N_IN			=> SFP_REFCLK_N_IN,
			SD_PRSNT_N_IN			=> SFP_PRSNT_N_IN,
			SD_LOS_IN			=> SFP_LOS_IN,
			SD_TXDIS_OUT			=> SFP_TXDIS_OUT,
			-- Autonegotiation stuff
			MR_ADV_ABILITY_IN		=> x"0020", -- full duplex only
			MR_AN_LP_ABILITY_OUT		=> pcs_an_lp_ability,
			MR_AN_PAGE_RX_OUT		=> pcs_an_page_rx,
			MR_AN_COMPLETE_OUT		=> pcs_an_complete,
			MR_RESET_IN			=> RESET,
			MR_MODE_IN			=> '0',
			MR_AN_ENABLE_IN			=> '1', -- do autonegotiation
			MR_RESTART_AN_IN		=> '0',
			-- Status and control port
			STAT_OP				=> open,
			CTRL_OP				=> x"0000",
			STAT_DEBUG			=> pcs_stat_debug, --open,
			CTRL_DEBUG			=> x"0000_0000_0000_0000"
		);
	end generate serdes_intclk_gen;
end generate imp_gen;

end architecture;
