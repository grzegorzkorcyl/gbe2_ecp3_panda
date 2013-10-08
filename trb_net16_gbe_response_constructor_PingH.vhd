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
-- Response Constructor which responds to Ping messages
--

entity trb_net16_gbe_response_constructor_Ping is
generic ( STAT_ADDRESS_BASE : integer := 0
);
port (
	CLK			: in	std_logic;  -- system clock
	RESET			: in	std_logic;
	
-- INTERFACE	
	PS_DATA_IN		: in	std_logic_vector(8 downto 0);
	PS_WR_EN_IN		: in	std_logic;
	PS_ACTIVATE_IN		: in	std_logic;
	PS_RESPONSE_READY_OUT	: out	std_logic;
	PS_BUSY_OUT		: out	std_logic;
	PS_SELECTED_IN		: in	std_logic;
	PS_SRC_MAC_ADDRESS_IN	: in	std_logic_vector(47 downto 0);
	PS_DEST_MAC_ADDRESS_IN  : in	std_logic_vector(47 downto 0);
	PS_SRC_IP_ADDRESS_IN	: in	std_logic_vector(31 downto 0);
	PS_DEST_IP_ADDRESS_IN	: in	std_logic_vector(31 downto 0);
	PS_SRC_UDP_PORT_IN	: in	std_logic_vector(15 downto 0);
	PS_DEST_UDP_PORT_IN	: in	std_logic_vector(15 downto 0);
	
	TC_WR_EN_OUT		: out	std_logic;
	TC_DATA_OUT		: out	std_logic_vector(8 downto 0);
	TC_FRAME_SIZE_OUT	: out	std_logic_vector(15 downto 0);
	TC_FRAME_TYPE_OUT	: out	std_logic_vector(15 downto 0);
	TC_IP_PROTOCOL_OUT	: out	std_logic_vector(7 downto 0);	
	TC_IDENT_OUT        : out	std_logic_vector(15 downto 0);	
	TC_DEST_MAC_OUT		: out	std_logic_vector(47 downto 0);
	TC_DEST_IP_OUT		: out	std_logic_vector(31 downto 0);
	TC_DEST_UDP_OUT		: out	std_logic_vector(15 downto 0);
	TC_SRC_MAC_OUT		: out	std_logic_vector(47 downto 0);
	TC_SRC_IP_OUT		: out	std_logic_vector(31 downto 0);
	TC_SRC_UDP_OUT		: out	std_logic_vector(15 downto 0);
	TC_IP_SIZE_OUT		: out	std_logic_vector(15 downto 0);
	TC_UDP_SIZE_OUT		: out	std_logic_vector(15 downto 0);
	TC_FLAGS_OFFSET_OUT	: out	std_logic_vector(15 downto 0);
	
	TC_BUSY_IN		: in	std_logic;
	
	STAT_DATA_OUT : out std_logic_vector(31 downto 0);
	STAT_ADDR_OUT : out std_logic_vector(7 downto 0);
	STAT_DATA_RDY_OUT : out std_logic;
	STAT_DATA_ACK_IN  : in std_logic;
		
	RECEIVED_FRAMES_OUT	: out	std_logic_vector(15 downto 0);
	SENT_FRAMES_OUT		: out	std_logic_vector(15 downto 0);
-- END OF INTERFACE

-- debug
	DEBUG_OUT		: out	std_logic_vector(31 downto 0)
);
end trb_net16_gbe_response_constructor_Ping;


architecture trb_net16_gbe_response_constructor_Ping of trb_net16_gbe_response_constructor_Ping is

attribute syn_encoding	: string;

type dissect_states is (IDLE, READ_FRAME, WAIT_FOR_LOAD, LOAD_FRAME, CLEANUP);
signal dissect_current_state, dissect_next_state : dissect_states;
attribute syn_encoding of dissect_current_state: signal is "safe,gray";

signal rec_frames               : std_logic_vector(15 downto 0);
signal sent_frames              : std_logic_vector(15 downto 0);

signal saved_data               : std_logic_vector(447 downto 0);
signal saved_headers            : std_logic_vector(63 downto 0);

signal data_ctr                 : integer range 1 to 1500;
signal data_length              : integer range 1 to 1500;
signal tc_data                  : std_logic_vector(8 downto 0);

signal checksum                 : std_logic_vector(15 downto 0);

signal checksum_l, checksum_r   : std_logic_vector(19 downto 0);
signal checksum_ll, checksum_rr : std_logic_vector(15 downto 0);
signal checksum_lll, checksum_rrr : std_logic_vector(15 downto 0);

signal fifo_wr_en, fifo_rd_en   : std_logic;
signal fifo_q                   : std_logic_vector(7 downto 0);

signal tc_wr                    : std_logic;

begin

DISSECT_MACHINE_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') then
			dissect_current_state <= IDLE;
		else
			dissect_current_state <= dissect_next_state;
		end if;
	end if;
end process DISSECT_MACHINE_PROC;

DISSECT_MACHINE : process(dissect_current_state, PS_WR_EN_IN, PS_ACTIVATE_IN, PS_DATA_IN, data_ctr, data_length)
begin
	case dissect_current_state is
	
		when IDLE =>
			if (PS_WR_EN_IN = '1' and PS_ACTIVATE_IN = '1') then
				dissect_next_state <= READ_FRAME;
			else
				dissect_next_state <= IDLE;
			end if;
		
		when READ_FRAME =>
			if (PS_DATA_IN(8) = '1') then
				dissect_next_state <= WAIT_FOR_LOAD;
			else
				dissect_next_state <= READ_FRAME;
			end if;
			
		when WAIT_FOR_LOAD =>
			if (PS_SELECTED_IN = '1') then
				dissect_next_state <= LOAD_FRAME;
			else
				dissect_next_state <= WAIT_FOR_LOAD;
			end if;
		
		when LOAD_FRAME =>
			if (data_ctr = data_length + 1) then
				dissect_next_state <= CLEANUP;
			else
				dissect_next_state <= LOAD_FRAME;
			end if;
		
		when CLEANUP =>
			dissect_next_state <= IDLE;
	
	end case;
end process DISSECT_MACHINE;

DATA_CTR_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') or (dissect_current_state = IDLE) or (dissect_current_state = WAIT_FOR_LOAD) then
			data_ctr <= 2;
		elsif (dissect_current_state = READ_FRAME and PS_WR_EN_IN = '1' and PS_ACTIVATE_IN = '1') then  -- in case of saving data from incoming frame
			data_ctr <= data_ctr + 1;
		elsif (dissect_current_state = LOAD_FRAME and PS_SELECTED_IN = '1') then  -- in case of constructing response
			data_ctr <= data_ctr + 1;
		end if;
	end if;
end process DATA_CTR_PROC;

TC_WR_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (dissect_current_state = LOAD_FRAME and PS_SELECTED_IN = '1') then
			tc_wr <= '1';
		else
			tc_wr <= '0';
		end if;
	end if;
end process TC_WR_PROC;

DATA_LENGTH_PROC: process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') then
			data_length <= 1;
		elsif (dissect_current_state = READ_FRAME and PS_DATA_IN(8) = '1') then
			data_length <= data_ctr;
		end if;
	end if;
end process DATA_LENGTH_PROC;

SAVE_VALUES_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') or (dissect_current_state = IDLE) then
			saved_headers <= (others => '0');
			saved_data    <= (others => '0');
		elsif (dissect_current_state = IDLE and PS_WR_EN_IN = '1' and PS_ACTIVATE_IN = '1') then
			saved_headers(7 downto 0) <= PS_DATA_IN(7 downto 0);
		elsif (dissect_current_state = READ_FRAME) then
			if (data_ctr < 9) then  -- headers
				saved_headers(data_ctr * 8 - 1 downto (data_ctr - 1) * 8) <= PS_DATA_IN(7 downto 0);
			end if;
		elsif (dissect_current_state = LOAD_FRAME) then
			saved_headers(7 downto 0)   <= x"00";
			saved_headers(23 downto 16) <= checksum(7 downto 0);
			saved_headers(31 downto 24) <= checksum(15 downto 8);
		end if;
	end if;
end process SAVE_VALUES_PROC;

fifo : fifo_64kx9
  PORT map(
    Reset   => RESET,
	RPReset => RESET,
    WrClock => CLK,
	RdClock => CLK,
    Data(7 downto 0) => PS_DATA_IN(7 downto 0),
    Data(8) => '0',
    WrEn    => fifo_wr_en,
    RdEn    => fifo_rd_en,
    Q(7 downto 0) => fifo_q,
    Q(8)    => open,
    Full    => open,
    Empty   => open
  );
  
--TODO: change it to synchronous
fifo_wr_en <= '1' when (dissect_current_state = READ_FRAME and data_ctr > 8) else '0';
fifo_rd_en <= '1' when (dissect_current_state = LOAD_FRAME and data_ctr > 8) else '0';

CS_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') or (dissect_current_state = IDLE) then
			checksum_l(19 downto 0)    <= (others => '0');
			checksum_r(19 downto 0)    <= (others => '0');
			checksum_ll(15 downto 0)   <= (others => '0');
			checksum_rr(15 downto 0)   <= (others => '0');
			checksum_lll(15 downto 0)  <= (others => '0');
			checksum_rrr(15 downto 0)  <= (others => '0');
		elsif (dissect_current_state = READ_FRAME and data_ctr > 4) then
			if (std_logic_vector(to_unsigned(data_ctr, 1)) = "0") then
				checksum_l <= checksum_l + PS_DATA_IN(7 downto 0);
			else
				checksum_r <= checksum_r + PS_DATA_IN(7 downto 0);
			end if;
		elsif (dissect_current_state = WAIT_FOR_LOAD and TC_BUSY_IN = '0') then
				checksum_ll <= x"0000" + checksum_l(7 downto 0) + checksum_r(19 downto 8);
				checksum_rr <= x"0000" + checksum_r(7 downto 0) + checksum_l(19 downto 8);
		elsif (dissect_current_state = LOAD_FRAME and data_ctr = 2) then
				checksum_lll <= x"0000" + checksum_ll(7 downto 0) + checksum_rr(15 downto 8);
				checksum_rrr <= x"0000" + checksum_rr(7 downto 0) + checksum_ll(15 downto 8);
		end if;
	end if;
end process CS_PROC;
checksum(7 downto 0)  <= not (checksum_rrr(7 downto 0) + checksum_lll(15 downto 8));
checksum(15 downto 8) <= not (checksum_lll(7 downto 0) + checksum_rrr(15 downto 8));

TC_DATA_PROC : process(dissect_current_state, data_ctr, saved_headers, saved_data, data_length)
begin
	if rising_edge(CLK) then
		tc_data(8) <= '0';
		
		if (dissect_current_state = LOAD_FRAME) then
			if (data_ctr < 10) then  -- headers
				for i in 0 to 7 loop
					tc_data(i) <= saved_headers((data_ctr - 2) * 8 + i);
				end loop;
			else  -- data
				for i in 0 to 7 loop
					tc_data(i) <= fifo_q(i);
				end loop;
			
				-- mark the last byte
				if (data_ctr = data_length + 1) then
					tc_data(8) <= '1';
				end if;
			end if;
		else
			tc_data(7 downto 0) <= (others => '0');	
		end if;
	end if;
end process TC_DATA_PROC;

TC_DATA_OUT <= tc_data;
TC_WR_EN_OUT <= tc_wr;

PS_RESPONSE_SYNC : process(CLK)
begin
	if rising_edge(CLK) then
		if (dissect_current_state = WAIT_FOR_LOAD or dissect_current_state = LOAD_FRAME or dissect_current_state = CLEANUP) then
			PS_RESPONSE_READY_OUT <= '1';
		else
			PS_RESPONSE_READY_OUT <= '0';
		end if;
		
		if (dissect_current_state = IDLE) then
			PS_BUSY_OUT <= '0';
		else
			PS_BUSY_OUT <= '1';
		end if;
	end if;	
end process PS_RESPONSE_SYNC;

TC_FRAME_SIZE_OUT   <= std_logic_vector(to_unsigned(data_length, 16));
TC_IP_SIZE_OUT      <= std_logic_vector(to_unsigned(data_length, 16));
TC_UDP_SIZE_OUT     <= std_logic_vector(to_unsigned(data_length, 16));

TC_FRAME_TYPE_OUT   <= x"0008";
TC_DEST_UDP_OUT     <= x"0000";  -- not used
TC_SRC_MAC_OUT      <= g_MY_MAC;
TC_SRC_IP_OUT       <= g_MY_IP;
TC_SRC_UDP_OUT      <= x"0000";  -- not used
TC_IP_PROTOCOL_OUT  <= X"01"; -- ICMP
TC_FLAGS_OFFSET_OUT <= (others => '0');  -- doesn't matter
TC_IDENT_OUT        <= x"2" & sent_frames(11 downto 0);

ADDR_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (dissect_current_state = READ_FRAME) then
			TC_DEST_MAC_OUT <= PS_SRC_MAC_ADDRESS_IN;
			TC_DEST_IP_OUT  <= PS_SRC_IP_ADDRESS_IN;
		end if;
	end if;
end process ADDR_PROC;

-- needed for identification
SENT_FRAMES_PROC : process(CLK)
begin
	if rising_edge(CLK) then
		if (RESET = '1') then
			sent_frames <= (others => '0');
		elsif (dissect_current_state = CLEANUP) then
			sent_frames <= sent_frames + x"1";
		end if;
	end if;
end process SENT_FRAMES_PROC;

end trb_net16_gbe_response_constructor_Ping;