library ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
library work;
use work.trb_net_std.all;

package trb_net16_hub_func is

--type for hub arrays
  type hub_iobuf_config_t is array(0 to 67) of integer; --2**(c_MUX_WIDTH-1)*c_MAX_MII_PER_HUB-1
  type hub_api_config_t is array(0 to 7) of integer;
  type hub_api_broadcast_t is array(0 to 7) of std_logic_vector(7 downto 0);
  type hub_channel_config_t is array(0 to 2**(3-1)-1) of integer;
  type hub_mii_config_t is array(0 to 16) of integer;

  --hub constraints (only needed for generic configuration)
  constant c_MAX_MII_PER_HUB    : integer := 17;
  constant c_MAX_API_PER_HUB    : integer := 8;
  constant c_MAX_TRG_PER_HUB    : integer := 8;
  constant c_MAX_POINTS_PER_HUB : integer := 18;

  constant std_HUB_IBUF_DEPTH : hub_iobuf_config_t :=( 6,6,6,6,    --MII 0
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6,
                                                       6,6,6,6);   --MII 15

  constant std_IBUF_DEPTH : hub_channel_config_t := (6,6,6,6);

  constant std_hub_mii_all_yes : hub_mii_config_t := (c_YES,c_YES,c_YES,c_YES,c_YES,c_YES,c_YES,c_YES,
                                                      c_YES,c_YES,c_YES,c_YES,c_YES,c_YES,c_YES,c_YES,c_YES);

  function calc_point_number (MII_NUMBER   : integer;
                              CHANNEL      : integer;
                              HUB_CTRL_CHANNEL : integer;
                              INT_NUMBER   : integer;
                              INT_CHANNELS : hub_api_config_t)
    return integer;

  function calc_depth(POINT        : integer;
                      MII_DEPTH    : hub_iobuf_config_t;
                      INT_DEPTH    : hub_api_config_t;
                      MII_NUMBER   : integer;
                      INT_NUMBER   : integer;
                      MUX_WIDTH    : integer;
                      HUB_CTRL_DEPTH : integer)
    return integer;

  function calc_first_point_number (MII_NUMBER   : integer;
                                    CHANNEL      : integer;
                                    HUB_CTRL_CHANNEL : integer;
                                    INT_NUMBER   : integer;
                                    INT_CHANNELS : hub_api_config_t
                                    )
    return integer;

  function calc_special_number(CHANNEL  : integer;
                               NUMBER   : integer;
                               CHANNELS : hub_api_config_t)
    return integer;


  function calc_is_ctrl_channel(CHANNEL : integer; HUB_CTRL_CHANNEL : integer)
    return integer;

  function reportint(i : integer)
    return integer;

  function VAL(i : integer)
    return integer;


  component trb_net16_hub_base is
  generic (
  --hub control
    HUB_CTRL_CHANNELNUM     : integer range 0 to 3 := c_SLOW_CTRL_CHANNEL;
    HUB_CTRL_DEPTH          : integer range 0 to 6 := c_FIFO_BRAM;
    HUB_CTRL_BROADCAST_BITMASK  : std_logic_vector(7 downto 0)  := x"FE";
    HUB_USED_CHANNELS       : hub_channel_config_t := (c_YES,c_YES,c_NO,c_YES);
    USE_CHECKSUM            : hub_channel_config_t := (c_NO,c_YES,c_YES,c_YES);
    USE_VENDOR_CORES        : integer range 0 to 1 := c_YES;
    IBUF_SECURE_MODE        : integer range 0 to 1 := c_NO;
    INIT_ADDRESS            : std_logic_vector(15 downto 0) := x"F004";
    INIT_UNIQUE_ID          : std_logic_vector(63 downto 0) := (others => '0');
    INIT_CTRL_REGS          : std_logic_vector(2**(4)*32-1 downto 0) :=
                                         x"00000000_00000000_00000000_00000000" &
                                         x"00000000_00000000_00000000_00000000" &
                                         x"00000000_00000000_000050FF_00000000" &
                                         x"FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF";
    COMPILE_TIME            : std_logic_vector(31 downto 0) := x"00000000";
    COMPILE_VERSION         : std_logic_vector(15 downto 0) := x"0001";
    INIT_ENDPOINT_ID        : std_logic_vector(15 downto 0)  := x"0001";
    USE_VAR_ENDPOINT_ID     : integer range c_NO to c_YES := c_NO;
    HARDWARE_VERSION        : std_logic_vector(31 downto 0) := x"12345678";
    CLOCK_FREQUENCY         : integer range 1 to 200 := 100;
    USE_ONEWIRE             : integer range 0 to 2 := c_YES;
    BROADCAST_SPECIAL_ADDR  : std_logic_vector(7 downto 0) := x"FF";
  --media interfaces
    MII_NUMBER              : integer range 1 to c_MAX_MII_PER_HUB := 12;
    MII_IBUF_DEPTH          : hub_iobuf_config_t := std_HUB_IBUF_DEPTH;
    MII_IS_UPLINK           : hub_mii_config_t := (others => c_YES);
    MII_IS_DOWNLINK         : hub_mii_config_t := (others => c_YES);
    MII_IS_UPLINK_ONLY      : hub_mii_config_t := (others => c_NO);
  -- settings for external api connections
    INT_NUMBER              : integer range 0 to c_MAX_API_PER_HUB := 0;
    INT_CHANNELS            : hub_api_config_t := (3,3,3,3,3,3,3,3);
    INT_IBUF_DEPTH          : hub_api_config_t := (6,6,6,6,6,6,6,6)
    );
  port (
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

    --Media interfacces
    MED_DATAREADY_OUT : out std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATA_OUT      : out std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT: out std_logic_vector (MII_NUMBER*c_NUM_WIDTH-1 downto 0);
    MED_READ_IN       : in  std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATAREADY_IN  : in  std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATA_IN       : in  std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN : in  std_logic_vector (MII_NUMBER*c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT      : out std_logic_vector (MII_NUMBER-1 downto 0);
    MED_STAT_OP       : in  std_logic_vector (MII_NUMBER*16-1 downto 0);
    MED_CTRL_OP       : out std_logic_vector (MII_NUMBER*16-1 downto 0);
    --INT: interfaces to connect APIs
    INT_INIT_DATAREADY_OUT    : out std_logic_vector (INT_NUMBER downto 0);
    INT_INIT_DATA_OUT         : out std_logic_vector (INT_NUMBER*c_DATA_WIDTH downto 0);
    INT_INIT_PACKET_NUM_OUT   : out std_logic_vector (INT_NUMBER*c_NUM_WIDTH  downto 0);
    INT_INIT_READ_IN          : in  std_logic_vector (INT_NUMBER downto 0) := (others => '0');
    INT_INIT_DATAREADY_IN     : in  std_logic_vector (INT_NUMBER downto 0) := (others => '0');
    INT_INIT_DATA_IN          : in  std_logic_vector (INT_NUMBER*c_DATA_WIDTH downto 0) := (others => '0');
    INT_INIT_PACKET_NUM_IN    : in  std_logic_vector (INT_NUMBER*c_NUM_WIDTH  downto 0) := (others => '0');
    INT_INIT_READ_OUT         : out std_logic_vector (INT_NUMBER downto 0);
    INT_REPLY_DATAREADY_OUT   : out std_logic_vector (INT_NUMBER downto 0);
    INT_REPLY_DATA_OUT        : out std_logic_vector (INT_NUMBER*c_DATA_WIDTH downto 0);
    INT_REPLY_PACKET_NUM_OUT  : out std_logic_vector (INT_NUMBER*c_NUM_WIDTH  downto 0);
    INT_REPLY_READ_IN         : in  std_logic_vector (INT_NUMBER downto 0) := (others => '0');
    INT_REPLY_DATAREADY_IN    : in  std_logic_vector (INT_NUMBER downto 0) := (others => '0');
    INT_REPLY_DATA_IN         : in  std_logic_vector (INT_NUMBER*c_DATA_WIDTH downto 0) := (others => '0');
    INT_REPLY_PACKET_NUM_IN   : in  std_logic_vector (INT_NUMBER*c_NUM_WIDTH downto 0) := (others => '0');
    INT_REPLY_READ_OUT        : out std_logic_vector (INT_NUMBER downto 0);
    --REGIO INTERFACE
    REGIO_ADDR_OUT            : out std_logic_vector(16-1 downto 0);
    REGIO_READ_ENABLE_OUT     : out std_logic;
    REGIO_WRITE_ENABLE_OUT    : out std_logic;
    REGIO_DATA_OUT            : out std_logic_vector(32-1 downto 0);
    REGIO_DATA_IN             : in  std_logic_vector(32-1 downto 0) := (others => '0');
    REGIO_DATAREADY_IN        : in  std_logic := '0';
    REGIO_NO_MORE_DATA_IN     : in  std_logic := '0';
    REGIO_WRITE_ACK_IN        : in  std_logic := '0';
    REGIO_UNKNOWN_ADDR_IN     : in  std_logic := '0';
    REGIO_TIMEOUT_OUT         : out std_logic;
    REGIO_VAR_ENDPOINT_ID        : in  std_logic_vector(15 downto 0) := (others => '0');
    TIMER_TICKS_OUT           : out std_logic_vector(1 downto 0);
    ONEWIRE               : inout std_logic;
    ONEWIRE_MONITOR_IN    : in  std_logic;
    ONEWIRE_MONITOR_OUT   : out std_logic;
    COMMON_STAT_REGS : in  std_logic_vector (std_COMSTATREG*32-1 downto 0) := (others => '0');  --Status of common STAT regs
    COMMON_CTRL_REGS : out std_logic_vector (std_COMCTRLREG*32-1 downto 0);  --Status of common STAT regs
    MY_ADDRESS_OUT   : out std_logic_vector (15 downto 0);
    HUB_LED_OUT      : out std_logic_vector (MII_NUMBER-1 downto 0);
    UNIQUE_ID_OUT                : out std_logic_vector (63 downto 0);
    --Fixed status and control ports
    HUB_STAT_CHANNEL      : out std_logic_vector (2**(c_MUX_WIDTH-1)*16-1 downto 0);
    HUB_STAT_GEN          : out std_logic_vector (31 downto 0);
    MPLEX_CTRL            : in  std_logic_vector (MII_NUMBER*32-1 downto 0);
    MPLEX_STAT            : out std_logic_vector (MII_NUMBER*32-1 downto 0);
    STAT_REGS             : out std_logic_vector (16*32-1 downto 0);  --Status of custom STAT regs
    STAT_CTRL_REGS        : out std_logic_vector (8*32-1 downto 0);  --Status of custom CTRL regs
    IOBUF_STAT_INIT_OBUF_DEBUG   : out std_logic_vector (MII_NUMBER*32*2**(c_MUX_WIDTH-1)-1 downto 0);
    IOBUF_STAT_REPLY_OBUF_DEBUG  : out std_logic_vector (MII_NUMBER*32*2**(c_MUX_WIDTH-1)-1 downto 0);

    --Debugging registers
    STAT_DEBUG            : out std_logic_vector (31 downto 0);      --free status regs for debugging
    CTRL_DEBUG            : in  std_logic_vector (31 downto 0)      --free control regs for debugging
    );
  end component;



component trb_net16_hub_streaming_port is
  generic(
  --hub control
    HUB_CTRL_CHANNELNUM     : integer range 0 to 3 := c_SLOW_CTRL_CHANNEL;
    HUB_CTRL_DEPTH          : integer range 0 to 6 := c_FIFO_BRAM;
    HUB_USED_CHANNELS       : hub_channel_config_t := (c_YES,c_YES,c_NO,c_YES);
    USE_CHECKSUM            : hub_channel_config_t := (c_NO,c_YES,c_YES,c_YES);
    USE_VENDOR_CORES        : integer range 0 to 1 := c_YES;
    IBUF_SECURE_MODE        : integer range 0 to 1 := c_NO;
    INIT_ADDRESS            : std_logic_vector(15 downto 0) := x"F004";
    INIT_UNIQUE_ID          : std_logic_vector(63 downto 0) := (others => '0');
    COMPILE_TIME            : std_logic_vector(31 downto 0) := x"00000000";
    COMPILE_VERSION         : std_logic_vector(15 downto 0) := x"0001";
    HARDWARE_VERSION        : std_logic_vector(31 downto 0) := x"12345678";
    INIT_ENDPOINT_ID        : std_logic_vector(15 downto 0) := x"0001";
    BROADCAST_BITMASK       : std_logic_vector(7 downto 0)  := x"7E";
    CLOCK_FREQUENCY         : integer range 1 to 200 := 100;
    USE_ONEWIRE             : integer range 0 to 2 := c_YES;
    BROADCAST_SPECIAL_ADDR  : std_logic_vector(7 downto 0) := x"FF";
  --media interfaces
    MII_NUMBER              : integer range 2 to c_MAX_MII_PER_HUB := 12;
    MII_IBUF_DEPTH          : hub_iobuf_config_t := std_HUB_IBUF_DEPTH;
    MII_IS_UPLINK           : hub_mii_config_t := (others => c_YES);
    MII_IS_DOWNLINK         : hub_mii_config_t := (others => c_YES);
    MII_IS_UPLINK_ONLY      : hub_mii_config_t := (others => c_NO)
    );

  port(
    CLK    : in std_logic;
    RESET  : in std_logic;
    CLK_EN : in std_logic;

  --Media Interface
    MED_DATAREADY_OUT : out std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATA_OUT      : out std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT: out std_logic_vector (MII_NUMBER*c_NUM_WIDTH-1 downto 0);
    MED_READ_IN       : in  std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATAREADY_IN  : in  std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATA_IN       : in  std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN : in  std_logic_vector (MII_NUMBER*c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT      : out std_logic_vector (MII_NUMBER-1 downto 0);
    MED_STAT_OP       : in  std_logic_vector (MII_NUMBER*16-1 downto 0);
    MED_CTRL_OP       : out std_logic_vector (MII_NUMBER*16-1 downto 0);

    --Event information coming from CTS
    CTS_NUMBER_OUT            : out std_logic_vector (15 downto 0);
    CTS_CODE_OUT              : out std_logic_vector (7  downto 0);
    CTS_INFORMATION_OUT       : out std_logic_vector (7  downto 0);
    CTS_READOUT_TYPE_OUT      : out std_logic_vector (3  downto 0);
    CTS_START_READOUT_OUT     : out std_logic;

    --Information sent to CTS
    --status data, equipped with DHDR
    CTS_DATA_IN             : in  std_logic_vector (31 downto 0);
    CTS_DATAREADY_IN        : in  std_logic;
    CTS_READOUT_FINISHED_IN : in  std_logic;      --no more data, end transfer, send TRM
    CTS_READ_OUT            : out std_logic;
    CTS_LENGTH_IN           : in  std_logic_vector (15 downto 0);
    CTS_STATUS_BITS_IN      : in  std_logic_vector (31 downto 0);

    -- Data from Frontends
    FEE_DATA_OUT           : out std_logic_vector (15 downto 0);
    FEE_DATAREADY_OUT      : out std_logic;
    FEE_READ_IN            : in  std_logic;  --must be high when idle, otherwise you will never get a dataready
    FEE_STATUS_BITS_OUT    : out std_logic_vector (31 downto 0);
    FEE_BUSY_OUT           : out std_logic;

    MY_ADDRESS_IN         : in  std_logic_vector (15 downto 0);

    COMMON_STAT_REGS      : out std_logic_vector (std_COMSTATREG*32-1 downto 0);  --Status of common STAT regs
    COMMON_CTRL_REGS      : out std_logic_vector (std_COMCTRLREG*32-1 downto 0);  --Status of common STAT regs
    ONEWIRE               : inout std_logic;
    ONEWIRE_MONITOR_IN    : in  std_logic;
    ONEWIRE_MONITOR_OUT   : out std_logic;

    MY_ADDRESS_OUT        : out std_logic_vector(15 downto 0);
    --REGIO INTERFACE
    REGIO_ADDR_OUT            : out std_logic_vector(16-1 downto 0);
    REGIO_READ_ENABLE_OUT     : out std_logic;
    REGIO_WRITE_ENABLE_OUT    : out std_logic;
    REGIO_DATA_OUT            : out std_logic_vector(32-1 downto 0);
    REGIO_DATA_IN             : in  std_logic_vector(32-1 downto 0) := (others => '0');
    REGIO_DATAREADY_IN        : in  std_logic := '0';
    REGIO_NO_MORE_DATA_IN     : in  std_logic := '0';
    REGIO_WRITE_ACK_IN        : in  std_logic := '0';
    REGIO_UNKNOWN_ADDR_IN     : in  std_logic := '0';
    REGIO_TIMEOUT_OUT         : out std_logic;

  --status and control ports
    HUB_STAT_CHANNEL      : out std_logic_vector (2**(c_MUX_WIDTH-1)*16-1 downto 0);
    HUB_STAT_GEN          : out std_logic_vector (31 downto 0);
    MPLEX_CTRL            : in  std_logic_vector (MII_NUMBER*32-1 downto 0);
    MPLEX_STAT            : out std_logic_vector (MII_NUMBER*32-1 downto 0);
    STAT_REGS             : out std_logic_vector (8*32-1 downto 0);  --Status of custom STAT regs
    STAT_CTRL_REGS        : out std_logic_vector (8*32-1 downto 0);  --Status of custom CTRL regs
    --Debugging registers
    STAT_DEBUG            : out std_logic_vector (31 downto 0);      --free status regs for debugging
    CTRL_DEBUG            : in  std_logic_vector (31 downto 0)      --free control regs for debugging
    );
  end component;


  component trb_net16_hub_ipu_logic is
    generic (
      POINT_NUMBER        : integer range 2 to 32 := 3
      );
    port (
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      --Internal interfaces to IOBufs
      INIT_DATAREADY_IN     : in  std_logic_vector (POINT_NUMBER-1 downto 0);
      INIT_DATA_IN          : in  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
      INIT_PACKET_NUM_IN    : in  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
      INIT_READ_OUT         : out std_logic_vector (POINT_NUMBER-1 downto 0);
      INIT_DATAREADY_OUT    : out std_logic_vector (POINT_NUMBER-1 downto 0);
      INIT_DATA_OUT         : out std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
      INIT_PACKET_NUM_OUT   : out std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
      INIT_READ_IN          : in  std_logic_vector (POINT_NUMBER-1 downto 0);
      REPLY_DATAREADY_IN    : in  std_logic_vector (POINT_NUMBER-1 downto 0);
      REPLY_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
      REPLY_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
      REPLY_READ_OUT        : out std_logic_vector (POINT_NUMBER-1 downto 0);
      REPLY_DATAREADY_OUT   : out std_logic_vector (POINT_NUMBER-1 downto 0);
      REPLY_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
      REPLY_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
      REPLY_READ_IN         : in  std_logic_vector (POINT_NUMBER-1 downto 0);
      MY_ADDRESS_IN         : in  std_logic_vector (15 downto 0);
      --Status ports
      STAT_DEBUG         : out std_logic_vector (31 downto 0);
      STAT_locked        : out std_logic;
      STAT_POINTS_locked : out std_logic_vector (31 downto 0);
      STAT_TIMEOUT       : out std_logic_vector (31 downto 0);
      STAT_ERRORBITS     : out std_logic_vector (31 downto 0);
      STAT_ALL_ERRORBITS : out std_logic_vector (16*32-1 downto 0);
      STAT_FSM           : out std_logic_vector (31 downto 0);
      STAT_MISMATCH      : out std_logic_vector (31 downto 0);
      CTRL_TIMEOUT_TIME  : in  std_logic_vector (15 downto 0);
      CTRL_activepoints  : in  std_logic_vector (31 downto 0) := (others => '1');
      CTRL_TIMER_TICK    : in  std_logic_vector (1 downto 0)
      );
  end component;



  component trb_net16_hub_logic is
    generic (
    --media interfaces
      POINT_NUMBER        : integer range 2 to 32 := 2;
      MII_IS_UPLINK_ONLY      : hub_mii_config_t := (others => c_NO)
      );
    port (
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;
      INIT_DATAREADY_IN     : in  std_logic_vector (POINT_NUMBER-1 downto 0);
      INIT_DATA_IN          : in  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
      INIT_PACKET_NUM_IN    : in  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
      INIT_READ_OUT         : out std_logic_vector (POINT_NUMBER-1 downto 0);
      INIT_DATAREADY_OUT    : out std_logic_vector (POINT_NUMBER-1 downto 0);
      INIT_DATA_OUT         : out std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
      INIT_PACKET_NUM_OUT   : out std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
      INIT_READ_IN          : in  std_logic_vector (POINT_NUMBER-1 downto 0);
      REPLY_DATAREADY_IN    : in  std_logic_vector (POINT_NUMBER-1 downto 0);
      REPLY_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
      REPLY_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
      REPLY_READ_OUT        : out std_logic_vector (POINT_NUMBER-1 downto 0);
      REPLY_DATAREADY_OUT   : out std_logic_vector (POINT_NUMBER-1 downto 0);
      REPLY_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH*POINT_NUMBER-1 downto 0);
      REPLY_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH*POINT_NUMBER-1 downto 0);
      REPLY_READ_IN         : in  std_logic_vector (POINT_NUMBER-1 downto 0);
      STAT                  : out std_logic_vector (15 downto 0);
      STAT_locked           : out std_logic;
      STAT_POINTS_locked    : out std_logic_vector (31 downto 0);
      STAT_TIMEOUT          : out std_logic_vector (31 downto 0);
      STAT_ERRORBITS        : out std_logic_vector (31 downto 0);
      STAT_ALL_ERRORBITS    : out std_logic_vector (16*32-1 downto 0);
      CTRL_TIMEOUT_TIME     : in  std_logic_vector (15 downto 0);
      CTRL_activepoints     : in  std_logic_vector (31 downto 0);
      CTRL_TIMER_TICK       : in  std_logic_vector (1 downto 0)
      );
  end component;



component trb_net16_hub_streaming_port_sctrl is
  generic(
  --hub control
    INIT_ADDRESS            : std_logic_vector(15 downto 0) := x"F004";
    INIT_UNIQUE_ID          : std_logic_vector(63 downto 0) := (others => '0');
    COMPILE_TIME            : std_logic_vector(31 downto 0) := x"00000000";
    COMPILE_VERSION         : std_logic_vector(15 downto 0) := x"0001";
    HARDWARE_VERSION        : std_logic_vector(31 downto 0) := x"12345678";
    INIT_ENDPOINT_ID        : std_logic_vector(15 downto 0) := x"0001";
    BROADCAST_BITMASK       : std_logic_vector(7 downto 0)  := x"7E";
    CLOCK_FREQUENCY         : integer range 1 to 200 := 100;
    USE_ONEWIRE             : integer range 0 to 2 := c_YES;
    BROADCAST_SPECIAL_ADDR  : std_logic_vector(7 downto 0) := x"FF";
  --media interfaces
    MII_NUMBER              : integer range 2 to c_MAX_MII_PER_HUB := 12;
    MII_IS_UPLINK           : hub_mii_config_t := (others => c_YES);
    MII_IS_DOWNLINK         : hub_mii_config_t := (others => c_YES);
    MII_IS_UPLINK_ONLY      : hub_mii_config_t := (others => c_NO)
    );

  port(
    CLK                          : in std_logic;
    RESET                        : in std_logic;
    CLK_EN                       : in std_logic;

  --Media Interface
    MED_DATAREADY_OUT            : out std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATA_OUT                 : out std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_OUT           : out std_logic_vector (MII_NUMBER*c_NUM_WIDTH-1 downto 0);
    MED_READ_IN                  : in  std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATAREADY_IN             : in  std_logic_vector (MII_NUMBER-1 downto 0);
    MED_DATA_IN                  : in  std_logic_vector (MII_NUMBER*c_DATA_WIDTH-1 downto 0);
    MED_PACKET_NUM_IN            : in  std_logic_vector (MII_NUMBER*c_NUM_WIDTH-1 downto 0);
    MED_READ_OUT                 : out std_logic_vector (MII_NUMBER-1 downto 0);
    MED_STAT_OP                  : in  std_logic_vector (MII_NUMBER*16-1 downto 0);
    MED_CTRL_OP                  : out std_logic_vector (MII_NUMBER*16-1 downto 0);

    --Event information coming from CTS
    CTS_NUMBER_OUT               : out std_logic_vector (15 downto 0);
    CTS_CODE_OUT                 : out std_logic_vector (7  downto 0);
    CTS_INFORMATION_OUT          : out std_logic_vector (7  downto 0);
    CTS_READOUT_TYPE_OUT         : out std_logic_vector (3  downto 0);
    CTS_START_READOUT_OUT        : out std_logic;

    --Information sent to CTS
    --status data, equipped with DHDR
    CTS_DATA_IN                  : in  std_logic_vector (31 downto 0);
    CTS_DATAREADY_IN             : in  std_logic;
    CTS_READOUT_FINISHED_IN      : in  std_logic;      --no more data, end transfer, send TRM
    CTS_READ_OUT                 : out std_logic;
    CTS_LENGTH_IN                : in  std_logic_vector (15 downto 0);
    CTS_STATUS_BITS_IN           : in  std_logic_vector (31 downto 0);

    -- Data from Frontends
    FEE_DATA_OUT                 : out std_logic_vector (15 downto 0);
    FEE_DATAREADY_OUT            : out std_logic;
    FEE_READ_IN                  : in  std_logic;  --must be high when idle, otherwise you will never get a dataready
    FEE_STATUS_BITS_OUT          : out std_logic_vector (31 downto 0);
    FEE_BUSY_OUT                 : out std_logic;

    MY_ADDRESS_IN                : in  std_logic_vector (15 downto 0);

    COMMON_STAT_REGS             : out std_logic_vector (std_COMSTATREG*32-1 downto 0);  --Status of common STAT regs
    COMMON_CTRL_REGS             : out std_logic_vector (std_COMCTRLREG*32-1 downto 0);  --Status of common STAT regs
    ONEWIRE                      : inout std_logic;
    ONEWIRE_MONITOR_IN           : in  std_logic;
    ONEWIRE_MONITOR_OUT          : out std_logic;
    MY_ADDRESS_OUT               : out std_logic_vector(15 downto 0);
    UNIQUE_ID_OUT                : out std_logic_vector (63 downto 0);

    --REGIO INTERFACE
    REGIO_ADDR_OUT               : out std_logic_vector(16-1 downto 0);
    REGIO_READ_ENABLE_OUT        : out std_logic;
    REGIO_WRITE_ENABLE_OUT       : out std_logic;
    REGIO_DATA_OUT               : out std_logic_vector(32-1 downto 0);
    REGIO_DATA_IN                : in  std_logic_vector(32-1 downto 0) := (others => '0');
    REGIO_DATAREADY_IN           : in  std_logic := '0';
    REGIO_NO_MORE_DATA_IN        : in  std_logic := '0';
    REGIO_WRITE_ACK_IN           : in  std_logic := '0';
    REGIO_UNKNOWN_ADDR_IN        : in  std_logic := '0';
    REGIO_TIMEOUT_OUT            : out std_logic;


    --Gbe Sctrl Input
    GSC_INIT_DATAREADY_IN        : in  std_logic;
    GSC_INIT_DATA_IN             : in  std_logic_vector(15 downto 0);
    GSC_INIT_PACKET_NUM_IN       : in  std_logic_vector(2 downto 0);
    GSC_INIT_READ_OUT            : out std_logic;
    GSC_REPLY_DATAREADY_OUT      : out std_logic;
    GSC_REPLY_DATA_OUT           : out std_logic_vector(15 downto 0);
    GSC_REPLY_PACKET_NUM_OUT     : out std_logic_vector(2 downto 0);
    GSC_REPLY_READ_IN            : in  std_logic;
    GSC_BUSY_OUT                 : out std_logic;
    
  --status and control ports
    HUB_STAT_CHANNEL             : out std_logic_vector (2**(c_MUX_WIDTH-1)*16-1 downto 0);
    HUB_STAT_GEN                 : out std_logic_vector (31 downto 0);
    MPLEX_CTRL                   : in  std_logic_vector (MII_NUMBER*32-1 downto 0);
    MPLEX_STAT                   : out std_logic_vector (MII_NUMBER*32-1 downto 0);
    STAT_REGS                    : out std_logic_vector (8*32-1 downto 0);  --Status of custom STAT regs
    STAT_CTRL_REGS               : out std_logic_vector (8*32-1 downto 0);  --Status of custom CTRL regs
    --Debugging registers
    STAT_DEBUG                   : out std_logic_vector (31 downto 0);      --free status regs for debugging
    CTRL_DEBUG                   : in  std_logic_vector (31 downto 0)      --free control regs for debugging
    );
end component;




end package trb_net16_hub_func;

package body trb_net16_hub_func is

  function VAL(i : integer)
    return integer is
    begin
      if i > 0 then
        return i-1;
      else
        return 0;
      end if;
    end function;

  function calc_is_ctrl_channel(CHANNEL : integer; HUB_CTRL_CHANNEL : integer)
    return integer is
    begin
      if CHANNEL = HUB_CTRL_CHANNEL then
        return 1;
      else
        return 0;
      end if;
    end function;

  function reportint(i : integer)
    return integer is
    begin
      report integer'image(i);
      return i;
    end function;

  function calc_point_number (MII_NUMBER   : integer;
                              CHANNEL      : integer;
                              HUB_CTRL_CHANNEL : integer;
                              INT_NUMBER   : integer;
                              INT_CHANNELS : hub_api_config_t)
    return integer is
    variable tmp : integer := 0;
    begin
      tmp := MII_NUMBER;
      if HUB_CTRL_CHANNEL = CHANNEL then
        tmp := tmp + 1;
      end if;
      if INT_NUMBER /= 0 then
        for i in 0 to INT_NUMBER-1 loop
          if(INT_CHANNELS(i) = CHANNEL) then
            tmp := tmp + 1;
          end if;
        end loop;
      end if;
      return tmp;
    end function;

  function calc_special_number(CHANNEL  : integer;
                               NUMBER   : integer;
                               CHANNELS : hub_api_config_t)
    return integer is
    variable tmp : integer := 0;
    begin
      tmp := 0;
      if NUMBER /= 0 then
        for i in 0 to NUMBER-1 loop
          if(CHANNELS(i) = CHANNEL) then
            tmp := tmp + 1;
          end if;
        end loop;
      end if;
      return tmp;
    end function;


  function calc_depth(POINT        : integer;
                      MII_DEPTH    : hub_iobuf_config_t;
                      INT_DEPTH    : hub_api_config_t;
                      MII_NUMBER   : integer;
                      INT_NUMBER   : integer;
                      MUX_WIDTH    : integer;
                      HUB_CTRL_DEPTH : integer)
    return integer is
    begin
      if(POINT < MII_NUMBER*2**(MUX_WIDTH-1)) then
        --report integer'image(MII_DEPTH((POINT / 2**(MUX_WIDTH-1))*4 + (POINT mod 2**(MUX_WIDTH-1))));
        return MII_DEPTH((POINT / 2**(MUX_WIDTH-1))*4 + (POINT mod 2**(MUX_WIDTH-1)));
      elsif(POINT = MII_NUMBER*2**(MUX_WIDTH-1)) then
        return HUB_CTRL_DEPTH;
      elsif POINT < MII_NUMBER*2**(MUX_WIDTH-1) + INT_NUMBER then
        return INT_DEPTH(POINT-(MII_NUMBER*2**(MUX_WIDTH-1)));
      else
        return -1;
      end if;
    end function;


  function calc_first_point_number (MII_NUMBER   : integer;
                                    CHANNEL      : integer;
                                    HUB_CTRL_CHANNEL : integer;
                                    INT_NUMBER   : integer;
                                    INT_CHANNELS : hub_api_config_t
                                    )
    return integer is
    variable tmp : integer := 0;
    begin
      if CHANNEL = 0 then
        return 0;
      end if;
      tmp := 0;
      for i in 0 to CHANNEL-1 loop
        tmp := tmp + calc_point_number(MII_NUMBER,i,HUB_CTRL_CHANNEL,INT_NUMBER,INT_CHANNELS);
      end loop;
      return tmp;
    end function;



end package body;
