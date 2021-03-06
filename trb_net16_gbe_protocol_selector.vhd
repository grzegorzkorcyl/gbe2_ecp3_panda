LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.trb_net_std.all;
use work.trb_net_components.all;
use work.trb_net16_hub_func.all;

use work.trb_net_gbe_components.all;
use work.trb_net_gbe_protocols.all;

--********
-- multiplexes between different protocols and manages the responses
-- 
-- 


entity trb_net16_gbe_protocol_selector is
port (
	CLK			: in	std_logic;  -- system clock
	RESET			: in	std_logic;

-- signals to/from main controller
	PS_DATA_IN		: in	std_logic_vector(8 downto 0); 
	PS_WR_EN_IN		: in	std_logic;
	PS_PROTO_SELECT_IN	: in	std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0);
	PS_BUSY_OUT		: out	std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0);
	PS_FRAME_SIZE_IN	: in	std_logic_vector(15 downto 0);
	PS_RESPONSE_READY_OUT	: out	std_logic;
	
	PS_SRC_MAC_ADDRESS_IN	: in	std_logic_vector(47 downto 0);
	PS_DEST_MAC_ADDRESS_IN  : in	std_logic_vector(47 downto 0);
	PS_SRC_IP_ADDRESS_IN	: in	std_logic_vector(31 downto 0);
	PS_DEST_IP_ADDRESS_IN	: in	std_logic_vector(31 downto 0);
	PS_SRC_UDP_PORT_IN	: in	std_logic_vector(15 downto 0);
	PS_DEST_UDP_PORT_IN	: in	std_logic_vector(15 downto 0);
	
-- singals to/from transmit controller with constructed response
	TC_DATA_OUT		: out	std_logic_vector(8 downto 0);
	TC_RD_EN_IN		: in	std_logic;
	TC_FRAME_SIZE_OUT	: out	std_logic_vector(15 downto 0);
	TC_FRAME_TYPE_OUT	: out	std_logic_vector(15 downto 0);
	TC_IP_PROTOCOL_OUT	: out	std_logic_vector(7 downto 0);
	TC_IDENT_OUT        : out   std_logic_vector(15 downto 0);
	TC_DEST_MAC_OUT		: out	std_logic_vector(47 downto 0);
	TC_DEST_IP_OUT		: out	std_logic_vector(31 downto 0);
	TC_DEST_UDP_OUT		: out	std_logic_vector(15 downto 0);
	TC_SRC_MAC_OUT		: out	std_logic_vector(47 downto 0);
	TC_SRC_IP_OUT		: out	std_logic_vector(31 downto 0);
	TC_SRC_UDP_OUT		: out	std_logic_vector(15 downto 0);
	
	MC_BUSY_IN      : in	std_logic;
	
	-- counters from response constructors
	RECEIVED_FRAMES_OUT	: out	std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);
	SENT_FRAMES_OUT		: out	std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);
	PROTOS_DEBUG_OUT	: out	std_logic_vector(c_MAX_PROTOCOLS * 64 - 1 downto 0);
	
	-- misc signals for response constructors
	DHCP_START_IN		: in	std_logic;
	DHCP_DONE_OUT		: out	std_logic;
	
	MAKE_RESET_OUT           : out std_logic;
	
	CFG_GBE_ENABLE_IN            : in std_logic;
	CFG_IPU_ENABLE_IN            : in std_logic;
	CFG_MULT_ENABLE_IN           : in std_logic;
	
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

	-- input for statistics from outside	
	STAT_DATA_IN             : in std_logic_vector(31 downto 0);
	STAT_ADDR_IN             : in std_logic_vector(7 downto 0);
	STAT_DATA_RDY_IN         : in std_logic;
	STAT_DATA_ACK_OUT        : out std_logic;

	DEBUG_OUT		: out	std_logic_vector(63 downto 0)
);
end trb_net16_gbe_protocol_selector;


architecture trb_net16_gbe_protocol_selector of trb_net16_gbe_protocol_selector is

--attribute HGROUP : string;
--attribute HGROUP of trb_net16_gbe_protocol_selector : architecture is "GBE_MAIN_group";

attribute syn_encoding : string;

signal rd_en                    : std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0);
signal resp_ready               : std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0);
signal tc_wr                    : std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0);
signal tc_data                  : std_logic_vector(c_MAX_PROTOCOLS * 9 - 1 downto 0);
signal tc_size                  : std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);
signal tc_type                  : std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);
signal busy                     : std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0);
signal selected                 : std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0);
signal tc_mac                   : std_logic_vector(c_MAX_PROTOCOLS * 48 - 1 downto 0);
signal tc_ip                    : std_logic_vector(c_MAX_PROTOCOLS * 32 - 1 downto 0);
signal tc_udp                   : std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);
signal tc_src_mac               : std_logic_vector(c_MAX_PROTOCOLS * 48 - 1 downto 0);
signal tc_src_ip                : std_logic_vector(c_MAX_PROTOCOLS * 32 - 1 downto 0);
signal tc_src_udp               : std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);
signal tc_ip_proto              : std_logic_vector(c_MAX_PROTOCOLS * 8 - 1 downto 0); 

-- plus 1 is for the outside
signal stat_data                : std_logic_vector(c_MAX_PROTOCOLS * 32 - 1 downto 0);
signal stat_addr                : std_logic_vector(c_MAX_PROTOCOLS * 8 - 1 downto 0);
signal stat_rdy                 : std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0);
signal stat_ack                 : std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0);
signal tc_ip_size               : std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);
signal tc_udp_size              : std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);
signal tc_size_left             : std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);
signal tc_flags_size            : std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);

signal tc_data_not_valid        : std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0);

type select_states is (IDLE, LOOP_OVER, SELECT_ONE, PROCESS_REQUEST, CLEANUP);
signal select_current_state, select_next_state : select_states;
attribute syn_encoding of select_current_state : signal is "onehot";

signal state                    : std_logic_vector(3 downto 0);
signal index                    : integer range 0 to c_MAX_PROTOCOLS - 1;

signal mult                     : std_logic;

signal tc_ident                 : std_logic_vector(c_MAX_PROTOCOLS * 16 - 1 downto 0);
signal zeros                    : std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0);

attribute syn_preserve : boolean;
attribute syn_keep : boolean;
attribute syn_keep of state, mult : signal is true;
attribute syn_preserve of state, mult : signal is true;

begin

zeros <= (others => '0');

-- protocol Nr. 1 ARP
ARP : trb_net16_gbe_response_constructor_ARP
generic map( STAT_ADDRESS_BASE => 6
)
port map (
	CLK						=> CLK,
	RESET					=> RESET,
	
-- INTERFACE	
	PS_DATA_IN				=> PS_DATA_IN,
	PS_WR_EN_IN				=> PS_WR_EN_IN,
	PS_ACTIVATE_IN			=> PS_PROTO_SELECT_IN(0),
	PS_RESPONSE_READY_OUT	=> resp_ready(0),
	PS_BUSY_OUT				=> busy(0),
	PS_SELECTED_IN			=> selected(0),

	PS_SRC_MAC_ADDRESS_IN	=> PS_SRC_MAC_ADDRESS_IN,
	PS_DEST_MAC_ADDRESS_IN  => PS_DEST_MAC_ADDRESS_IN,
	PS_SRC_IP_ADDRESS_IN	=> PS_SRC_IP_ADDRESS_IN,
	PS_DEST_IP_ADDRESS_IN	=> PS_DEST_IP_ADDRESS_IN,
	PS_SRC_UDP_PORT_IN		=> PS_SRC_UDP_PORT_IN,
	PS_DEST_UDP_PORT_IN		=> PS_DEST_UDP_PORT_IN,
	
	TC_RD_EN_IN 			=> TC_RD_EN_IN,
	TC_DATA_OUT				=> tc_data(1 * 9 - 1 downto 0 * 9),
	TC_FRAME_SIZE_OUT		=> tc_size(1 * 16 - 1 downto 0 * 16),
	TC_FRAME_TYPE_OUT		=> tc_type(1 * 16 - 1 downto 0 * 16),
	TC_IP_PROTOCOL_OUT		=> tc_ip_proto(1 * 8 - 1 downto 0 * 8),
	TC_IDENT_OUT            => tc_ident(1 * 16 - 1 downto 0 * 16),
	
	TC_DEST_MAC_OUT			=> tc_mac(1 * 48 - 1 downto 0 * 48),
	TC_DEST_IP_OUT			=> tc_ip(1 * 32 - 1 downto 0 * 32),
	TC_DEST_UDP_OUT			=> tc_udp(1 * 16 - 1 downto 0 * 16),
	TC_SRC_MAC_OUT			=> tc_src_mac(1 * 48 - 1 downto 0 * 48),
	TC_SRC_IP_OUT			=> tc_src_ip(1 * 32 - 1 downto 0 * 32),
	TC_SRC_UDP_OUT			=> tc_src_udp(1 * 16 - 1 downto 0 * 16),
	
	STAT_DATA_OUT 			=> stat_data(1 * 32 - 1 downto 0 * 32),
	STAT_ADDR_OUT 			=> stat_addr(1 * 8 - 1 downto 0 * 8),
	STAT_DATA_RDY_OUT 		=> stat_rdy(0),
	STAT_DATA_ACK_IN  		=> stat_ack(0),
	RECEIVED_FRAMES_OUT		=> RECEIVED_FRAMES_OUT(1 * 16 - 1 downto 0 * 16),
	SENT_FRAMES_OUT			=> SENT_FRAMES_OUT(1 * 16 - 1 downto 0 * 16),
	DEBUG_OUT				=> PROTOS_DEBUG_OUT(1 * 64 - 1 downto 0 * 64)
-- END OF INTERFACE 
);

-- protocol No. 2 DHCP
DHCP : trb_net16_gbe_response_constructor_DHCP
generic map( STAT_ADDRESS_BASE => 0
)
port map (
	CLK			            => CLK,
	RESET			        => RESET,
	
-- INTERFACE	
	PS_DATA_IN		        => PS_DATA_IN,
	PS_WR_EN_IN		        => PS_WR_EN_IN,
	PS_ACTIVATE_IN		    => PS_PROTO_SELECT_IN(1),
	PS_RESPONSE_READY_OUT	=> resp_ready(1),
	PS_BUSY_OUT		        => busy(1),
	PS_SELECTED_IN		    => selected(1),
	
	PS_SRC_MAC_ADDRESS_IN	=> PS_SRC_MAC_ADDRESS_IN,
	PS_DEST_MAC_ADDRESS_IN  => PS_DEST_MAC_ADDRESS_IN,
	PS_SRC_IP_ADDRESS_IN	=> PS_SRC_IP_ADDRESS_IN,
	PS_DEST_IP_ADDRESS_IN	=> PS_DEST_IP_ADDRESS_IN,
	PS_SRC_UDP_PORT_IN	    => PS_SRC_UDP_PORT_IN,
	PS_DEST_UDP_PORT_IN	    => PS_DEST_UDP_PORT_IN,
	 
	TC_RD_EN_IN             => TC_RD_EN_IN,
	TC_DATA_OUT		        => tc_data(2 * 9 - 1 downto 1 * 9),
	TC_FRAME_SIZE_OUT	    => tc_size(2 * 16 - 1 downto 1 * 16),
	TC_FRAME_TYPE_OUT	    => tc_type(2 * 16 - 1 downto 1 * 16),
	TC_IP_PROTOCOL_OUT	    => tc_ip_proto(2 * 8 - 1 downto 1 * 8),
	TC_IDENT_OUT            => tc_ident(2 * 16 - 1 downto 1 * 16),
	 
	TC_DEST_MAC_OUT		    => tc_mac(2 * 48 - 1 downto 1 * 48),
	TC_DEST_IP_OUT		    => tc_ip(2 * 32 - 1 downto 1 * 32),
	TC_DEST_UDP_OUT		    => tc_udp(2 * 16 - 1 downto 1 * 16),
	TC_SRC_MAC_OUT		    => tc_src_mac(2 * 48 - 1 downto 1 * 48),
	TC_SRC_IP_OUT		    => tc_src_ip(2 * 32 - 1 downto 1 * 32),
	TC_SRC_UDP_OUT		    => tc_src_udp(2 * 16 - 1 downto 1 * 16),
	
	STAT_DATA_OUT           => stat_data(2 * 32 - 1 downto 1 * 32),
	STAT_ADDR_OUT           => stat_addr(2 * 8 - 1 downto 1 * 8),
	STAT_DATA_RDY_OUT       => stat_rdy(1),
	STAT_DATA_ACK_IN        => stat_ack(1),
	RECEIVED_FRAMES_OUT	    => RECEIVED_FRAMES_OUT(2 * 16 - 1 downto 1 * 16),
	SENT_FRAMES_OUT		    => SENT_FRAMES_OUT(2 * 16 - 1 downto 1 * 16),
-- END OF INTERFACE

	DHCP_START_IN		    => DHCP_START_IN,
	DHCP_DONE_OUT		    => DHCP_DONE_OUT,
	 
	DEBUG_OUT		        => PROTOS_DEBUG_OUT(1 * 64 - 1 downto 0 * 64)
 );

-- protocol No. 3 Ping
--Ping : trb_net16_gbe_response_constructor_Ping
--generic map( STAT_ADDRESS_BASE => 3
--)
--port map (
--	CLK			            => CLK,
--	RESET			        => RESET,
--	
------ INTERFACE	
--	PS_DATA_IN		        => PS_DATA_IN,
--	PS_WR_EN_IN		        => PS_WR_EN_IN,
--	PS_ACTIVATE_IN		    => PS_PROTO_SELECT_IN(2),
--	PS_RESPONSE_READY_OUT	=> resp_ready(2),
--	PS_BUSY_OUT		        => busy(2),
--	PS_SELECTED_IN		    => selected(2),
--	
--	PS_SRC_MAC_ADDRESS_IN	=> PS_SRC_MAC_ADDRESS_IN,
--	PS_DEST_MAC_ADDRESS_IN  => PS_DEST_MAC_ADDRESS_IN,
--	PS_SRC_IP_ADDRESS_IN	=> PS_SRC_IP_ADDRESS_IN,
--	PS_DEST_IP_ADDRESS_IN	=> PS_DEST_IP_ADDRESS_IN,
--	PS_SRC_UDP_PORT_IN	    => PS_SRC_UDP_PORT_IN,
--	PS_DEST_UDP_PORT_IN	    => PS_DEST_UDP_PORT_IN,
--	
--	TC_RD_EN_IN             => TC_RD_EN_IN,
--	TC_DATA_OUT		        => tc_data(3 * 9 - 1 downto 2 * 9),
--	TC_FRAME_SIZE_OUT	    => tc_size(3 * 16 - 1 downto 2 * 16),
--	TC_FRAME_TYPE_OUT	    => tc_type(3 * 16 - 1 downto 2 * 16),
--	TC_IP_PROTOCOL_OUT	    => tc_ip_proto(3 * 8 - 1 downto 2 * 8),
--	TC_IDENT_OUT            => tc_ident(3 * 16 - 1 downto 2 * 16),
--	
--	TC_DEST_MAC_OUT		    => tc_mac(3 * 48 - 1 downto 2 * 48),
--	TC_DEST_IP_OUT	     	=> tc_ip(3 * 32 - 1 downto 2 * 32),
--	TC_DEST_UDP_OUT		    => tc_udp(3 * 16 - 1 downto 2 * 16),
--	TC_SRC_MAC_OUT		    => tc_src_mac(3 * 48 - 1 downto 2 * 48),
--	TC_SRC_IP_OUT		    => tc_src_ip(3 * 32 - 1 downto 2 * 32),
--	TC_SRC_UDP_OUT		    => tc_src_udp(3 * 16 - 1 downto 2 * 16),
--	
--	STAT_DATA_OUT           => stat_data(3 * 32 - 1 downto 2 * 32),
--	STAT_ADDR_OUT           => stat_addr(3 * 8 - 1 downto 2 * 8),
--	STAT_DATA_RDY_OUT       => stat_rdy(2),
--	STAT_DATA_ACK_IN        => stat_ack(2),
--	RECEIVED_FRAMES_OUT  	=> RECEIVED_FRAMES_OUT(3 * 16 - 1 downto 2 * 16),
--	SENT_FRAMES_OUT		    => SENT_FRAMES_OUT(3 * 16 - 1 downto 2 * 16),
--	DEBUG_OUT		        => PROTOS_DEBUG_OUT(3 * 32 - 1 downto 2 * 32)
---- END OF INTERFACE
--);

DataTX : trb_net16_gbe_response_constructor_DataTX
	port map(
		CLK			            => CLK,
		RESET			        => RESET,
		
	---- INTERFACE	
		PS_DATA_IN		        => PS_DATA_IN,
		PS_WR_EN_IN		        => PS_WR_EN_IN,
		PS_ACTIVATE_IN		    => PS_PROTO_SELECT_IN(2),
		PS_RESPONSE_READY_OUT	=> resp_ready(2),
		PS_BUSY_OUT		        => busy(2),
		PS_SELECTED_IN		    => selected(2),
		
		PS_SRC_MAC_ADDRESS_IN	=> PS_SRC_MAC_ADDRESS_IN,
		PS_DEST_MAC_ADDRESS_IN  => PS_DEST_MAC_ADDRESS_IN,
		PS_SRC_IP_ADDRESS_IN	=> PS_SRC_IP_ADDRESS_IN,
		PS_DEST_IP_ADDRESS_IN	=> PS_DEST_IP_ADDRESS_IN,
		PS_SRC_UDP_PORT_IN	    => PS_SRC_UDP_PORT_IN,
		PS_DEST_UDP_PORT_IN	    => PS_DEST_UDP_PORT_IN,
		
		TC_RD_EN_IN             => TC_RD_EN_IN,
		TC_DATA_OUT		        => tc_data(3 * 9 - 1 downto 2 * 9),
		TC_FRAME_SIZE_OUT	    => tc_size(3 * 16 - 1 downto 2 * 16),
		TC_FRAME_TYPE_OUT	    => tc_type(3 * 16 - 1 downto 2 * 16),
		TC_IP_PROTOCOL_OUT	    => tc_ip_proto(3 * 8 - 1 downto 2 * 8),
		TC_IDENT_OUT            => tc_ident(3 * 16 - 1 downto 2 * 16),
		
		TC_DEST_MAC_OUT		    => tc_mac(3 * 48 - 1 downto 2 * 48),
		TC_DEST_IP_OUT	     	=> tc_ip(3 * 32 - 1 downto 2 * 32),
		TC_DEST_UDP_OUT		    => tc_udp(3 * 16 - 1 downto 2 * 16),
		TC_SRC_MAC_OUT		    => tc_src_mac(3 * 48 - 1 downto 2 * 48),
		TC_SRC_IP_OUT		    => tc_src_ip(3 * 32 - 1 downto 2 * 32),
		TC_SRC_UDP_OUT		    => tc_src_udp(3 * 16 - 1 downto 2 * 16),

		
		PS_MY_MAC_IN            => (others => '0'),
		PS_MY_IP_IN             => (others => '0'),
			
		STAT_DATA_OUT           => stat_data(3 * 32 - 1 downto 2 * 32),
		STAT_ADDR_OUT           => stat_addr(3 * 8 - 1 downto 2 * 8),
		STAT_DATA_RDY_OUT       => stat_rdy(2),
		STAT_DATA_ACK_IN        => stat_ack(2),
		RECEIVED_FRAMES_OUT  	=> RECEIVED_FRAMES_OUT(3 * 16 - 1 downto 2 * 16),
		SENT_FRAMES_OUT		    => SENT_FRAMES_OUT(3 * 16 - 1 downto 2 * 16),
		DEBUG_OUT		        => PROTOS_DEBUG_OUT(3 * 64 - 1 downto 2 * 64),
 
	-- END OF INTERFACE
	
	-- protocol specific ports
		UDP_CHECKSUM_OUT        => open,
			
		SCTRL_DEST_MAC_IN       => SCTRL_DEST_MAC_IN,
		SCTRL_DEST_IP_IN        => SCTRL_DEST_IP_IN,
		SCTRL_DEST_UDP_IN       => SCTRL_DEST_UDP_IN,
	
		LL_DATA_IN              => LL_DATA_IN,
		LL_REM_IN               => LL_REM_IN,
		LL_SOF_N_IN             => LL_SOF_N_IN,
		LL_EOF_N_IN             => LL_EOF_N_IN,
		LL_SRC_READY_N_IN       => LL_SRC_READY_N_IN,
		LL_DST_READY_N_OUT      => LL_DST_READY_N_OUT,
		LL_READ_CLK_OUT         => LL_READ_CLK_OUT
	-- end of protocol specific ports
	);
	
--***************
-- DO NOT TOUCH,  response selection logic

--stat_data((c_MAX_PROTOCOLS + 1) * 32 - 1 downto c_MAX_PROTOCOLS * 32) <= STAT_DATA_IN;
--stat_addr((c_MAX_PROTOCOLS + 1) * 8 - 1 downto c_MAX_PROTOCOLS * 8)   <= STAT_ADDR_IN;
--stat_rdy(c_MAX_PROTOCOLS) <= STAT_DATA_RDY_IN;
--STAT_DATA_ACK_OUT <= stat_ack(c_MAX_PROTOCOLS);

--mult <= or_all(resp_ready(2 downto 0)); --or_all(resp_ready(2 downto 0)) and or_all(resp_ready(4 downto 3));

PS_BUSY_OUT <= busy;

SELECT_MACHINE_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') then
			select_current_state <= IDLE;
		else
			select_current_state <= select_next_state;
		end if;
	end if;
end process SELECT_MACHINE_PROC;

SELECT_MACHINE : process(select_current_state, MC_BUSY_IN, resp_ready, index, zeros)
begin
	
	case (select_current_state) is
	
		when IDLE =>
			if (MC_BUSY_IN = '0') then
				select_next_state <= LOOP_OVER;
			else
				select_next_state <= IDLE;
			end if;
		
		when LOOP_OVER =>
			if (resp_ready /= zeros) then
				if (resp_ready(index) = '1') then
					select_next_state <= SELECT_ONE;
				elsif (index = c_MAX_PROTOCOLS) then
					select_next_state <= CLEANUP;
				else
					select_next_state <= LOOP_OVER;
				end if;
			else
				select_next_state <= CLEANUP;
			end if;
			
		when SELECT_ONE =>
			if (MC_BUSY_IN = '1') then
				select_next_state <= PROCESS_REQUEST;
			else
				select_next_state <= SELECT_ONE;
			end if;
			
		when PROCESS_REQUEST =>
			if (MC_BUSY_IN = '0') then
				select_next_state <= CLEANUP;
			else
				select_next_state <= PROCESS_REQUEST;
			end if;
		
		when CLEANUP =>
			select_next_state <= IDLE;
	
	end case;
	
end process SELECT_MACHINE;

INDEX_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') or (select_current_state = IDLE) then
			index <= 0;
		elsif (select_current_state = LOOP_OVER and resp_ready(index) = '0') then
			index <= index + 1;
		else
			index <= index;
		end if;
	end if;
end process INDEX_PROC;

SELECTOR_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') then
			TC_DATA_OUT           <= (others => '0');
			TC_FRAME_SIZE_OUT     <= (others => '0');
			TC_FRAME_TYPE_OUT     <= (others => '0');
			TC_DEST_MAC_OUT       <= (others => '0');
			TC_DEST_IP_OUT        <= (others => '0');
			TC_DEST_UDP_OUT       <= (others => '0');
			TC_SRC_MAC_OUT        <= (others => '0');
			TC_SRC_IP_OUT         <= (others => '0');
			TC_SRC_UDP_OUT        <= (others => '0');
			TC_IP_PROTOCOL_OUT    <= (others => '0');
			TC_IDENT_OUT          <= (others => '0');
			PS_RESPONSE_READY_OUT <= '0';
			selected              <= (others => '0');
		elsif (select_current_state = SELECT_ONE or select_current_state = PROCESS_REQUEST) then
			TC_DATA_OUT           <= tc_data((index + 1) * 9 - 1 downto index * 9);
			TC_FRAME_SIZE_OUT     <= tc_size((index + 1) * 16 - 1 downto index * 16);
			TC_FRAME_TYPE_OUT     <= tc_type((index + 1) * 16 - 1 downto index * 16);
			TC_DEST_MAC_OUT       <= tc_mac((index + 1) * 48 - 1 downto index * 48);
			TC_DEST_IP_OUT        <= tc_ip((index + 1) * 32 - 1 downto index * 32);
			TC_DEST_UDP_OUT       <= tc_udp((index + 1) * 16 - 1 downto index * 16);
			TC_SRC_MAC_OUT        <= tc_src_mac((index + 1) * 48 - 1 downto index * 48);
			TC_SRC_IP_OUT         <= tc_src_ip((index + 1) * 32 - 1 downto index * 32);
			TC_SRC_UDP_OUT        <= tc_src_udp((index + 1) * 16 - 1 downto index * 16);
			TC_IP_PROTOCOL_OUT    <= tc_ip_proto((index + 1) * 8 - 1 downto index * 8);
			TC_IDENT_OUT          <= tc_ident((index + 1) * 16 - 1 downto index * 16);
			if (select_current_state = SELECT_ONE) then
				PS_RESPONSE_READY_OUT <= '1';
				selected(index)       <= '0';
			else
				PS_RESPONSE_READY_OUT <= '0';
				selected(index)       <= '1';
			end if;
		else
			TC_DATA_OUT           <= (others => '0');
			TC_FRAME_SIZE_OUT     <= (others => '0');
			TC_FRAME_TYPE_OUT     <= (others => '0');
			TC_DEST_MAC_OUT       <= (others => '0');
			TC_DEST_IP_OUT        <= (others => '0');
			TC_DEST_UDP_OUT       <= (others => '0');
			TC_SRC_MAC_OUT        <= (others => '0');
			TC_SRC_IP_OUT         <= (others => '0');
			TC_SRC_UDP_OUT        <= (others => '0');
			TC_IP_PROTOCOL_OUT    <= (others => '0');
			TC_IDENT_OUT          <= (others => '0');
			PS_RESPONSE_READY_OUT <= '0';
			selected              <= (others => '0');		
		end if;
	end if;
end process SELECTOR_PROC;

end trb_net16_gbe_protocol_selector;


