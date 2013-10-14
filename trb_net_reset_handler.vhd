library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;


entity trb_net_reset_handler is
generic(
	RESET_DELAY     : std_logic_vector(15 downto 0) := x"1fff"
);
port(
	CLEAR_IN        : in    std_logic; -- reset input (high active, async)
	CLEAR_N_IN      : in    std_logic; -- reset input (low active, async)
	CLK_IN          : in    std_logic; -- raw master clock, NOT from PLL/DLL!
	SYSCLK_IN       : in    std_logic; -- PLL/DLL remastered clock
	PLL_LOCKED_IN   : in    std_logic; -- master PLL lock signal (async)
	RESET_IN        : in    std_logic; -- general reset signal (SYSCLK)
	TRB_RESET_IN    : in    std_logic; -- TRBnet reset signal (SYSCLK)
	CLEAR_OUT       : out   std_logic; -- async reset out, USE WITH CARE!
	RESET_OUT       : out   std_logic; -- synchronous reset out (SYSCLK)
	DEBUG_OUT       : out   std_logic_vector(15 downto 0)
);
end;

-- This reset handler tries to generate a stable synchronous reset
-- for FPGA fabric. It waits for the system clock PLL to lock, reacts
-- on two external asynchronous resets, and also allows to reset the
-- FPGA by sending a synchronous TRBnet reset pulse.
-- It is not recommended to reset the system clock PLL/DLL with
-- any of the reset signals generated here. It may deadlock.

architecture behavioral of trb_net_reset_handler is

-- normal signals
signal async_sampler        : std_logic_vector(7 downto 0); -- input shift register
signal comb_async_pulse     : std_logic;
signal async_pulse          : std_logic;
signal reset_cnt            : std_logic_vector(15 downto 0) := x"0000";
signal debug                : std_logic_vector(15 downto 0);
signal reset                : std_logic; -- DO NOT USE THIS SIGNAL!

signal reset_buffer         : std_logic; -- DO NOT USE THIS SIGNAL!
signal trb_reset_buffer     : std_logic; -- DO NOT USE THIS SIGNAL!
signal reset_pulse          : std_logic_vector(1 downto 0) := b"00";
signal trb_reset_pulse      : std_logic_vector(1 downto 0) := b"00";
signal comb_async_rst_n     : std_logic;
signal final_reset          : std_logic_vector(1 downto 0) := b"11"; -- DO NOT USE THIS SIGNAL!

attribute syn_preserve : boolean;
attribute syn_preserve of async_sampler : signal  is true;
attribute syn_preserve of async_pulse : signal  is true;
attribute syn_preserve of reset : signal  is true;
attribute syn_preserve of reset_cnt : signal  is true;
attribute syn_preserve of comb_async_rst_n : signal  is true;

begin

----------------------------------------------------------------
-- Combine all async reset sources: CLR, /CLR, PLL_LOCK
----------------------------------------------------------------
comb_async_rst_n <= not clear_in and clear_n_in and pll_locked_in;

----------------------------------------------------------------
-- sample the async reset line and react only on a long pulse
----------------------------------------------------------------
THE_ASYNC_SAMPLER_PROC: process( clk_in )
begin
	if( rising_edge(clk_in) ) then
		async_sampler(7 downto 0) <= async_sampler(6 downto 0) & comb_async_rst_n;
		async_pulse               <= comb_async_pulse;
	end if;
end process THE_ASYNC_SAMPLER_PROC;

-- first two registers are clock domain transfer registers!
comb_async_pulse <= '1' when ( async_sampler(7 downto 2) = b"0000_00" ) else '0';

----------------------------------------------------------------
-- Sync the signals from SYSCLK to raw clock domain and back
----------------------------------------------------------------
THE_SYNC_PROC: process( sysclk_in )
begin
	if( rising_edge(sysclk_in) ) then
		reset_buffer     <= reset_in;      -- not really needed, but relaxes timing
		trb_reset_buffer <= trb_reset_in;  -- not really needed, but relaxes timing
		final_reset      <= final_reset(0) & reset;
	end if;
end process THE_SYNC_PROC;

THE_CROSSING_PROC: process( clk_in )
begin
	if( rising_edge(clk_in) ) then
		reset_pulse      <= reset_pulse(0)     & reset_buffer;
		trb_reset_pulse  <= trb_reset_pulse(0) & trb_reset_buffer;
	end if;
end process THE_CROSSING_PROC;

----------------------------------------------------------------
-- one global reset counter
----------------------------------------------------------------
THE_GLOBAL_RESET_PROC: process( clk_in )
begin
	if( rising_edge(clk_in) ) then
		if( (async_pulse = '1') or (reset_pulse(1) = '1') or (trb_reset_pulse(1) = '1') ) then
			reset_cnt <= (others => '0');
			reset     <= '1';
		else
			reset_cnt <= reset_cnt + 1;
			reset     <= '1';
			if( reset_cnt = RESET_DELAY ) then
				reset     <= '0';
				reset_cnt <= RESET_DELAY;
			end if;
		end if;
	end if;
end process THE_GLOBAL_RESET_PROC;


----------------------------------------------------------------
-- Debug signals
----------------------------------------------------------------
debug(15)           <= reset;
debug(14)           <= '0';
debug(13 downto 12) <= final_reset;
debug(11 downto 0)  <= reset_cnt(11 downto 0);
--debug(15)           <= comb_async_pulse;
--debug(14 downto 8)  <= (others => '0');
--debug(7 downto 0)   <= async_sampler;

----------------------------------------------------------------
-- Output signals
----------------------------------------------------------------
debug_out <= debug;
clear_out <= not comb_async_rst_n;
reset_out <= final_reset(1);

end behavioral;
