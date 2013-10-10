-- std package
library ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

package trb_net_std is

  type channel_config_t is array(0 to 3) of integer;
  type array_32_t is array(integer range <>) of std_logic_vector(31 downto 0);
  type multiplexer_config_t is array(0 to 2**3-1) of integer;

--Trigger types
  constant TRIG_PHYS         : std_logic_vector(3 downto 0) := x"1";
  constant TRIG_MDC_CAL      : std_logic_vector(3 downto 0) := x"9";
  constant TRIG_SHW_CAL      : std_logic_vector(3 downto 0) := x"A";
  constant TRIG_SHW_PED      : std_logic_vector(3 downto 0) := x"B";
--Trigger Info
  constant TRIG_SUPPRESS_BIT : integer range 0 to 15 := 0;



-- some basic definitions for the whole network
-----------------------------------------------

  constant c_DATA_WIDTH        : integer   := 16;
  constant c_NUM_WIDTH         : integer   := 3;
  constant c_MUX_WIDTH         : integer   := 3; --!!!


--assigning channel names
  constant c_TRG_LVL1_CHANNEL  : integer := 0;
  constant c_DATA_CHANNEL      : integer := 1;
  constant c_IPU_CHANNEL       : integer := 1;
  constant c_UNUSED_CHANNEL    : integer := 2;
  constant c_SLOW_CTRL_CHANNEL : integer := 3;

--api_type generic
  constant c_API_ACTIVE   : integer := 1;
  constant c_API_PASSIVE  : integer := 0;

--sbuf_version generic
  constant c_SBUF_FULL     : integer := 0;
  constant c_SBUF_FAST     : integer := 0;
  constant c_SBUF_HALF     : integer := 1;
  constant c_SBUF_SLOW     : integer := 1;
  constant c_SECURE_MODE   : integer := 1;
  constant c_NON_SECURE_MODE : integer := 0;

--fifo_depth
  constant c_FIFO_NONE     : integer := 0;
  constant c_FIFO_2PCK     : integer := 1;
  constant c_FIFO_SMALL    : integer := 1;
  constant c_FIFO_4PCK     : integer := 2;
  constant c_FIFO_MEDIUM   : integer := 2;
  constant c_FIFO_8PCK     : integer := 3;
  constant c_FIFO_BIG      : integer := 3;
  constant c_FIFO_BRAM     : integer := 6;
  constant c_FIFO_BIGGEST  : integer := 6;
  constant c_FIFO_INFTY    : integer := 7;

--simple logic
  constant c_YES  : integer := 1;
  constant c_NO   : integer := 0;
  constant c_MONITOR : integer := 2;


--standard values
  constant std_SBUF_VERSION     : integer := c_SBUF_FULL;
  constant std_IBUF_SECURE_MODE : integer := c_SECURE_MODE;
  constant std_USE_ACKNOWLEDGE  : integer := c_YES;
  constant std_USE_REPLY_CHANNEL: integer := c_YES;
  constant std_FIFO_DEPTH       : integer := c_FIFO_BRAM;
  constant std_DATA_COUNT_WIDTH : integer := 7; --max 7
  constant std_TERM_SECURE_MODE : integer := c_YES;
  constant std_MUX_SECURE_MODE  : integer := c_NO;
  constant std_FORCE_REPLY      : integer := c_YES;
  constant cfg_USE_CHECKSUM      : channel_config_t   := (c_NO,c_YES,c_NO,c_YES);
  constant cfg_USE_ACKNOWLEDGE   : channel_config_t   := (c_YES,c_YES,c_NO,c_YES);
  constant cfg_FORCE_REPLY       : channel_config_t   := (c_YES,c_YES,c_YES,c_YES);
  constant cfg_USE_REPLY_CHANNEL : channel_config_t   := (c_YES,c_YES,c_YES,c_YES);
  constant c_MAX_IDLE_TIME_PER_PACKET : integer := 24;
  constant std_multipexer_config : multiplexer_config_t := (others => c_NO);

--packet types
  constant TYPE_DAT : std_logic_vector(2 downto 0) := "000";
  constant TYPE_HDR : std_logic_vector(2 downto 0) := "001";
  constant TYPE_EOB : std_logic_vector(2 downto 0) := "010";
  constant TYPE_TRM : std_logic_vector(2 downto 0) := "011";
  constant TYPE_ACK : std_logic_vector(2 downto 0) := "101";
  constant TYPE_ILLEGAL : std_logic_vector(2 downto 0) := "111";

--Media interface error codes
  constant ERROR_OK     : std_logic_vector(2 downto 0) := "000"; --transmission ok
  constant ERROR_ENCOD  : std_logic_vector(2 downto 0) := "001"; --transmission error by encoding
  constant ERROR_RECOV  : std_logic_vector(2 downto 0) := "010"; --transmission error, reconstructed
  constant ERROR_FATAL  : std_logic_vector(2 downto 0) := "011"; --transmission error, fatal
  constant ERROR_WAIT   : std_logic_vector(2 downto 0) := "110"; --link awaiting initial response
  constant ERROR_NC     : std_logic_vector(2 downto 0) := "111"; --media not connected


--special addresses
  constant ILLEGAL_ADDRESS   : std_logic_vector(15 downto 0) := x"0000";
  constant BROADCAST_ADDRESS : std_logic_vector(15 downto 0) := x"ffff";

--command definitions
  constant LINK_STARTUP_WORD : std_logic_vector(15 downto 0) := x"e110";
  constant SET_ADDRESS : std_logic_vector(15 downto 0) := x"5EAD";
  constant ACK_ADDRESS : std_logic_vector(15 downto 0) := x"ACAD";
  constant READ_ID     : std_logic_vector(15 downto 0) := x"5E1D";

--common registers
  --maximum: 4, because of regio implementation
  constant std_COMSTATREG  : integer := 9;
  constant std_COMCTRLREG  : integer := 3;
    --needed address width for common registers
  constant std_COMneededwidth : integer := 4;
  constant c_REGIO_ADDRESS_WIDTH : integer := 16;
  constant c_REGIO_REGISTER_WIDTH : integer := 32;
  constant c_REGIO_REG_WIDTH : integer := 32;
  constant c_regio_timeout_bit : integer := 5;

--RegIO operation dtype
  constant c_network_control_type : std_logic_vector(3 downto 0) := x"F";
  constant c_read_register_type   : std_logic_vector(3 downto 0) := x"8";
  constant c_write_register_type  : std_logic_vector(3 downto 0) := x"9";
  constant c_read_multiple_type   : std_logic_vector(3 downto 0) := x"A";
  constant c_write_multiple_type  : std_logic_vector(3 downto 0) := x"B";

  constant c_BUS_HANDLER_MAX_PORTS : integer := 64;
  type c_BUS_HANDLER_ADDR_t is array(0 to c_BUS_HANDLER_MAX_PORTS) of std_logic_vector(15 downto 0);
  type c_BUS_HANDLER_WIDTH_t is array(0 to c_BUS_HANDLER_MAX_PORTS) of integer range 0 to 16;


--Names of 16bit words
  constant c_H0 : std_logic_vector(2 downto 0) := "100";
  constant c_F0 : std_logic_vector(2 downto 0) := "000";
  constant c_F1 : std_logic_vector(2 downto 0) := "001";
  constant c_F2 : std_logic_vector(2 downto 0) := "010";
  constant c_F3 : std_logic_vector(2 downto 0) := "011";

  constant c_H0_next : std_logic_vector(2 downto 0) := "011";
  constant c_F0_next : std_logic_vector(2 downto 0) := "100";
  constant c_F1_next : std_logic_vector(2 downto 0) := "000";
  constant c_F2_next : std_logic_vector(2 downto 0) := "001";
  constant c_F3_next : std_logic_vector(2 downto 0) := "010";

  constant c_max_word_number : std_logic_vector(2 downto 0) := "100";
  --constant VERSION_NUMBER_TIME  : std_logic_vector(31 downto 0)   := conv_std_logic_vector(1234567890,32);




--function declarations
  function and_all (arg : std_logic_vector)
    return std_logic;
  function or_all  (arg : std_logic_vector)
    return std_logic;
  function all_zero (arg : std_logic_vector)
    return std_logic;
  function xor_all  (arg : std_logic_vector)
    return std_logic;

  function get_bit_position  (arg : std_logic_vector)
    return integer;

  function is_time_reached  (timer : integer; time : integer; period : integer)
    return std_logic;

  function MAX(x : integer; y : integer)
    return integer;

  function Log2( input:integer ) return integer;
  function count_ones( input:std_logic_vector ) return integer;
  function minimum (LEFT, RIGHT: INTEGER) return INTEGER;
  function maximum (LEFT, RIGHT: INTEGER) return INTEGER;


end package trb_net_std;

package body trb_net_std is

  function and_all (arg : std_logic_vector)
    return std_logic is
    variable tmp : std_logic := '1';
    begin
      tmp := '1';
      for i in arg'range loop
        tmp := tmp and arg(i);
      end loop;  -- i
      return tmp;
  end function and_all;

  function or_all (arg : std_logic_vector)
    return std_logic is
    variable tmp : std_logic := '1';
    begin
      tmp := '0';
      for i in arg'range loop
        tmp := tmp or arg(i);
      end loop;  -- i
      return tmp;
  end function or_all;

  function all_zero (arg : std_logic_vector)
    return std_logic is
	 variable tmp : std_logic := '1';
	 begin
      for i in arg'range loop
		  tmp := not arg(i);
        exit when tmp = '0';
      end loop;  -- i
      return tmp;
  end function all_zero;

  function xor_all (arg : std_logic_vector)
    return std_logic is
    variable tmp : std_logic := '0';
    begin
      tmp := '0';
      for i in arg'range loop
        tmp := tmp xor arg(i);
      end loop;  -- i
      return tmp;
  end function xor_all;

  function get_bit_position (arg : std_logic_vector)
    return integer is
    variable tmp : integer := 0;
    begin
      tmp := 0;
      for i in  arg'range loop
        if arg(i) = '1' then
          return i;
        end if;
        --exit when arg(i) = '1';
      end loop;  -- i
      return 0;
  end get_bit_position;

  function is_time_reached  (timer : integer; time : integer; period : integer)
    return std_logic is
    variable i : integer range 0 to 1 := 0;
    variable t : std_logic_vector(27 downto 0) := conv_std_logic_vector(timer,28);
    begin
      i := 0;
      if period = 10 then
        case time is
          when 1300000000 => if t(27) = '1' then i := 1; end if;
          when 640000 => if t(16) = '1' then i := 1; end if;
          when 80000  => if t(13) = '1' then i := 1; end if;
          when 10000  => if t(10) = '1' then i := 1; end if;
          when 1200   => if t(7)  = '1' then i := 1; end if;
          when others => if timer >= time/period then i := 1; end if;
        end case;
      elsif period = 40 then
        case time is
          when 1300000000 => if t(25) = '1' then i := 1; end if;
          when 640000 => if t(14) = '1' then i := 1; end if;
          when 80000  => if t(11) = '1' then i := 1; end if;
          when 10000  => if t(8) = '1' then i := 1; end if;
          when 1200   => if t(5)  = '1' then i := 1; end if;
          when others => if timer >= time/period then i := 1; end if;
        end case;
      else
        if timer = time/period then i := 1; end if;
      end if;
      if i = 1 then  return '1'; else return '0'; end if;
    end is_time_reached;

  function MAX(x : integer; y : integer)
    return integer is
    begin
      if x > y then
        return x;
      else
        return y;
      end if;
    end MAX;


  function Log2( input:integer ) return integer is
    variable temp,log:integer;
    begin
      temp:=input;
      log:=0;
      while (temp /= 0) loop
      temp:=temp/2;
      log:=log+1;
      end loop;
      return log;
      end function log2;

  function count_ones( input:std_logic_vector ) return integer is
    variable temp:std_logic_vector(input'range);
    begin
      temp := (others => '0');
      for i in input'range loop
--        if input(i) = '1' then
          temp := temp + input(i);
--        end if;
      end loop;
      return conv_integer(temp);
      end function count_ones;

      
function minimum (LEFT, RIGHT: INTEGER) return INTEGER is
  begin
    if LEFT < RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end function;        

function maximum (LEFT, RIGHT: INTEGER) return INTEGER is
  begin
    if LEFT > RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end function;       
  
end package body trb_net_std;

