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
-- maps the frame type and protocol code into internal value which sets the priority

entity trb_net16_gbe_protocol_prioritizer is
port (
	CLK			: in	std_logic;
	RESET			: in	std_logic;
	
	FRAME_TYPE_IN		: in	std_logic_vector(15 downto 0);  -- recovered frame type	
	PROTOCOL_CODE_IN	: in	std_logic_vector(7 downto 0);  -- ip protocol
	UDP_PROTOCOL_IN		: in	std_logic_vector(15 downto 0);
	
	CODE_OUT		: out	std_logic_vector(c_MAX_PROTOCOLS - 1 downto 0)
);
end trb_net16_gbe_protocol_prioritizer;


architecture trb_net16_gbe_protocol_prioritizer of trb_net16_gbe_protocol_prioritizer is

--attribute HGROUP : string;
--attribute HGROUP of trb_net16_gbe_protocol_prioritizer : architecture is "GBE_MAIN_group";

begin

PRIORITIZE : process(CLK, RESET)
begin
	if RESET = '1' then
		CODE_OUT <= (others => '0');
	elsif rising_edge(CLK) then
	
		CODE_OUT <= (others => '0');
				
			--**** HERE ADD YOU PROTOCOL RECOGNITION AT WANTED PRIORITY LEVEL
			-- priority level is the bit position in the CODE_OUT vector
			-- less significant bit has the higher priority
			case FRAME_TYPE_IN is
			
				-- IPv4 
				when x"0800" =>
					if (PROTOCOL_CODE_IN = x"11") then -- UDP
						-- No. 2 = DHCP
						if (UDP_PROTOCOL_IN = x"0044") then  -- DHCP Client
							CODE_OUT(1) <= '1';
						-- No. 4 = SCTRL
--						elsif (UDP_PROTOCOL_IN = x"6590") then -- SCTRL module
--							CODE_OUT(2) <= '1';
						else
							-- branch for pure IPv4
							CODE_OUT <= (others => '0');
						end if;
					-- No. 3 = ICMP 
--					elsif (PROTOCOL_CODE_IN = x"01") then -- ICMP
--						CODE_OUT(4) <= '1';
					else
						CODE_OUT <= (others => '0');
					end if;
				
				-- No. 1 = ARP
				when x"0806" =>
					CODE_OUT(0) <= '1';
				
				-- last slot is reserved for Trash
				when others =>
					CODE_OUT <= (others => '0');
			
			end case;
			
	end if;

end process PRIORITIZE;

end trb_net16_gbe_protocol_prioritizer;


