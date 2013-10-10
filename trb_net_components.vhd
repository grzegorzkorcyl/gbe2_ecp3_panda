library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_UNSIGNED.all;
library work;
use work.trb_net_std.all;

package trb_net_components is



--This list of components is sorted alphabetically, ignoring the trb_net or trb_net16 prefix of some component names


  component Sfp_Interface is
    generic (
      I2C_SPEED         :       std_logic_vector(15 downto 0) := x"0200"
      );
    port(
      CLK_IN            : in    std_logic;                        -- System clock
      RST_IN            : in    std_logic;                        -- System reset
  -- host side
      START_PULSE       : in    std_logic;                        -- System start pulse
      DEVICE_ADDRESS    : in    std_logic_vector(7 downto 0);     -- Device address input: x"06" for SFP_Interface
      DATA_OUT          : out   std_logic_vector(15 downto 0);    -- Data output from optical transmitter
      READ_DONE         : out   std_logic;                        -- Reading process done
      SFP_ADDRESS       : in    std_logic_vector(7 downto 0);     -- SFP address
  -- optical transceiver side
      SCL               : out   std_logic_vector(15 downto 0);                          -- I2C Serial clock I/O
      SDA               : inout std_logic_vector(15 downto 0);                          -- I2C Serial data I/O
      DEBUG             : out   std_logic_vector(31 downto 0)
      );

  end component;

  component sfp_i2c_readout is
    generic(
      SFP_NUMBER : integer := 6
      );
    port(
      CLOCK     : in  std_logic;
      RESET     : in  std_logic;
      
      BUS_DATA_IN   : in  std_logic_vector(31 downto 0);
      BUS_DATA_OUT  : out std_logic_vector(31 downto 0);
      BUS_ADDR_IN   : in  std_logic_vector(7 downto 0);
      BUS_WRITE_IN  : in  std_logic;
      BUS_READ_IN   : in  std_logic;
      BUS_ACK_OUT   : out std_logic;
      BUS_NACK_OUT  : out std_logic;
      
      SDA           : out std_logic_vector(SFP_NUMBER-1 downto 0);
      SDA_IN        : in  std_logic_vector(SFP_NUMBER-1 downto 0);
      SCL           : out std_logic_vector(SFP_NUMBER-1 downto 0)
      );
  end component;
  
  component trb_net16_med_scm_sfp_gbe is
    generic(
      SERDES_NUM  : integer range 0 to 3 := 0;     -- DO NOT CHANGE
      EXT_CLOCK   : integer range 0 to 1 := c_NO;  -- DO NOT CHANGE
      USE_200_MHZ : integer range 0 to 1 := c_YES  -- DO NOT CHANGE
      );
    port(
      CLK                : in  std_logic;  -- SerDes clock
      SYSCLK             : in  std_logic;  -- fabric clock
      RESET              : in  std_logic;  -- synchronous reset
      CLEAR              : in  std_logic;  -- asynchronous reset
      CLK_EN             : in  std_logic;
      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic;
      MED_READ_OUT       : out std_logic;
      MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic;
      MED_READ_IN        : in  std_logic;
      REFCLK2CORE_OUT    : out std_logic;
      --SFP Connection
      SD_RXD_P_IN        : in  std_logic;
      SD_RXD_N_IN        : in  std_logic;
      SD_TXD_P_OUT       : out std_logic;
      SD_TXD_N_OUT       : out std_logic;
      SD_REFCLK_P_IN     : in  std_logic;
      SD_REFCLK_N_IN     : in  std_logic;
      SD_PRSNT_N_IN      : in  std_logic;  -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
      SD_LOS_IN          : in  std_logic;  -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
      SD_TXDIS_OUT       : out std_logic;  -- SFP disable
      -- Status and control port
      STAT_OP            : out std_logic_vector (15 downto 0);
      CTRL_OP            : in  std_logic_vector (15 downto 0);
      STAT_DEBUG         : out std_logic_vector (63 downto 0);
      CTRL_DEBUG         : in  std_logic_vector (63 downto 0)
      );
  end component trb_net16_med_scm_sfp_gbe;





  component adc_ltc2308_readout is
    generic(
      CLOCK_FREQUENCY : integer := 100  --MHz
      );
    port(
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      ADC_SCK    : out std_logic;
      ADC_SDI    : out std_logic;
      ADC_SDO    : in  std_logic;
      ADC_CONVST : out std_logic;

      DAT_ADDR_IN          : in  std_logic_vector(5 downto 0);
      DAT_READ_EN_IN       : in  std_logic;
      DAT_WRITE_EN_IN      : in  std_logic;
      DAT_DATA_OUT         : out std_logic_vector(31 downto 0);
      DAT_DATA_IN          : in  std_logic_vector(31 downto 0);
      DAT_DATAREADY_OUT    : out std_logic;
      DAT_NO_MORE_DATA_OUT : out std_logic;
      DAT_WRITE_ACK_OUT    : out std_logic;
      DAT_UNKNOWN_ADDR_OUT : out std_logic;
      DAT_TIMEOUT_IN       : in  std_logic;

      STAT_VOLTAGES_OUT : out std_logic_vector(31 downto 0)
      );
  end component;






  component trb_net16_addresses is
    generic(
      INIT_ADDRESS     : std_logic_vector(15 downto 0) := x"FFFF";
      INIT_UNIQUE_ID   : std_logic_vector(63 downto 0) := x"1000_2000_3654_4876";
      INIT_BOARD_INFO  : std_logic_vector(31 downto 0) := x"1111_2222";
      INIT_ENDPOINT_ID : std_logic_vector(15 downto 0) := x"0001"
      );
    port(
      CLK                 : in  std_logic;
      RESET               : in  std_logic;
      CLK_EN              : in  std_logic;
      API_DATA_IN         : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
      API_PACKET_NUM_IN   : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      API_DATAREADY_IN    : in  std_logic;
      API_READ_OUT        : out std_logic;
      RAM_DATA_IN         : in  std_logic_vector(15 downto 0);
      RAM_DATA_OUT        : out std_logic_vector(15 downto 0);
      RAM_ADDR_IN         : in  std_logic_vector(2 downto 0);
      RAM_WR_IN           : in  std_logic;
      API_DATA_OUT        : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
      API_PACKET_NUM_OUT  : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      API_DATAREADY_OUT   : out std_logic;
      API_READ_IN         : in  std_logic;
      ADDRESS_REJECTED    : out std_logic;
      DONT_UNDERSTAND_OUT : out std_logic;
      API_SEND_OUT        : out std_logic;
      ADDRESS_OUT         : out std_logic_vector(15 downto 0);
      STAT_DEBUG          : out std_logic_vector(15 downto 0)
      );
  end component;






  component trb_net16_api_base is
    generic (
      API_TYPE               : integer range 0 to 1          := c_API_PASSIVE;
      FIFO_TO_INT_DEPTH      : integer range 0 to 6          := 6;  --std_FIFO_DEPTH;
      FIFO_TO_APL_DEPTH      : integer range 1 to 6          := 6;  --std_FIFO_DEPTH;
      FORCE_REPLY            : integer range 0 to 1          := std_FORCE_REPLY;
      SBUF_VERSION           : integer range 0 to 1          := std_SBUF_VERSION;
      USE_VENDOR_CORES       : integer range 0 to 1          := c_YES;
      SECURE_MODE_TO_APL     : integer range 0 to 1          := c_YES;
      SECURE_MODE_TO_INT     : integer range 0 to 1          := c_YES;
      APL_WRITE_ALL_WORDS    : integer range 0 to 1          := c_NO;
      ADDRESS_MASK           : std_logic_vector(15 downto 0) := x"FFFF";
      BROADCAST_BITMASK      : std_logic_vector(7 downto 0)  := x"FF";
      BROADCAST_SPECIAL_ADDR : std_logic_vector(7 downto 0)  := x"FF"
      );

    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      -- APL Transmitter port
      APL_DATA_IN               : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      APL_PACKET_NUM_IN         : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      APL_DATAREADY_IN          : in  std_logic;
      APL_READ_OUT              : out std_logic;
      APL_SHORT_TRANSFER_IN     : in  std_logic;
      APL_DTYPE_IN              : in  std_logic_vector (3 downto 0);
      APL_ERROR_PATTERN_IN      : in  std_logic_vector (31 downto 0);
      APL_SEND_IN               : in  std_logic;
      APL_TARGET_ADDRESS_IN     : in  std_logic_vector (15 downto 0);  -- the target (only for active APIs)
      -- Receiver port
      APL_DATA_OUT              : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      APL_PACKET_NUM_OUT        : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      APL_TYP_OUT               : out std_logic_vector (2 downto 0);
      APL_DATAREADY_OUT         : out std_logic;
      APL_READ_IN               : in  std_logic;
      -- APL Control port
      APL_RUN_OUT               : out std_logic;
      APL_MY_ADDRESS_IN         : in  std_logic_vector (15 downto 0);
      APL_SEQNR_OUT             : out std_logic_vector (7 downto 0);
      APL_LENGTH_IN             : in  std_logic_vector (15 downto 0);
      APL_FIFO_COUNT_OUT        : out std_logic_vector (10 downto 0);
      -- Internal direction port
      -- the ports with master or slave in their name are to be mapped by the active api
      -- to the init respectivly the reply path and vice versa in the passive api.
      -- lets define: the "master" path is the path that I send data on.
      -- master_data_out and slave_data_in are only used in active API for termination
      INT_MASTER_DATAREADY_OUT  : out std_logic;
      INT_MASTER_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_MASTER_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_MASTER_READ_IN        : in  std_logic;
      INT_MASTER_DATAREADY_IN   : in  std_logic;
      INT_MASTER_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_MASTER_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_MASTER_READ_OUT       : out std_logic;
      INT_SLAVE_DATAREADY_OUT   : out std_logic;
      INT_SLAVE_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_SLAVE_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_SLAVE_READ_IN         : in  std_logic;
      INT_SLAVE_DATAREADY_IN    : in  std_logic;
      INT_SLAVE_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_SLAVE_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_SLAVE_READ_OUT        : out std_logic;
      -- Status and control port
      CTRL_SEQNR_RESET          : in  std_logic;
      STAT_FIFO_TO_INT          : out std_logic_vector(31 downto 0);
      STAT_FIFO_TO_APL          : out std_logic_vector(31 downto 0)
      );
  end component;




  component trb_net16_api_ipu_streaming is
    port(
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      -- Internal direction port

      FEE_INIT_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      FEE_INIT_DATAREADY_OUT  : out std_logic;
      FEE_INIT_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      FEE_INIT_READ_IN        : in  std_logic;

      FEE_REPLY_DATA_IN       : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      FEE_REPLY_DATAREADY_IN  : in  std_logic;
      FEE_REPLY_PACKET_NUM_IN : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      FEE_REPLY_READ_OUT      : out std_logic;

      CTS_INIT_DATA_IN       : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      CTS_INIT_DATAREADY_IN  : in  std_logic;
      CTS_INIT_PACKET_NUM_IN : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      CTS_INIT_READ_OUT      : out std_logic;

      CTS_REPLY_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      CTS_REPLY_DATAREADY_OUT  : out std_logic;
      CTS_REPLY_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      CTS_REPLY_READ_IN        : in  std_logic;

      --Event information coming from CTS
      CTS_NUMBER_OUT        : out std_logic_vector (15 downto 0);
      CTS_CODE_OUT          : out std_logic_vector (7 downto 0);
      CTS_INFORMATION_OUT   : out std_logic_vector (7 downto 0);
      CTS_READOUT_TYPE_OUT  : out std_logic_vector (3 downto 0);
      CTS_START_READOUT_OUT : out std_logic;

      --Information sent to CTS
      --status data, equipped with DHDR
      CTS_DATA_IN             : in  std_logic_vector (31 downto 0);
      CTS_DATAREADY_IN        : in  std_logic;
      CTS_READOUT_FINISHED_IN : in  std_logic;  --no more data, end transfer, send TRM
      CTS_READ_OUT            : out std_logic;
      CTS_LENGTH_IN           : in  std_logic_vector (15 downto 0);
      CTS_STATUS_BITS_IN      : in  std_logic_vector (31 downto 0);

      -- Data from Frontends
      FEE_DATA_OUT        : out std_logic_vector (15 downto 0);
      FEE_DATAREADY_OUT   : out std_logic;
      FEE_READ_IN         : in  std_logic;  --must be high when idle, otherwise you will never get a dataready
      FEE_STATUS_BITS_OUT : out std_logic_vector (31 downto 0);
      FEE_BUSY_OUT        : out std_logic;

      MY_ADDRESS_IN    : in std_logic_vector (15 downto 0);
      CTRL_SEQNR_RESET : in std_logic

      );
  end component;


  component trb_net16_api_ipu_streaming_internal is
    port(
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      -- Internal direction port

      FEE_INIT_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      FEE_INIT_DATAREADY_OUT  : out std_logic;
      FEE_INIT_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      FEE_INIT_READ_IN        : in  std_logic;

      FEE_REPLY_DATA_IN       : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      FEE_REPLY_DATAREADY_IN  : in  std_logic;
      FEE_REPLY_PACKET_NUM_IN : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      FEE_REPLY_READ_OUT      : out std_logic;

      --Event information coming from CTS
      CTS_SEND_IN         : in std_logic;
      CTS_NUMBER_IN       : in std_logic_vector (15 downto 0);  --valid while start_readout is high
      CTS_CODE_IN         : in std_logic_vector (7 downto 0);  --valid while start_readout is high
      CTS_INFORMATION_IN  : in std_logic_vector (7 downto 0);  --valid while start_readout is high
      CTS_READOUT_TYPE_IN : in std_logic_vector (3 downto 0);  --valid while start_readout is high

      CTS_STATUS_BITS_OUT : out std_logic_vector (31 downto 0);
      CTS_BUSY_OUT        : out std_logic;  --goes high after CTS_SEND_IN, goes low after GBE_READOUT_FINISHED_IN

      --connection to GbE
      GBE_CTS_NUMBER_OUT        : out std_logic_vector (15 downto 0);  --valid while start_readout is high
      GBE_CTS_CODE_OUT          : out std_logic_vector (7 downto 0);  --valid while start_readout is high
      GBE_CTS_INFORMATION_OUT   : out std_logic_vector (7 downto 0);  --valid while start_readout is high
      GBE_CTS_READOUT_TYPE_OUT  : out std_logic_vector (3 downto 0);  --valid while start_readout is high
      GBE_CTS_START_READOUT_OUT : out std_logic;

      GBE_READOUT_FINISHED_IN : in std_logic;  --no more data, end transfer, send TRM, should be high 1 CLK cycle
      GBE_STATUS_BITS_IN      : in std_logic_vector (31 downto 0);  --valid when readout_finished is high

      GBE_FEE_DATA_OUT        : out std_logic_vector (15 downto 0);  --data from FEE
      GBE_FEE_DATAREADY_OUT   : out std_logic;  --data on data_out is valid
      GBE_FEE_READ_IN         : in  std_logic;  --must be high always unless connected entity can not read data, otherwise you will never get a dataready
      GBE_FEE_STATUS_BITS_OUT : out std_logic_vector (31 downto 0);  --valid after busy is low again
      GBE_FEE_BUSY_OUT        : out std_logic;  --goes high shortly after start_readout; goes low when last dataword from FEE
                                                --has been read.

      MY_ADDRESS_IN    : in std_logic_vector (15 downto 0);
      CTRL_SEQNR_RESET : in std_logic

      );
  end component;


  component trb_net_bridge_pcie_apl is
    generic(
      USE_CHANNELS : channel_config_t := (c_YES, c_YES, c_NO, c_YES)
      );
    port(
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      --TrbNet connect
      APL_DATA_OUT           : out std_logic_vector (16*3-1 downto 0);
      APL_PACKET_NUM_OUT     : out std_logic_vector (3*3-1 downto 0);
      APL_DATAREADY_OUT      : out std_logic_vector (3-1 downto 0);
      APL_READ_IN            : in  std_logic_vector (3-1 downto 0);
      APL_SHORT_TRANSFER_OUT : out std_logic_vector (3-1 downto 0);
      APL_DTYPE_OUT          : out std_logic_vector (3*4-1 downto 0);
      APL_ERROR_PATTERN_OUT  : out std_logic_vector (32*3-1 downto 0);
      APL_SEND_OUT           : out std_logic_vector (3-1 downto 0);
      APL_TARGET_ADDRESS_OUT : out std_logic_vector (16*3-1 downto 0);
      APL_DATA_IN            : in  std_logic_vector (16*3-1 downto 0);
      APL_PACKET_NUM_IN      : in  std_logic_vector (3*3-1 downto 0);
      APL_TYP_IN             : in  std_logic_vector (3*3-1 downto 0);
      APL_DATAREADY_IN       : in  std_logic_vector (3-1 downto 0);
      APL_READ_OUT           : out std_logic_vector (3-1 downto 0);
      APL_RUN_IN             : in  std_logic_vector (3-1 downto 0);
      APL_SEQNR_IN           : in  std_logic_vector (8*3-1 downto 0);
      APL_FIFO_COUNT_IN      : in  std_logic_vector (11*3-1 downto 0);

      --Internal Data Bus
      BUS_ADDR_IN  : in  std_logic_vector(31 downto 0);
      BUS_WDAT_IN  : in  std_logic_vector(31 downto 0);
      BUS_RDAT_OUT : out std_logic_vector(31 downto 0);
      BUS_SEL_IN   : in  std_logic_vector(3 downto 0);
      BUS_WE_IN    : in  std_logic;
      BUS_CYC_IN   : in  std_logic;
      BUS_STB_IN   : in  std_logic;
      BUS_LOCK_IN  : in  std_logic;
      BUS_ACK_OUT  : out std_logic;

      EXT_TRIGGER_INFO : out std_logic_vector(15 downto 0);
      SEND_RESET_OUT   : out std_logic;
      --DMA interface

      --Debug
      STAT : out std_logic_vector (31 downto 0);
      CTRL : in  std_logic_vector (31 downto 0)
      );
  end component;


  component trb_net_bridge_pcie_endpoint is
    generic(
      USE_CHANNELS : channel_config_t := (c_YES, c_YES, c_NO, c_YES)
      );
    port(
      RESET : in std_logic;
      CLK   : in std_logic;

      BUS_ADDR_IN  : in  std_logic_vector(31 downto 0);
      BUS_WDAT_IN  : in  std_logic_vector(31 downto 0);
      BUS_RDAT_OUT : out std_logic_vector(31 downto 0);
      BUS_SEL_IN   : in  std_logic_vector(3 downto 0);
      BUS_WE_IN    : in  std_logic;
      BUS_CYC_IN   : in  std_logic;
      BUS_STB_IN   : in  std_logic;
      BUS_LOCK_IN  : in  std_logic;
      BUS_ACK_OUT  : out std_logic;

      MED_DATAREADY_IN  : in  std_logic;
      MED_DATA_IN       : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_OUT      : out std_logic;

      MED_DATAREADY_OUT  : out std_logic;
      MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_IN        : in  std_logic;

      MED_ERROR_IN   : in  std_logic_vector(2 downto 0);
      SEND_RESET_OUT : out std_logic;
      STAT           : out std_logic_vector(31 downto 0);
      STAT_ENDP      : out std_logic_vector(31 downto 0);
      STAT_API1      : out std_logic_vector(31 downto 0)
      );
  end component;


  component trb_net_bridge_pcie_endpoint_hub is
    generic(
      NUM_LINKS    : integer range 1 to 4          := 2;
      COMPILE_TIME : std_logic_vector(31 downto 0) := (others => '0')
      );
    port(
      RESET        : in std_logic;
      RESET_TRBNET : in std_logic;
      CLK          : in std_logic;
      CLK_125_IN   : in std_logic;

      BUS_ADDR_IN  : in  std_logic_vector(31 downto 0);
      BUS_WDAT_IN  : in  std_logic_vector(31 downto 0);
      BUS_RDAT_OUT : out std_logic_vector(31 downto 0);
      BUS_SEL_IN   : in  std_logic_vector(3 downto 0);
      BUS_WE_IN    : in  std_logic;
      BUS_CYC_IN   : in  std_logic;
      BUS_STB_IN   : in  std_logic;
      BUS_LOCK_IN  : in  std_logic;
      BUS_ACK_OUT  : out std_logic;

      SPI_CLK_OUT : out std_logic;
      SPI_D_OUT   : out std_logic;
      SPI_D_IN    : in  std_logic;
      SPI_CE_OUT  : out std_logic;

      MED_DATAREADY_IN  : in  std_logic_vector (NUM_LINKS-1 downto 0);
      MED_DATA_IN       : in  std_logic_vector (16*NUM_LINKS-1 downto 0);
      MED_PACKET_NUM_IN : in  std_logic_vector (3*NUM_LINKS-1 downto 0);
      MED_READ_OUT      : out std_logic_vector (NUM_LINKS-1 downto 0);

      MED_DATAREADY_OUT  : out std_logic_vector (NUM_LINKS-1 downto 0);
      MED_DATA_OUT       : out std_logic_vector (16*NUM_LINKS-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector (3*NUM_LINKS-1 downto 0);
      MED_READ_IN        : in  std_logic_vector (NUM_LINKS-1 downto 0);

      MED_STAT_OP_IN  : in  std_logic_vector (16*NUM_LINKS-1 downto 0);
      MED_CTRL_OP_OUT : out std_logic_vector (16*NUM_LINKS-1 downto 0);

      REQUESTOR_ID_IN : in  std_logic_vector(15 downto 0);
      TX_ST_OUT       : out std_logic;  --tx first word
      TX_END_OUT      : out std_logic;  --tx last word
      TX_DWEN_OUT     : out std_logic;  --tx use only upper 32 bit
      TX_DATA_OUT     : out std_logic_vector(63 downto 0);  --tx data out
      TX_REQ_OUT      : out std_logic;  --tx request out
      TX_RDY_IN       : in  std_logic;  --tx arbiter can read
      TX_VAL_IN       : in  std_logic;  --tx data is valid
      TX_CA_PH_IN     : in  std_logic_vector(8 downto 0);  --header credit for write
      TX_CA_PD_IN     : in  std_logic_vector(12 downto 0);  --data credits in 32 bit words
      TX_CA_NPH_IN    : in  std_logic_vector(8 downto 0);  --header credit for read

      RX_CR_CPLH_OUT : out std_logic;
      RX_CR_CPLD_OUT : out std_logic_vector(7 downto 0);
      UNEXP_CMPL_OUT : out std_logic;
      RX_ST_IN       : in  std_logic;
      RX_END_IN      : in  std_logic;
      RX_DWEN_IN     : in  std_logic;
      RX_DATA_IN     : in  std_logic_vector(63 downto 0);

      PROGRMN_OUT    : out std_logic;
      SEND_RESET_OUT : out std_logic;
      MAKE_RESET_OUT : out std_logic;
      DEBUG_OUT      : out std_logic_vector (31 downto 0)
      );
  end component;

  component trb_net_CRC is
    port(
      CLK       : in  std_logic;
      RESET     : in  std_logic;
      CLK_EN    : in  std_logic;
      DATA_IN   : in  std_logic_vector(15 downto 0);
      CRC_OUT   : out std_logic_vector(15 downto 0);
      CRC_match : out std_logic
      );
  end component;


  component trb_net_CRC8 is
    port(
      CLK       : in  std_logic;
      RESET     : in  std_logic;
      CLK_EN    : in  std_logic;
      DATA_IN   : in  std_logic_vector(7 downto 0);
      CRC_OUT   : out std_logic_vector(7 downto 0);
      CRC_match : out std_logic
      );
  end component;

  component ddr_off is
    port (
      Clk  : in  std_logic;
      Data : in  std_logic_vector(1 downto 0);
      Q    : out std_logic_vector(0 downto 0)
      );
  end component;



  component dll_in100_out100 is
    port (
      clk     : in  std_logic;
      aluhold : in  std_logic;
      clkop   : out std_logic;
      clkos   : out std_logic;
      lock    : out std_logic
      );
  end component;


  component dll_in200_out100 is
    port (
      clk     : in  std_logic;
      aluhold : in  std_logic;
      clkop   : out std_logic;
      clkos   : out std_logic;
      lock    : out std_logic
      );
  end component;


  component trb_net16_dummy_fifo is
    port (
      CLK             : in  std_logic;
      RESET           : in  std_logic;
      CLK_EN          : in  std_logic;
      DATA_IN         : in  std_logic_vector(c_DATA_WIDTH - 1 downto 0);
      PACKET_NUM_IN   : in  std_logic_vector(1 downto 0);
      WRITE_ENABLE_IN : in  std_logic;
      DATA_OUT        : out std_logic_vector(c_DATA_WIDTH - 1 downto 0);
      PACKET_NUM_OUT  : out std_logic_vector(1 downto 0);
      READ_ENABLE_IN  : in  std_logic;
      FULL_OUT        : out std_logic;
      EMPTY_OUT       : out std_logic
      );
  end component;





  component trb_net16_endpoint_hades_full is
    generic (
      USE_CHANNEL               : channel_config_t                       := (c_YES, c_YES, c_NO, c_YES);
      IBUF_DEPTH                : channel_config_t                       := (6, 6, 6, 6);
      FIFO_TO_INT_DEPTH         : channel_config_t                       := (6, 6, 6, 6);
      FIFO_TO_APL_DEPTH         : channel_config_t                       := (1, 1, 1, 1);
      IBUF_SECURE_MODE          : channel_config_t                       := (c_YES, c_YES, c_YES, c_YES);
      API_SECURE_MODE_TO_APL    : channel_config_t                       := (c_YES, c_YES, c_YES, c_YES);
      API_SECURE_MODE_TO_INT    : channel_config_t                       := (c_YES, c_YES, c_YES, c_YES);
      OBUF_DATA_COUNT_WIDTH     : integer range 0 to 7                   := std_DATA_COUNT_WIDTH;
      INIT_CAN_SEND_DATA        : channel_config_t                       := (c_NO, c_NO, c_NO, c_NO);
      REPLY_CAN_SEND_DATA       : channel_config_t                       := (c_YES, c_YES, c_YES, c_YES);
      REPLY_CAN_RECEIVE_DATA    : channel_config_t                       := (c_NO, c_NO, c_NO, c_NO);
      USE_CHECKSUM              : channel_config_t                       := (c_NO, c_YES, c_YES, c_YES);
      APL_WRITE_ALL_WORDS       : channel_config_t                       := (c_NO, c_NO, c_NO, c_NO);
      ADDRESS_MASK              : std_logic_vector(15 downto 0)          := x"FFFF";
      BROADCAST_BITMASK         : std_logic_vector(7 downto 0)           := x"FF";
      BROADCAST_SPECIAL_ADDR    : std_logic_vector(7 downto 0)           := x"FF";
      TIMING_TRIGGER_RAW        : integer range 0 to 1                   := c_YES;
      REGIO_NUM_STAT_REGS       : integer range 0 to 6                   := 3;  --log2 of number of status registers
      REGIO_NUM_CTRL_REGS       : integer range 0 to 6                   := 3;  --log2 of number of ctrl registers
      --standard values for output registers
      REGIO_INIT_CTRL_REGS      : std_logic_vector(2**(4)*32-1 downto 0) := (others => '0');
      --set to 0 for unused ctrl registers to save resources
      REGIO_USED_CTRL_REGS      : std_logic_vector(2**(4)-1 downto 0)    := (others => '1');
      --set to 0 for each unused bit in a register
      REGIO_USED_CTRL_BITMASK   : std_logic_vector(2**(4)*32-1 downto 0) := (others => '1');
      REGIO_USE_DAT_PORT        : integer range 0 to 1                   := c_YES;  --internal data port
      REGIO_INIT_ADDRESS        : std_logic_vector(15 downto 0)          := x"FFFF";
      REGIO_INIT_UNIQUE_ID      : std_logic_vector(63 downto 0)          := x"1000_2000_3654_4876";
      REGIO_INIT_BOARD_INFO     : std_logic_vector(31 downto 0)          := x"1111_2222";
      REGIO_INIT_ENDPOINT_ID    : std_logic_vector(15 downto 0)          := x"0001";
      REGIO_COMPILE_TIME        : std_logic_vector(31 downto 0)          := x"00000000";
      REGIO_COMPILE_VERSION     : std_logic_vector(15 downto 0)          := x"0001";
      REGIO_HARDWARE_VERSION    : std_logic_vector(31 downto 0)          := x"12345678";
      REGIO_USE_1WIRE_INTERFACE : integer                                := c_YES;  --c_YES,c_NO,c_MONITOR
      REGIO_USE_VAR_ENDPOINT_ID : integer range c_NO to c_YES            := c_NO;
      CLOCK_FREQUENCY           : integer range 1 to 200                 := 100
      );

    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic := '1';

      --  Media direction port
      MED_DATAREADY_OUT  : out std_logic;
      MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_IN        : in  std_logic;
      MED_DATAREADY_IN   : in  std_logic;
      MED_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_OUT       : out std_logic;
      MED_STAT_OP_IN     : in  std_logic_vector(15 downto 0);
      MED_CTRL_OP_OUT    : out std_logic_vector(15 downto 0);

      -- LVL1 trigger APL
      TRG_TIMING_TRG_RECEIVED_IN : in std_logic;  --strobe when timing trigger received

      LVL1_TRG_DATA_VALID_OUT     : out std_logic;  --trigger type, number, code, information are valid
      LVL1_TRG_VALID_TIMING_OUT   : out std_logic;  --valid timing trigger has been received
      LVL1_TRG_VALID_NOTIMING_OUT : out std_logic;  --valid trigger without timing trigger has been received
      LVL1_TRG_INVALID_OUT        : out std_logic;  --the current trigger is invalid (e.g. no timing trigger, no LVL1...)

      LVL1_TRG_TYPE_OUT        : out std_logic_vector(3 downto 0);
      LVL1_TRG_NUMBER_OUT      : out std_logic_vector(15 downto 0);
      LVL1_TRG_CODE_OUT        : out std_logic_vector(7 downto 0);
      LVL1_TRG_INFORMATION_OUT : out std_logic_vector(23 downto 0);

      LVL1_ERROR_PATTERN_IN   : in  std_logic_vector(31 downto 0) := x"00000000";
      LVL1_TRG_RELEASE_IN     : in  std_logic                     := '0';
      LVL1_INT_TRG_NUMBER_OUT : out std_logic_vector(15 downto 0);  --internally generated trigger number, for informational uses only

      --Information about trigger handler errors
      TRG_MULTIPLE_TRG_OUT     : out std_logic;
      TRG_TIMEOUT_DETECTED_OUT : out std_logic;
      TRG_SPURIOUS_TRG_OUT     : out std_logic;
      TRG_MISSING_TMG_TRG_OUT  : out std_logic;
      TRG_SPIKE_DETECTED_OUT   : out std_logic;
      TRG_LONG_TRG_OUT         : out std_logic;
      --Data Port
      IPU_NUMBER_OUT           : out std_logic_vector (15 downto 0);
      IPU_READOUT_TYPE_OUT     : out std_logic_vector (3 downto 0);
      IPU_INFORMATION_OUT      : out std_logic_vector (7 downto 0);
      --start strobe
      IPU_START_READOUT_OUT    : out std_logic;
      --detector data, equipped with DHDR
      IPU_DATA_IN              : in  std_logic_vector (31 downto 0);
      IPU_DATAREADY_IN         : in  std_logic;
      --no more data, end transfer, send TRM
      IPU_READOUT_FINISHED_IN  : in  std_logic;
      --will be low every second cycle due to 32bit -> 16bit conversion
      IPU_READ_OUT             : out std_logic;
      IPU_LENGTH_IN            : in  std_logic_vector (15 downto 0);
      IPU_ERROR_PATTERN_IN     : in  std_logic_vector (31 downto 0);


      -- Slow Control Data Port
      REGIO_COMMON_STAT_REG_IN  : in    std_logic_vector(std_COMSTATREG*32-1 downto 0)           := (others => '0');
      REGIO_COMMON_CTRL_REG_OUT : out   std_logic_vector(std_COMCTRLREG*32-1 downto 0);
      REGIO_REGISTERS_IN        : in    std_logic_vector(32*2**(REGIO_NUM_STAT_REGS)-1 downto 0) := (others => '0');
      REGIO_REGISTERS_OUT       : out   std_logic_vector(32*2**(REGIO_NUM_CTRL_REGS)-1 downto 0);
      COMMON_STAT_REG_STROBE    : out   std_logic_vector(std_COMSTATREG-1 downto 0);
      COMMON_CTRL_REG_STROBE    : out   std_logic_vector(std_COMCTRLREG-1 downto 0);
      STAT_REG_STROBE           : out   std_logic_vector(2**(REGIO_NUM_STAT_REGS)-1 downto 0);
      CTRL_REG_STROBE           : out   std_logic_vector(2**(REGIO_NUM_CTRL_REGS)-1 downto 0);
      --following ports only used when using internal data port
      REGIO_ADDR_OUT            : out   std_logic_vector(16-1 downto 0);
      REGIO_READ_ENABLE_OUT     : out   std_logic;
      REGIO_WRITE_ENABLE_OUT    : out   std_logic;
      REGIO_DATA_OUT            : out   std_logic_vector(32-1 downto 0);
      REGIO_DATA_IN             : in    std_logic_vector(32-1 downto 0)                          := (others => '0');
      REGIO_DATAREADY_IN        : in    std_logic                                                := '0';
      REGIO_NO_MORE_DATA_IN     : in    std_logic                                                := '0';
      REGIO_WRITE_ACK_IN        : in    std_logic                                                := '0';
      REGIO_UNKNOWN_ADDR_IN     : in    std_logic                                                := '0';
      REGIO_TIMEOUT_OUT         : out   std_logic;
      --IDRAM is used if no 1-wire interface, onewire used otherwise
      REGIO_IDRAM_DATA_IN       : in    std_logic_vector(15 downto 0)                            := (others => '0');
      REGIO_IDRAM_DATA_OUT      : out   std_logic_vector(15 downto 0);
      REGIO_IDRAM_ADDR_IN       : in    std_logic_vector(2 downto 0)                             := "000";
      REGIO_IDRAM_WR_IN         : in    std_logic                                                := '0';
      REGIO_ONEWIRE_INOUT       : inout std_logic;  --temperature sensor
      REGIO_ONEWIRE_MONITOR_IN  : in    std_logic                                                := '0';
      REGIO_ONEWIRE_MONITOR_OUT : out   std_logic;
      REGIO_VAR_ENDPOINT_ID     : in    std_logic_vector(15 downto 0)                            := (others => '0');

      GLOBAL_TIME_OUT         : out std_logic_vector(31 downto 0);  --global time, microseconds
      LOCAL_TIME_OUT          : out std_logic_vector(7 downto 0);  --local time running with chip frequency
      TIME_SINCE_LAST_TRG_OUT : out std_logic_vector(31 downto 0);  --local time, resetted with each trigger
      TIMER_TICKS_OUT         : out std_logic_vector(1 downto 0);  --bit 1 ms-tick, 0 us-tick
      --Debugging & Status information
      STAT_DEBUG_IPU          : out std_logic_vector (31 downto 0);
      STAT_DEBUG_1            : out std_logic_vector (31 downto 0);
      STAT_DEBUG_2            : out std_logic_vector (31 downto 0);
      MED_STAT_OP             : out std_logic_vector (15 downto 0);
      CTRL_MPLEX              : in  std_logic_vector (31 downto 0)     := (others => '0');
      IOBUF_CTRL_GEN          : in  std_logic_vector (4*32-1 downto 0) := (others => '0');
      STAT_ONEWIRE            : out std_logic_vector (31 downto 0);
      STAT_ADDR_DEBUG         : out std_logic_vector (15 downto 0);
      STAT_TRIGGER_OUT        : out std_logic_vector (79 downto 0);
      DEBUG_LVL1_HANDLER_OUT  : out std_logic_vector (15 downto 0)
      );
  end component;


  component trb_net16_endpoint_hades_full_handler is
    generic (
      IBUF_DEPTH                : channel_config_t                   := (6, 6, 6, 6);
      FIFO_TO_INT_DEPTH         : channel_config_t                   := (6, 6, 6, 6);
      FIFO_TO_APL_DEPTH         : channel_config_t                   := (1, 1, 1, 1);
      APL_WRITE_ALL_WORDS       : channel_config_t                   := (c_NO, c_NO, c_NO, c_NO);
      ADDRESS_MASK              : std_logic_vector(15 downto 0)      := x"FFFF";
      BROADCAST_BITMASK         : std_logic_vector(7 downto 0)       := x"FF";
      BROADCAST_SPECIAL_ADDR    : std_logic_vector(7 downto 0)       := x"FF";
      REGIO_NUM_STAT_REGS       : integer range 0 to 6               := 3;  --log2 of number of status registers
      REGIO_NUM_CTRL_REGS       : integer range 0 to 6               := 3;  --log2 of number of ctrl registers
      REGIO_INIT_CTRL_REGS      : std_logic_vector(16*32-1 downto 0) := (others => '0');
      REGIO_INIT_ADDRESS        : std_logic_vector(15 downto 0)      := x"FFFF";
      REGIO_INIT_BOARD_INFO     : std_logic_vector(31 downto 0)      := x"1111_2222";
      REGIO_INIT_ENDPOINT_ID    : std_logic_vector(15 downto 0)      := x"0001";
      REGIO_COMPILE_TIME        : std_logic_vector(31 downto 0)      := x"00000000";
      REGIO_COMPILE_VERSION     : std_logic_vector(15 downto 0)      := x"0001";
      REGIO_HARDWARE_VERSION    : std_logic_vector(31 downto 0)      := x"12345678";
      REGIO_USE_1WIRE_INTERFACE : integer                            := c_YES;  --c_YES,c_NO,c_MONITOR
      REGIO_USE_VAR_ENDPOINT_ID : integer range c_NO to c_YES        := c_NO;
      TIMING_TRIGGER_RAW        : integer range 0 to 1               := c_YES;
      CLOCK_FREQUENCY           : integer range 1 to 200             := 100;
      --Configure data handler
      DATA_INTERFACE_NUMBER     : integer range 1 to 16              := 1;
      DATA_BUFFER_DEPTH         : integer range 9 to 14              := 9;
      DATA_BUFFER_WIDTH         : integer range 1 to 32              := 31;
      DATA_BUFFER_FULL_THRESH   : integer range 0 to 2**14-2         := 2**8;
      TRG_RELEASE_AFTER_DATA    : integer range 0 to 1               := c_YES;
      HEADER_BUFFER_DEPTH       : integer range 9 to 14              := 9;
      HEADER_BUFFER_FULL_THRESH : integer range 2**8 to 2**14-2      := 2**8
      );

    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic := '1';

      --  Media direction port
      MED_DATAREADY_OUT  : out std_logic;
      MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_IN        : in  std_logic;
      MED_DATAREADY_IN   : in  std_logic;
      MED_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_OUT       : out std_logic;
      MED_STAT_OP_IN     : in  std_logic_vector(15 downto 0);
      MED_CTRL_OP_OUT    : out std_logic_vector(15 downto 0);

      --Timing trigger in
      TRG_TIMING_TRG_RECEIVED_IN  : in  std_logic;
      --LVL1 trigger to FEE
      LVL1_TRG_DATA_VALID_OUT     : out std_logic;  --trigger type, number, code, information are valid
      LVL1_VALID_TIMING_TRG_OUT   : out std_logic;  --valid timing trigger has been received
      LVL1_VALID_NOTIMING_TRG_OUT : out std_logic;  --valid trigger without timing trigger has been received
      LVL1_INVALID_TRG_OUT        : out std_logic;  --the current trigger is invalid (e.g. no timing trigger, no LVL1...)

      LVL1_TRG_TYPE_OUT        : out std_logic_vector(3 downto 0);
      LVL1_TRG_NUMBER_OUT      : out std_logic_vector(15 downto 0);
      LVL1_TRG_CODE_OUT        : out std_logic_vector(7 downto 0);
      LVL1_TRG_INFORMATION_OUT : out std_logic_vector(23 downto 0);
      LVL1_INT_TRG_NUMBER_OUT  : out std_logic_vector(15 downto 0);  --internally generated trigger number, for informational uses only

      --Response from FEE
      FEE_TRG_RELEASE_IN       : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
      FEE_TRG_STATUSBITS_IN    : in  std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
      FEE_DATA_IN              : in  std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
      FEE_DATA_WRITE_IN        : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
      FEE_DATA_FINISHED_IN     : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
      FEE_DATA_ALMOST_FULL_OUT : out std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);

      --Information about trigger handler errors
      TRG_MULTIPLE_TRG_OUT     : out std_logic;
      TRG_TIMEOUT_DETECTED_OUT : out std_logic;
      TRG_SPURIOUS_TRG_OUT     : out std_logic;
      TRG_MISSING_TMG_TRG_OUT  : out std_logic;
      TRG_SPIKE_DETECTED_OUT   : out std_logic;

      --Slow Control Port
      --common registers
      REGIO_COMMON_STAT_REG_IN     : in    std_logic_vector(std_COMSTATREG*32-1 downto 0)           := (others => '0');
      REGIO_COMMON_CTRL_REG_OUT    : out   std_logic_vector(std_COMCTRLREG*32-1 downto 0);
      REGIO_COMMON_STAT_STROBE_OUT : out   std_logic_vector(std_COMSTATREG-1 downto 0);
      REGIO_COMMON_CTRL_STROBE_OUT : out   std_logic_vector(std_COMCTRLREG-1 downto 0);
      --user defined registers
      REGIO_STAT_REG_IN            : in    std_logic_vector(2**(REGIO_NUM_STAT_REGS)*32-1 downto 0) := (others => '0');
      REGIO_CTRL_REG_OUT           : out   std_logic_vector(2**(REGIO_NUM_CTRL_REGS)*32-1 downto 0);
      REGIO_STAT_STROBE_OUT        : out   std_logic_vector(2**(REGIO_NUM_STAT_REGS)-1 downto 0);
      REGIO_CTRL_STROBE_OUT        : out   std_logic_vector(2**(REGIO_NUM_CTRL_REGS)-1 downto 0);
      --internal data port
      BUS_ADDR_OUT                 : out   std_logic_vector(16-1 downto 0);
      BUS_DATA_OUT                 : out   std_logic_vector(32-1 downto 0);
      BUS_READ_ENABLE_OUT          : out   std_logic;
      BUS_WRITE_ENABLE_OUT         : out   std_logic;
      BUS_TIMEOUT_OUT              : out   std_logic;
      BUS_DATA_IN                  : in    std_logic_vector(32-1 downto 0)                          := (others => '0');
      BUS_DATAREADY_IN             : in    std_logic                                                := '0';
      BUS_WRITE_ACK_IN             : in    std_logic                                                := '0';
      BUS_NO_MORE_DATA_IN          : in    std_logic                                                := '0';
      BUS_UNKNOWN_ADDR_IN          : in    std_logic                                                := '0';
      --Onewire
      ONEWIRE_INOUT                : inout std_logic;  --temperature sensor
      ONEWIRE_MONITOR_IN           : in    std_logic                                                := '0';
      ONEWIRE_MONITOR_OUT          : out   std_logic;
      --Config endpoint id, if not statically assigned
      REGIO_VAR_ENDPOINT_ID        : in    std_logic_vector (15 downto 0)                           := (others => '0');

      --Timing registers
      TIME_GLOBAL_OUT         : out std_logic_vector (31 downto 0);  --global time, microseconds
      TIME_LOCAL_OUT          : out std_logic_vector (7 downto 0);  --local time running with chip frequency
      TIME_SINCE_LAST_TRG_OUT : out std_logic_vector (31 downto 0);  --local time, resetted with each trigger
      TIME_TICKS_OUT          : out std_logic_vector (1 downto 0);  --bit 1 ms-tick, 0 us-tick

      --Debugging & Status information
      STAT_DEBUG_IPU              : out std_logic_vector (31 downto 0);
      STAT_DEBUG_1                : out std_logic_vector (31 downto 0);
      STAT_DEBUG_2                : out std_logic_vector (31 downto 0);
      STAT_DEBUG_DATA_HANDLER_OUT : out std_logic_vector (31 downto 0);
      STAT_DEBUG_IPU_HANDLER_OUT  : out std_logic_vector (31 downto 0);
      CTRL_MPLEX                  : in  std_logic_vector (31 downto 0)     := (others => '0');
      IOBUF_CTRL_GEN              : in  std_logic_vector (4*32-1 downto 0) := (others => '0');
      STAT_ONEWIRE                : out std_logic_vector (31 downto 0);
      STAT_ADDR_DEBUG             : out std_logic_vector (15 downto 0);
      STAT_TRIGGER_OUT            : out std_logic_vector (79 downto 0);
      DEBUG_LVL1_HANDLER_OUT      : out std_logic_vector (15 downto 0)
      );
  end component;

  component trb_net16_endpoint_hades_cts is
    generic(
      USE_CHANNEL               : channel_config_t                       := (c_YES, c_YES, c_NO, c_YES);
      IBUF_DEPTH                : channel_config_t                       := (1, 6, 6, 6);
      FIFO_TO_INT_DEPTH         : channel_config_t                       := (1, 1, 6, 6);
      FIFO_TO_APL_DEPTH         : channel_config_t                       := (1, 6, 6, 6);
      INIT_CAN_SEND_DATA        : channel_config_t                       := (c_YES, c_YES, c_NO, c_NO);
      REPLY_CAN_SEND_DATA       : channel_config_t                       := (c_NO, c_NO, c_NO, c_YES);
      REPLY_CAN_RECEIVE_DATA    : channel_config_t                       := (c_YES, c_YES, c_NO, c_NO);
      USE_CHECKSUM              : channel_config_t                       := (c_NO, c_YES, c_YES, c_YES);
      APL_WRITE_ALL_WORDS       : channel_config_t                       := (c_NO, c_NO, c_NO, c_NO);
      ADDRESS_MASK              : std_logic_vector(15 downto 0)          := x"FFFF";
      BROADCAST_BITMASK         : std_logic_vector(7 downto 0)           := x"FF";
      REGIO_NUM_STAT_REGS       : integer range 0 to 6                   := 2;  --log2 of number of status registers
      REGIO_NUM_CTRL_REGS       : integer range 0 to 6                   := 3;  --log2 of number of ctrl registers
      --standard values for output registers
      REGIO_INIT_CTRL_REGS      : std_logic_vector(2**(4)*32-1 downto 0) := (others => '0');
      --set to 0 for unused ctrl registers to save resources
      REGIO_USED_CTRL_REGS      : std_logic_vector(2**(4)-1 downto 0)    := x"0001";
      --set to 0 for each unused bit in a register
      REGIO_USED_CTRL_BITMASK   : std_logic_vector(2**(4)*32-1 downto 0) := (others => '1');
      REGIO_USE_DAT_PORT        : integer range 0 to 1                   := c_YES;  --internal data port
      REGIO_INIT_ADDRESS        : std_logic_vector(15 downto 0)          := x"FFFF";
      REGIO_INIT_UNIQUE_ID      : std_logic_vector(63 downto 0)          := x"0000_0000_0000_0000";
      REGIO_INIT_BOARD_INFO     : std_logic_vector(31 downto 0)          := x"0000_0000";
      REGIO_INIT_ENDPOINT_ID    : std_logic_vector(15 downto 0)          := x"0001";
      REGIO_COMPILE_TIME        : std_logic_vector(31 downto 0)          := x"00000000";
      REGIO_COMPILE_VERSION     : std_logic_vector(15 downto 0)          := x"0001";
      REGIO_HARDWARE_VERSION    : std_logic_vector(31 downto 0)          := x"50000000";
      REGIO_USE_1WIRE_INTERFACE : integer                                := c_YES;  --c_YES,c_NO,c_MONITOR
      REGIO_USE_VAR_ENDPOINT_ID : integer range c_NO to c_YES            := c_NO;
      CLOCK_FREQUENCY           : integer range 1 to 200                 := 100
      );
    port(
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      --  Media direction port
      MED_DATAREADY_OUT  : out std_logic;
      MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_IN        : in  std_logic;

      MED_DATAREADY_IN  : in  std_logic;
      MED_DATA_IN       : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_OUT      : out std_logic;

      MED_STAT_OP_IN  : in  std_logic_vector(15 downto 0);
      MED_CTRL_OP_OUT : out std_logic_vector(15 downto 0);

      --LVL1 trigger
      TRG_SEND_IN         : in  std_logic;
      TRG_TYPE_IN         : in  std_logic_vector (3 downto 0);
      TRG_NUMBER_IN       : in  std_logic_vector (15 downto 0);
      TRG_INFORMATION_IN  : in  std_logic_vector (23 downto 0);
      TRG_RND_CODE_IN     : in  std_logic_vector (7 downto 0);
      TRG_STATUS_BITS_OUT : out std_logic_vector (31 downto 0);
      TRG_BUSY_OUT        : out std_logic;

      --IPU Channel
      IPU_SEND_IN         : in  std_logic;
      IPU_TYPE_IN         : in  std_logic_vector (3 downto 0);
      IPU_NUMBER_IN       : in  std_logic_vector (15 downto 0);
      IPU_INFORMATION_IN  : in  std_logic_vector (7 downto 0);
      IPU_RND_CODE_IN     : in  std_logic_vector (7 downto 0);
      -- Receiver port
      IPU_DATA_OUT        : out std_logic_vector (31 downto 0);
      IPU_DATAREADY_OUT   : out std_logic;
      IPU_READ_IN         : in  std_logic;
      IPU_STATUS_BITS_OUT : out std_logic_vector (31 downto 0);
      IPU_BUSY_OUT        : out std_logic;

      -- Slow Control Data Port
      REGIO_COMMON_STAT_REG_IN  : in    std_logic_vector(std_COMSTATREG*32-1 downto 0)           := (others => '0');
      REGIO_COMMON_CTRL_REG_OUT : out   std_logic_vector(std_COMCTRLREG*32-1 downto 0);
      REGIO_REGISTERS_IN        : in    std_logic_vector(32*2**(REGIO_NUM_STAT_REGS)-1 downto 0) := (others => '0');
      REGIO_REGISTERS_OUT       : out   std_logic_vector(32*2**(REGIO_NUM_CTRL_REGS)-1 downto 0);
      COMMON_STAT_REG_STROBE    : out   std_logic_vector(std_COMSTATREG-1 downto 0);
      COMMON_CTRL_REG_STROBE    : out   std_logic_vector(std_COMCTRLREG-1 downto 0);
      STAT_REG_STROBE           : out   std_logic_vector(2**(REGIO_NUM_STAT_REGS)-1 downto 0);
      CTRL_REG_STROBE           : out   std_logic_vector(2**(REGIO_NUM_CTRL_REGS)-1 downto 0);
      --following ports only used when using internal data port
      REGIO_ADDR_OUT            : out   std_logic_vector(16-1 downto 0);
      REGIO_READ_ENABLE_OUT     : out   std_logic;
      REGIO_WRITE_ENABLE_OUT    : out   std_logic;
      REGIO_DATA_OUT            : out   std_logic_vector(32-1 downto 0);
      REGIO_DATA_IN             : in    std_logic_vector(32-1 downto 0)                          := (others => '0');
      REGIO_DATAREADY_IN        : in    std_logic                                                := '0';
      REGIO_NO_MORE_DATA_IN     : in    std_logic                                                := '0';
      REGIO_WRITE_ACK_IN        : in    std_logic                                                := '0';
      REGIO_UNKNOWN_ADDR_IN     : in    std_logic                                                := '0';
      REGIO_TIMEOUT_OUT         : out   std_logic;
      REGIO_ONEWIRE_INOUT       : inout std_logic;
      REGIO_ONEWIRE_MONITOR_OUT : out   std_logic;
      REGIO_ONEWIRE_MONITOR_IN  : in    std_logic;
      REGIO_VAR_ENDPOINT_ID     : in    std_logic_vector(15 downto 0)                            := (others => '0');
      TRIGGER_MONITOR_IN        : in    std_logic                                                := '0';  --strobe when timing trigger received
      GLOBAL_TIME_OUT           : out   std_logic_vector(31 downto 0);  --global time, microseconds
      LOCAL_TIME_OUT            : out   std_logic_vector(7 downto 0);  --local time running with chip frequency
      TIME_SINCE_LAST_TRG_OUT   : out   std_logic_vector(31 downto 0);  --local time, resetted with each trigger
      TIMER_TICKS_OUT           : out   std_logic_vector(1 downto 0);  --bit 1 ms-tick, 0 us-tick
      STAT_DEBUG_1              : out   std_logic_vector(31 downto 0);
      STAT_DEBUG_2              : out   std_logic_vector(31 downto 0)
      );

  end component;




  component etrax_interface is
    generic(
      STATUS_REGISTERS  : integer := 4;
      CONTROL_REGISTERS : integer := 4
      );
    port (
      CLK                   : in  std_logic;
      RESET                 : in  std_logic;
      --Connection to Etrax
      ETRAX_DATA_BUS_B      : out std_logic_vector(17 downto 0);
      ETRAX_DATA_BUS_C      : in  std_logic_vector(17 downto 0);
      ETRAX_BUS_BUSY        : out std_logic;
      --Connection to internal FPGA logic (all addresses above 0x100)
      INTERNAL_DATA_OUT     : out std_logic_vector(31 downto 0);
      INTERNAL_DATA_IN      : in  std_logic_vector(31 downto 0);
      INTERNAL_READ_OUT     : out std_logic;
      INTERNAL_WRITE_OUT    : out std_logic;
      INTERNAL_DATAREADY_IN : in  std_logic;
      INTERNAL_ADDRESS_OUT  : out std_logic_vector(15 downto 0);
      --Easy-to-use status and control registers (Addresses 0-15 (stat) and 16-31 (ctrl)
      FPGA_REGISTER_IN      : in  std_logic_vector(STATUS_REGISTERS*32-1 downto 0);
      FPGA_REGISTER_OUT     : out std_logic_vector(CONTROL_REGISTERS*32-1 downto 0);
      --Reset FPGA via Etrax
      EXTERNAL_RESET        : out std_logic;
      STAT                  : out std_logic_vector(15 downto 0)
      );
  end component;








  component trb_net16_fifo is
    generic (
      USE_VENDOR_CORES : integer range 0 to 1 := c_NO;
      USE_DATA_COUNT   : integer range 0 to 1 := c_NO;
      DEPTH            : integer              := 6
      );
    port (
      CLK             : in  std_logic;
      RESET           : in  std_logic;
      CLK_EN          : in  std_logic;
      DATA_IN         : in  std_logic_vector(c_DATA_WIDTH - 1 downto 0);
      PACKET_NUM_IN   : in  std_logic_vector(1 downto 0);
      WRITE_ENABLE_IN : in  std_logic;
      DATA_OUT        : out std_logic_vector(c_DATA_WIDTH - 1 downto 0);
      PACKET_NUM_OUT  : out std_logic_vector(1 downto 0);
      READ_ENABLE_IN  : in  std_logic;
      DATA_COUNT_OUT  : out std_logic_vector(10 downto 0);
      FULL_OUT        : out std_logic;
      EMPTY_OUT       : out std_logic
      );
  end component;





  component trb_net_fifo_16bit_bram_dualport is
    generic(
      USE_STATUS_FLAGS : integer := c_YES
      );
    port(read_clock_in     : in  std_logic;
          write_clock_in   : in  std_logic;
          read_enable_in   : in  std_logic;
          write_enable_in  : in  std_logic;
          fifo_gsr_in      : in  std_logic;
          write_data_in    : in  std_logic_vector(17 downto 0);
          read_data_out    : out std_logic_vector(17 downto 0);
          full_out         : out std_logic;
          empty_out        : out std_logic;
          fifostatus_out   : out std_logic_vector(3 downto 0);
          valid_read_out   : out std_logic;
          almost_empty_out : out std_logic;
          almost_full_out  : out std_logic
          );
  end component;






  component fifo_dualclock_width_16_reg is
    port (
      Data    : in  std_logic_vector(17 downto 0);
      WrClock : in  std_logic;
      RdClock : in  std_logic;
      WrEn    : in  std_logic;
      RdEn    : in  std_logic;
      Reset   : in  std_logic;
      RPReset : in  std_logic;
      Q       : out std_logic_vector(17 downto 0);
      Empty   : out std_logic;
      Full    : out std_logic);
  end component;



  component fpga_reboot is
    port(
      CLK       : in  std_logic;
      RESET     : in  std_logic;
      DO_REBOOT : in  std_logic;
      PROGRAMN  : out std_logic
      );
  end component;


  component handler_data is
    generic(
      DATA_INTERFACE_NUMBER     : integer range 1 to 16         := 1;
      DATA_BUFFER_DEPTH         : integer range 9 to 14         := 9;
      DATA_BUFFER_WIDTH         : integer range 1 to 32         := 32;
      DATA_BUFFER_FULL_THRESH   : integer range 0 to 2**14-1    := 2**8;
      TRG_RELEASE_AFTER_DATA    : integer range 0 to 1          := c_YES;
      HEADER_BUFFER_DEPTH       : integer range 9 to 14         := 9;
      HEADER_BUFFER_FULL_THRESH : integer range 2**8 to 2**14-1 := 2**8
      );
    port(
      CLOCK : in std_logic;
      RESET : in std_logic;

      --LVL1 Handler
      LVL1_VALID_TRIGGER_IN  : in  std_logic;  --received valid trigger, readout starts
      LVL1_TRG_DATA_VALID_IN : in  std_logic;  --TRG Info valid & FEE busy
      LVL1_TRG_TYPE_IN       : in  std_logic_vector(3 downto 0);  --trigger type
      LVL1_TRG_INFO_IN       : in  std_logic_vector(23 downto 0);  --further trigger details
      LVL1_TRG_CODE_IN       : in  std_logic_vector(7 downto 0);
      LVL1_TRG_NUMBER_IN     : in  std_logic_vector(15 downto 0);  --trigger number
      LVL1_STATUSBITS_OUT    : out std_logic_vector(31 downto 0);
      LVL1_TRG_RELEASE_OUT   : out std_logic;

      --FEE
      FEE_DATA_IN              : in  std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
      FEE_DATA_WRITE_IN        : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
      FEE_DATA_FINISHED_IN     : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
      FEE_DATA_ALMOST_FULL_OUT : out std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);

      --IPU Handler
      IPU_DATA_OUT        : out std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
      IPU_DATA_READ_IN    : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
      IPU_DATA_EMPTY_OUT  : out std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
      IPU_DATA_LENGTH_OUT : out std_logic_vector(DATA_INTERFACE_NUMBER*16-1 downto 0);
      IPU_DATA_FLAGS_OUT  : out std_logic_vector(DATA_INTERFACE_NUMBER*4-1 downto 0);

      IPU_HDR_DATA_OUT       : out std_logic_vector(31 downto 0);
      IPU_HDR_DATA_READ_IN   : in  std_logic;
      IPU_HDR_DATA_EMPTY_OUT : out std_logic;

      TMG_TRG_ERROR_IN         : in  std_logic;
      MAX_EVENT_SIZE_IN        : in  std_logic_vector(15 downto 0) := x"FFFF";
      --Status
      STAT_DATA_BUFFER_LEVEL   : out std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
      STAT_HEADER_BUFFER_LEVEL : out std_logic_vector(31 downto 0);

      --Debug
      DEBUG_OUT : out std_logic_vector(31 downto 0)
      );

  end component;





  component handler_ipu is
    generic(
      DATA_INTERFACE_NUMBER : integer range 1 to 7 := 1
      );
    port(
      CLOCK : in std_logic;
      RESET : in std_logic;

      --From Data Handler
      DAT_DATA_IN           : in  std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
      DAT_DATA_READ_OUT     : out std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
      DAT_DATA_EMPTY_IN     : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
      DAT_DATA_LENGTH_IN    : in  std_logic_vector(DATA_INTERFACE_NUMBER*16-1 downto 0);
      DAT_DATA_FLAGS_IN     : in  std_logic_vector(DATA_INTERFACE_NUMBER*4-1 downto 0);
      DAT_HDR_DATA_IN       : in  std_logic_vector(31 downto 0);
      DAT_HDR_DATA_READ_OUT : out std_logic;
      DAT_HDR_DATA_EMPTY_IN : in  std_logic;

      --To IPU Channel
      IPU_NUMBER_IN            : in  std_logic_vector (15 downto 0);
      IPU_INFORMATION_IN       : in  std_logic_vector (7 downto 0);
      IPU_READOUT_TYPE_IN      : in  std_logic_vector (3 downto 0);
      IPU_START_READOUT_IN     : in  std_logic;
      IPU_DATA_OUT             : out std_logic_vector (31 downto 0);
      IPU_DATAREADY_OUT        : out std_logic;
      IPU_READOUT_FINISHED_OUT : out std_logic;
      IPU_READ_IN              : in  std_logic;
      IPU_LENGTH_OUT           : out std_logic_vector (15 downto 0);
      IPU_ERROR_PATTERN_OUT    : out std_logic_vector (31 downto 0);

      --Debug
      STATUS_OUT : out std_logic_vector(31 downto 0)
      );

  end component;



  component handler_lvl1 is
    generic(
      TIMING_TRIGGER_RAW : integer range 0 to 1 := c_YES
      );
    port(
      RESET                   : in  std_logic;
      RESET_FLAGS_IN          : in  std_logic;
      RESET_STATS_IN          : in  std_logic;
      CLOCK                   : in  std_logic;
      --Timing Trigger
      LVL1_TIMING_TRG_IN      : in  std_logic;  --raw trigger signal input, min. 80 ns or strobe, see generics
      LVL1_PSEUDO_TMG_TRG_IN  : in  std_logic;  --strobe for dummy timing trigger
      --LVL1_handler connection
      LVL1_TRG_RECEIVED_IN    : in  std_logic;
      LVL1_TRG_TYPE_IN        : in  std_logic_vector(3 downto 0);
      LVL1_TRG_NUMBER_IN      : in  std_logic_vector(15 downto 0);
      LVL1_TRG_CODE_IN        : in  std_logic_vector(7 downto 0);
      LVL1_TRG_INFORMATION_IN : in  std_logic_vector(23 downto 0);
      LVL1_ERROR_PATTERN_OUT  : out std_logic_vector(31 downto 0);  --errorbits to CTS
      LVL1_TRG_RELEASE_OUT    : out std_logic := '0';  --release to CTS

      LVL1_INT_TRG_NUMBER_OUT : out std_logic_vector(15 downto 0);  -- increased after trigger release
      LVL1_INT_TRG_LOAD_IN    : in  std_logic;  -- load internal trigger counter
      LVL1_INT_TRG_COUNTER_IN : in  std_logic_vector(15 downto 0);  -- load value for internal trigger counter

      --FEE logic / Data Handler
      LVL1_TRG_DATA_VALID_OUT     : out std_logic;  -- trigger type, number, code, information are valid
      LVL1_VALID_TIMING_TRG_OUT   : out std_logic;  -- valid timing trigger has been received
      LVL1_VALID_NOTIMING_TRG_OUT : out std_logic;  -- valid trigger without timing trigger has been received
      LVL1_INVALID_TRG_OUT        : out std_logic;  -- the current trigger is invalid (e.g. no timing trigger, no LVL1...)
      LVL1_MULTIPLE_TRG_OUT       : out std_logic;  -- more than one timing trigger detected
      LVL1_DELAY_OUT              : out std_logic_vector(15 downto 0);
      LVL1_TIMEOUT_DETECTED_OUT   : out std_logic;  -- gk 11.09.10
      LVL1_SPURIOUS_TRG_OUT       : out std_logic;  -- gk 11.09.10
      LVL1_MISSING_TMG_TRG_OUT    : out std_logic;  -- gk 11.09.10
      LVL1_LONG_TRG_OUT           : out std_logic;
      SPIKE_DETECTED_OUT          : out std_logic;  -- gk 12.09.10

      LVL1_ERROR_PATTERN_IN : in std_logic_vector(31 downto 0);  -- error pattern from FEE
      LVL1_TRG_RELEASE_IN   : in std_logic := '0';  -- trigger release from FEE

      --Stat/Control
      STATUS_OUT          : out std_logic_vector (63 downto 0);  -- bits for status registers
      TRG_ENABLE_IN       : in  std_logic;  -- trigger enable flag
      TRG_INVERT_IN       : in  std_logic;  -- trigger invert flag
      COUNTERS_STATUS_OUT : out std_logic_vector (79 downto 0);
      --Debug
      DEBUG_OUT           : out std_logic_vector (15 downto 0)
      );
  end component;





  component handler_trigger_and_data is
    generic(
      DATA_INTERFACE_NUMBER     : integer range 1 to 16         := 1;
      DATA_BUFFER_DEPTH         : integer range 9 to 14         := 9;
      DATA_BUFFER_WIDTH         : integer range 1 to 32         := 32;
      DATA_BUFFER_FULL_THRESH   : integer range 0 to 2**14-1    := 2**8;
      TRG_RELEASE_AFTER_DATA    : integer range 0 to 1          := c_YES;
      HEADER_BUFFER_DEPTH       : integer range 9 to 14         := 9;
      HEADER_BUFFER_FULL_THRESH : integer range 2**8 to 2**14-1 := 2**8
      );
    port(
      CLOCK     : in std_logic;
      RESET     : in std_logic;
      RESET_IPU : in std_logic;

      --To Endpoint
      --Timing Trigger (registered)
      LVL1_VALID_TRIGGER_IN   : in  std_logic;
      LVL1_INT_TRG_NUMBER_IN  : in  std_logic_vector(15 downto 0);
      --LVL1_handler connection
      LVL1_TRG_DATA_VALID_IN  : in  std_logic;
      LVL1_TRG_TYPE_IN        : in  std_logic_vector(3 downto 0);
      LVL1_TRG_NUMBER_IN      : in  std_logic_vector(15 downto 0);
      LVL1_TRG_CODE_IN        : in  std_logic_vector(7 downto 0);
      LVL1_TRG_INFORMATION_IN : in  std_logic_vector(23 downto 0);
      LVL1_ERROR_PATTERN_OUT  : out std_logic_vector(31 downto 0);
      LVL1_TRG_RELEASE_OUT    : out std_logic;

      --IPU channel
      IPU_NUMBER_IN            : in  std_logic_vector(15 downto 0);
      IPU_INFORMATION_IN       : in  std_logic_vector(7 downto 0);
      IPU_READOUT_TYPE_IN      : in  std_logic_vector(3 downto 0);
      IPU_START_READOUT_IN     : in  std_logic;
      IPU_DATA_OUT             : out std_logic_vector(31 downto 0);
      IPU_DATAREADY_OUT        : out std_logic;
      IPU_READOUT_FINISHED_OUT : out std_logic;
      IPU_READ_IN              : in  std_logic;
      IPU_LENGTH_OUT           : out std_logic_vector(15 downto 0);
      IPU_ERROR_PATTERN_OUT    : out std_logic_vector(31 downto 0);

      --To FEE
      --FEE to Trigger
      FEE_TRG_RELEASE_IN    : in std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
      FEE_TRG_STATUSBITS_IN : in std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);

      --Data Input from FEE
      FEE_DATA_IN              : in  std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
      FEE_DATA_WRITE_IN        : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
      FEE_DATA_FINISHED_IN     : in  std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);
      FEE_DATA_ALMOST_FULL_OUT : out std_logic_vector(DATA_INTERFACE_NUMBER-1 downto 0);

      TMG_TRG_ERROR_IN         : in  std_logic;
      MAX_EVENT_SIZE_IN        : in  std_logic_vector(15 downto 0) := x"FFFF";
      --Status Registers
      STATUS_OUT               : out std_logic_vector(127 downto 0);
      STAT_DATA_BUFFER_LEVEL   : out std_logic_vector(DATA_INTERFACE_NUMBER*32-1 downto 0);
      STAT_HEADER_BUFFER_LEVEL : out std_logic_vector(31 downto 0);
      TIMER_TICKS_IN           : in  std_logic_vector(1 downto 0);
      STATISTICS_DATA_OUT      : out std_logic_vector(31 downto 0);
      STATISTICS_ADDR_IN       : in  std_logic_vector(4 downto 0);
      STATISTICS_READY_OUT     : out std_logic;
      STATISTICS_READ_IN       : in  std_logic;
      STATISTICS_UNKNOWN_OUT   : out std_logic;

      --Debug
      DEBUG_DATA_HANDLER_OUT : out std_logic_vector(31 downto 0);
      DEBUG_IPU_HANDLER_OUT  : out std_logic_vector(31 downto 0)

      );
  end component;







  component trb_net16_ibuf is
    generic (
      DEPTH                  : integer range 0 to 7 := c_FIFO_BRAM;
      USE_VENDOR_CORES       : integer range 0 to 1 := c_YES;
      USE_ACKNOWLEDGE        : integer range 0 to 1 := std_USE_ACKNOWLEDGE;
      USE_CHECKSUM           : integer range 0 to 1 := c_YES;
      SBUF_VERSION           : integer range 0 to 1 := std_SBUF_VERSION;
      INIT_CAN_RECEIVE_DATA  : integer range 0 to 1 := c_YES;
      REPLY_CAN_RECEIVE_DATA : integer range 0 to 1 := c_YES
      );
    port(
      --  Misc
      CLK                      : in  std_logic;
      RESET                    : in  std_logic;
      CLK_EN                   : in  std_logic;
      --  Media direction port
      MED_DATAREADY_IN         : in  std_logic;
      MED_DATA_IN              : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN        : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_READ_OUT             : out std_logic;
      MED_ERROR_IN             : in  std_logic_vector (2 downto 0);
      -- Internal direction port
      INT_INIT_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_INIT_PACKET_NUM_OUT  : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      INT_INIT_DATAREADY_OUT   : out std_logic;
      INT_INIT_READ_IN         : in  std_logic;
      INT_REPLY_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_REPLY_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      INT_REPLY_DATAREADY_OUT  : out std_logic;
      INT_REPLY_READ_IN        : in  std_logic;
      INT_ERROR_OUT            : out std_logic_vector (2 downto 0);
      -- Status and control port
      STAT_BUFFER_COUNTER      : out std_logic_vector (31 downto 0);
      STAT_DATA_COUNTER        : out std_logic_vector (31 downto 0);
      STAT_BUFFER              : out std_logic_vector (31 downto 0);
      CTRL_STAT                : in  std_logic_vector (15 downto 0)
      );
  end component;






  component fifo_36x512 is
    port (
      Data  : in  std_logic_vector(35 downto 0);
      Clock : in  std_logic;
      WrEn  : in  std_logic;
      RdEn  : in  std_logic;
      Reset : in  std_logic;
      Q     : out std_logic_vector(35 downto 0);
      Empty : out std_logic;
      Full  : out std_logic
      );
  end component;


  component trb_net16_iobuf is
    generic (
      IBUF_DEPTH             : integer range 0 to 6 := c_FIFO_BRAM;  --std_FIFO_DEPTH;
      IBUF_SECURE_MODE       : integer range 0 to 1 := c_NO;  --std_IBUF_SECURE_MODE;
      SBUF_VERSION           : integer range 0 to 1 := std_SBUF_VERSION;
      SBUF_VERSION_OBUF      : integer range 0 to 6 := std_SBUF_VERSION;
      OBUF_DATA_COUNT_WIDTH  : integer range 2 to 7 := std_DATA_COUNT_WIDTH;
      USE_ACKNOWLEDGE        : integer range 0 to 1 := std_USE_ACKNOWLEDGE;
      USE_CHECKSUM           : integer range 0 to 1 := c_YES;
      USE_VENDOR_CORES       : integer range 0 to 1 := c_YES;
      INIT_CAN_RECEIVE_DATA  : integer range 0 to 1 := c_YES;
      REPLY_CAN_RECEIVE_DATA : integer range 0 to 1 := c_YES;
      INIT_CAN_SEND_DATA     : integer range 0 to 1 := c_YES;
      REPLY_CAN_SEND_DATA    : integer range 0 to 1 := c_YES
      );
    port(
      --  Misc
      CLK                      : in  std_logic;
      RESET                    : in  std_logic;
      CLK_EN                   : in  std_logic;
      --  Media direction port
      MED_INIT_DATAREADY_OUT   : out std_logic;
      MED_INIT_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_INIT_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_INIT_READ_IN         : in  std_logic;
      MED_REPLY_DATAREADY_OUT  : out std_logic;
      MED_REPLY_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_REPLY_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_REPLY_READ_IN        : in  std_logic;
      MED_DATAREADY_IN         : in  std_logic;
      MED_DATA_IN              : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN        : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_OUT             : out std_logic;
      MED_ERROR_IN             : in  std_logic_vector (2 downto 0);
      -- Internal direction port
      INT_INIT_DATAREADY_OUT   : out std_logic;
      INT_INIT_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_INIT_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_INIT_READ_IN         : in  std_logic;
      INT_INIT_DATAREADY_IN    : in  std_logic;
      INT_INIT_DATA_IN         : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_INIT_PACKET_NUM_IN   : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_INIT_READ_OUT        : out std_logic;
      INT_REPLY_DATAREADY_OUT  : out std_logic;
      INT_REPLY_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_REPLY_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_REPLY_READ_IN        : in  std_logic;
      INT_REPLY_DATAREADY_IN   : in  std_logic;
      INT_REPLY_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_REPLY_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_REPLY_READ_OUT       : out std_logic;
      -- Status and control port
      STAT_GEN                 : out std_logic_vector (31 downto 0);
      STAT_IBUF_BUFFER         : out std_logic_vector (31 downto 0);
      CTRL_GEN                 : in  std_logic_vector (31 downto 0);
      CTRL_OBUF_settings       : in  std_logic_vector (31 downto 0) := (others => '0');
      STAT_INIT_OBUF_DEBUG     : out std_logic_vector (31 downto 0);
      STAT_REPLY_OBUF_DEBUG    : out std_logic_vector (31 downto 0);
      STAT_BUFFER_COUNTER      : out std_logic_vector (31 downto 0);
      STAT_DATA_COUNTER        : out std_logic_vector (31 downto 0);
      TIMER_TICKS_IN           : in  std_logic_vector (1 downto 0);
      CTRL_STAT                : in  std_logic_vector (15 downto 0)
      );
  end component;






  component trb_net16_io_multiplexer is
    generic(
      USE_INPUT_SBUF : multiplexer_config_t := (others => c_NO)
      );
    port(
      --  Misc
      CLK                : in  std_logic;
      RESET              : in  std_logic;
      CLK_EN             : in  std_logic;
      --  Media direction port
      MED_DATAREADY_IN   : in  std_logic;
      MED_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_OUT       : out std_logic;
      MED_DATAREADY_OUT  : out std_logic;
      MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_IN        : in  std_logic;
      -- Internal direction port
      INT_DATA_OUT       : out std_logic_vector (2**(c_MUX_WIDTH-1)*c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_OUT : out std_logic_vector (2**(c_MUX_WIDTH-1)*c_NUM_WIDTH-1 downto 0);
      INT_DATAREADY_OUT  : out std_logic_vector (2**(c_MUX_WIDTH-1)-1 downto 0);
      INT_READ_IN        : in  std_logic_vector (2**(c_MUX_WIDTH-1)-1 downto 0);
      INT_DATAREADY_IN   : in  std_logic_vector (2**c_MUX_WIDTH-1 downto 0);
      INT_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH*(2**c_MUX_WIDTH)-1 downto 0);
      INT_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH*(2**c_MUX_WIDTH)-1 downto 0);
      INT_READ_OUT       : out std_logic_vector (2**c_MUX_WIDTH-1 downto 0);
      -- Status and control port
      CTRL               : in  std_logic_vector (31 downto 0);
      STAT               : out std_logic_vector (31 downto 0)
      );
  end component;





  component trb_net16_ipudata is
    generic(
      DO_CHECKS : integer range c_NO to c_YES := c_YES
      );
    port(
      --  Misc
      CLK                    : in  std_logic;
      RESET                  : in  std_logic;
      CLK_EN                 : in  std_logic;
      -- Port to API
      API_DATA_OUT           : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      API_PACKET_NUM_OUT     : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      API_DATAREADY_OUT      : out std_logic;
      API_READ_IN            : in  std_logic;
      API_SHORT_TRANSFER_OUT : out std_logic;
      API_DTYPE_OUT          : out std_logic_vector (3 downto 0);
      API_ERROR_PATTERN_OUT  : out std_logic_vector (31 downto 0);
      API_SEND_OUT           : out std_logic;
      -- Receiver port
      API_DATA_IN            : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      API_PACKET_NUM_IN      : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      API_TYP_IN             : in  std_logic_vector (2 downto 0);
      API_DATAREADY_IN       : in  std_logic;
      API_READ_OUT           : out std_logic;
      -- APL Control port
      API_RUN_IN             : in  std_logic;
      API_SEQNR_IN           : in  std_logic_vector (7 downto 0);
      API_LENGTH_OUT         : out std_logic_vector (15 downto 0);
      MY_ADDRESS_IN          : in  std_logic_vector (15 downto 0);

      --Information received with request
      IPU_NUMBER_OUT          : out std_logic_vector (15 downto 0);
      IPU_READOUT_TYPE_OUT    : out std_logic_vector (3 downto 0);
      IPU_INFORMATION_OUT     : out std_logic_vector (7 downto 0);
      IPU_CODE_OUT            : out std_logic_vector (7 downto 0);
      --start strobe
      IPU_START_READOUT_OUT   : out std_logic;
      --detector data, equipped with DHDR
      IPU_DATA_IN             : in  std_logic_vector (31 downto 0);
      IPU_DATAREADY_IN        : in  std_logic;
      --no more data, end transfer, send TRM
      IPU_READOUT_FINISHED_IN : in  std_logic;
      --will be low every second cycle due to 32bit -> 16bit conversion
      IPU_READ_OUT            : out std_logic;
      IPU_LENGTH_IN           : in  std_logic_vector (15 downto 0);
      IPU_ERROR_PATTERN_IN    : in  std_logic_vector (31 downto 0);

      STAT_DEBUG : out std_logic_vector(31 downto 0)
      );
  end component;
-- 
-- component trb_net16_gbe_buf is
-- generic(
-- DO_SIMULATION                : integer range 0 to 1 := 1;
-- USE_125MHZ_EXTCLK       : integer range 0 to 1 := 1
-- );
-- port(
-- CLK                                                  : in    std_logic;
-- TEST_CLK                                     : in    std_logic; -- only for simulation!
-- CLK_125_IN                           : in std_logic;  -- gk 28.04.01 used only in internal 125MHz clock mode
-- RESET                                                : in    std_logic;
-- GSR_N                                                : in    std_logic;
-- -- Debug
-- STAGE_STAT_REGS_OUT                  : out   std_logic_vector(31 downto 0);
-- STAGE_CTRL_REGS_IN                   : in    std_logic_vector(31 downto 0);
-- -- configuration interface
-- IP_CFG_START_IN                              : in    std_logic;
-- IP_CFG_BANK_SEL_IN                   : in    std_logic_vector(3 downto 0);
-- IP_CFG_DONE_OUT                              : out   std_logic;
-- IP_CFG_MEM_ADDR_OUT                  : out   std_logic_vector(7 downto 0);
-- IP_CFG_MEM_DATA_IN                   : in    std_logic_vector(31 downto 0);
-- IP_CFG_MEM_CLK_OUT                   : out   std_logic;
-- MR_RESET_IN                                  : in    std_logic;
-- MR_MODE_IN                                   : in    std_logic;
-- MR_RESTART_IN                                : in    std_logic;
-- -- gk 29.03.10
-- SLV_ADDR_IN                  : in std_logic_vector(7 downto 0);
-- SLV_READ_IN                  : in std_logic;
-- SLV_WRITE_IN                 : in std_logic;
-- SLV_BUSY_OUT                 : out std_logic;
-- SLV_ACK_OUT                  : out std_logic;
-- SLV_DATA_IN                  : in std_logic_vector(31 downto 0);
-- SLV_DATA_OUT                 : out std_logic_vector(31 downto 0);
-- -- gk 22.04.10
-- -- registers setup interface
-- BUS_ADDR_IN               : in std_logic_vector(7 downto 0);
-- BUS_DATA_IN               : in std_logic_vector(31 downto 0);
-- BUS_DATA_OUT              : out std_logic_vector(31 downto 0);  -- gk 26.04.10
-- BUS_WRITE_EN_IN           : in std_logic;  -- gk 26.04.10
-- BUS_READ_EN_IN            : in std_logic;  -- gk 26.04.10
-- BUS_ACK_OUT               : out std_logic;  -- gk 26.04.10
-- -- gk 23.04.10
-- LED_PACKET_SENT_OUT          : out std_logic;
-- LED_AN_DONE_N_OUT            : out std_logic;
-- -- CTS interface
-- CTS_NUMBER_IN                                : in    std_logic_vector (15 downto 0);
-- CTS_CODE_IN                                  : in    std_logic_vector (7  downto 0);
-- CTS_INFORMATION_IN                   : in    std_logic_vector (7  downto 0);
-- CTS_READOUT_TYPE_IN                  : in    std_logic_vector (3  downto 0);
-- CTS_START_READOUT_IN         : in    std_logic;
-- CTS_DATA_OUT                         : out   std_logic_vector (31 downto 0);
-- CTS_DATAREADY_OUT                    : out   std_logic;
-- CTS_READOUT_FINISHED_OUT     : out   std_logic;
-- CTS_READ_IN                                  : in    std_logic;
-- CTS_LENGTH_OUT                               : out   std_logic_vector (15 downto 0);
-- CTS_ERROR_PATTERN_OUT                : out   std_logic_vector (31 downto 0);
-- -- Data payload interface
-- FEE_DATA_IN                                  : in    std_logic_vector (15 downto 0);
-- FEE_DATAREADY_IN                     : in    std_logic;
-- FEE_READ_OUT                         : out   std_logic;
-- FEE_STATUS_BITS_IN                   : in    std_logic_vector (31 downto 0);
-- FEE_BUSY_IN                                  : in    std_logic;
-- --SFP Connection
-- SFP_RXD_P_IN                         : in    std_logic;
-- SFP_RXD_N_IN                         : in    std_logic;
-- SFP_TXD_P_OUT                                : out   std_logic;
-- SFP_TXD_N_OUT                                : out   std_logic;
-- SFP_REFCLK_P_IN                              : in    std_logic;
-- SFP_REFCLK_N_IN                              : in    std_logic;
-- SFP_PRSNT_N_IN                               : in    std_logic; -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
-- SFP_LOS_IN                                   : in    std_logic; -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
-- SFP_TXDIS_OUT                                : out   std_logic; -- SFP disable
-- -- debug ports
-- MC_UNIQUE_ID_IN     : in std_logic_vector(63 downto 0);
-- ANALYZER_DEBUG_OUT                   : out   std_logic_vector(63 downto 0)
-- );
-- end component;




  component ipu_dummy is
    port(CLK_IN                    : in  std_logic;  -- 100MHz local clock
          CLEAR_IN                 : in  std_logic;
          RESET_IN                 : in  std_logic;  -- synchronous reset
          -- Slow control signals
          MIN_COUNT_IN             : in  std_logic_vector(15 downto 0);  -- minimum counter value
          MAX_COUNT_IN             : in  std_logic_vector(15 downto 0);  -- maximum counter value
          CTRL_IN                  : in  std_logic_vector(7 downto 0);  -- control bits from slow control
          -- IPU channel connections
          IPU_NUMBER_IN            : in  std_logic_vector(15 downto 0);  -- trigger tag
          IPU_INFORMATION_IN       : in  std_logic_vector(7 downto 0);  -- trigger information
          IPU_START_READOUT_IN     : in  std_logic;  -- gimme data!
          IPU_DATA_OUT             : out std_logic_vector(31 downto 0);  -- detector data, equipped with DHDR
          IPU_DATAREADY_OUT        : out std_logic;  -- data is valid
          IPU_READOUT_FINISHED_OUT : out std_logic;  -- no more data, end transfer, send TRM
          IPU_READ_IN              : in  std_logic;  -- read strobe, low every second cycle
          IPU_LENGTH_OUT           : out std_logic_vector(15 downto 0);  -- length of data packet (32bit words) (?)
          IPU_ERROR_PATTERN_OUT    : out std_logic_vector(31 downto 0);  -- error pattern
          -- DHDR buffer
          LVL1_FIFO_RD_OUT         : out std_logic;
          LVL1_FIFO_EMPTY_IN       : in  std_logic;
          LVL1_FIFO_NUMBER_IN      : in  std_logic_vector(15 downto 0);
          LVL1_FIFO_CODE_IN        : in  std_logic_vector(7 downto 0);
          LVL1_FIFO_INFORMATION_IN : in  std_logic_vector(7 downto 0);
          LVL1_FIFO_TYPE_IN        : in  std_logic_vector(3 downto 0);
          -- Debug signals
          DBG_BSM_OUT              : out std_logic_vector(7 downto 0);
          DBG_OUT                  : out std_logic_vector(31 downto 0)
          );
  end component;





  component trb_net16_lsm_sfp is
    generic(
      CHECK_FOR_CV      : integer := c_YES;
      HIGHSPEED_STARTUP : integer := c_NO
      );
    port(
      SYSCLK          : in  std_logic;  -- fabric clock
      RESET           : in  std_logic;  -- synchronous reset
      CLEAR           : in  std_logic;  -- asynchronous reset, connect to '0' if not needed / available
      -- status signals
      SFP_MISSING_IN  : in  std_logic;  -- SFP Present ('0' = no SFP mounted, '1' = SFP in place)
      SFP_LOS_IN      : in  std_logic;  -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
      SD_LINK_OK_IN   : in  std_logic;  -- SerDes Link OK ('0' = not linked, '1' link established)
      SD_LOS_IN       : in  std_logic;  -- SerDes Loss Of Signal ('0' = OK, '1' = signal lost)
      SD_TXCLK_BAD_IN : in  std_logic;  -- SerDes Tx Clock locked ('0' = locked, '1' = not locked)
      SD_RXCLK_BAD_IN : in  std_logic;  -- SerDes Rx Clock locked ('0' = locked, '1' = not locked)
      SD_RETRY_IN     : in  std_logic;  -- '0' = handle byte swapping in logic, '1' = simply restart link and hope
      SD_ALIGNMENT_IN : in  std_logic_vector(1 downto 0);  -- SerDes Byte alignment ("10" = swapped, "01" = correct)
      SD_CV_IN        : in  std_logic_vector(1 downto 0);  -- SerDes Code Violation ("00" = OK, everything else = BAD)
      -- control signals
      FULL_RESET_OUT  : out std_logic;  -- full reset AKA quad_reset
      LANE_RESET_OUT  : out std_logic;  -- partial reset AKA lane_reset
      TX_ALLOW_OUT    : out std_logic;  -- allow normal transmit operation
      RX_ALLOW_OUT    : out std_logic;  -- allow normal receive operation
      SWAP_BYTES_OUT  : out std_logic;  -- bytes need swapping ('0' = correct order, '1' = swapped order)
      -- debug signals
      STAT_OP         : out std_logic_vector(15 downto 0);
      CTRL_OP         : in  std_logic_vector(15 downto 0);
      STAT_DEBUG      : out std_logic_vector(31 downto 0)
      );
  end component;








  component trb_net16_med_8_SDR_OS is
    generic(
      TRANSMISSION_CLOCK_DIV : integer range 1 to 10 := 1
      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      INT_DATAREADY_OUT  : out std_logic;
      INT_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_READ_IN        : in  std_logic;

      INT_DATAREADY_IN  : in  std_logic;
      INT_DATA_IN       : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_IN : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_READ_OUT      : out std_logic;

      --  Media direction port
      TX_DATA_OUT : out std_logic_vector (7 downto 0);
      TX_CLK_OUT  : out std_logic;
      TX_CTRL_OUT : out std_logic_vector (1 downto 0);
      RX_DATA_IN  : in  std_logic_vector (7 downto 0);
      RX_CLK_IN   : in  std_logic;
      RX_CTRL_IN  : in  std_logic_vector (1 downto 0);

      -- Status and control port
      STAT_OP : out std_logic_vector (15 downto 0);
      CTRL_OP : in  std_logic_vector (15 downto 0);

      STAT : out std_logic_vector (31 downto 0);
      CTRL : in  std_logic_vector (31 downto 0)
      );
  end component;







  component trb_net16_med_ecp_fot is
    port(
      CLK    : in std_logic;
      CLK_25 : in std_logic;
      CLK_EN : in std_logic;
      RESET  : in std_logic;
      CLEAR  : in std_logic;

      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic;
      MED_READ_OUT       : out std_logic;
      MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic;
      MED_READ_IN        : in  std_logic;

      --SFP Connection
      TXP : out std_logic;
      TXN : out std_logic;
      RXP : in  std_logic;
      RXN : in  std_logic;
      SD  : in  std_logic;

      -- Status and control port
      RX_CLOCK_OUT : out std_logic;
      STAT_OP      : out std_logic_vector (15 downto 0);
      CTRL_OP      : in  std_logic_vector (15 downto 0);
      STAT_REG_OUT : out std_logic_vector(127 downto 0);
      STAT_DEBUG   : out std_logic_vector (63 downto 0);
      CTRL_DEBUG   : in  std_logic_vector (15 downto 0)
      );
  end component;








  component trb_net16_med_ecp_fot_4 is
    generic(
      REVERSE_ORDER : integer range 0 to 1 := c_NO
      --  USED_PORTS : std_logic-vector(3 downto 0) := "1111"
      );
    port(
      CLK                : in  std_logic;
      CLK_25             : in  std_logic;
      CLK_EN             : in  std_logic;
      RESET              : in  std_logic;
      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH*4-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH*4-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic_vector(3 downto 0);
      MED_READ_OUT       : out std_logic_vector(3 downto 0);
      MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH*4-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH*4-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic_vector(3 downto 0);
      MED_READ_IN        : in  std_logic_vector(3 downto 0);
      --SFP Connection
      TXP                : out std_logic_vector(3 downto 0);
      TXN                : out std_logic_vector(3 downto 0);
      RXP                : in  std_logic_vector(3 downto 0);
      RXN                : in  std_logic_vector(3 downto 0);
      SD                 : in  std_logic_vector(3 downto 0);
      -- Status and control port
      STAT_OP            : out std_logic_vector (63 downto 0);
      CTRL_OP            : in  std_logic_vector (63 downto 0);
      STAT_REG_OUT       : out std_logic_vector(127 downto 0);
      STAT_DEBUG         : out std_logic_vector (255 downto 0);
      CTRL_DEBUG         : in  std_logic_vector (63 downto 0)
      );
  end component;





  component trb_net16_med_ecp_fot_4_ctc is
    generic(
      REVERSE_ORDER : integer range 0 to 1 := c_NO
      --  USED_PORTS : std_logic-vector(3 downto 0) := "1111"
      );
    port(
      CLK                : in  std_logic;
      CLK_25             : in  std_logic;
      CLK_EN             : in  std_logic;
      RESET              : in  std_logic;
      CLEAR              : in  std_logic;
      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH*4-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH*4-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic_vector(3 downto 0);
      MED_READ_OUT       : out std_logic_vector(3 downto 0);
      MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH*4-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH*4-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic_vector(3 downto 0);
      MED_READ_IN        : in  std_logic_vector(3 downto 0);

      --SFP Connection
      TXP : out std_logic_vector(3 downto 0);
      TXN : out std_logic_vector(3 downto 0);
      RXP : in  std_logic_vector(3 downto 0);
      RXN : in  std_logic_vector(3 downto 0);
      SD  : in  std_logic_vector(3 downto 0);

      -- Status and control port
      STAT_OP      : out std_logic_vector (63 downto 0);
      CTRL_OP      : in  std_logic_vector (63 downto 0);
      STAT_REG_OUT : out std_logic_vector (511 downto 0);
      STAT_DEBUG   : out std_logic_vector (255 downto 0);
      CTRL_DEBUG   : in  std_logic_vector (63 downto 0)
      );
  end component;





  component trb_net16_med_ecp_sfp is
    generic(
      SERDES_NUM : integer range 0 to 3 := 0;
      EXT_CLOCK  : integer range 0 to 1 := c_NO
      );
    port(
      CLK                : in  std_logic;  -- SerDes clock
      SYSCLK             : in  std_logic;  -- fabric clock
      RESET              : in  std_logic;  -- synchronous reset
      CLEAR              : in  std_logic;  -- asynchronous reset
      CLK_EN             : in  std_logic;
      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic;
      MED_READ_OUT       : out std_logic;
      MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic;
      MED_READ_IN        : in  std_logic;
      REFCLK2CORE_OUT    : out std_logic;
      --SFP Connection
      SD_RXD_P_IN        : in  std_logic;
      SD_RXD_N_IN        : in  std_logic;
      SD_TXD_P_OUT       : out std_logic;
      SD_TXD_N_OUT       : out std_logic;
      SD_REFCLK_P_IN     : in  std_logic;
      SD_REFCLK_N_IN     : in  std_logic;
      SD_PRSNT_N_IN      : in  std_logic;  -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
      SD_LOS_IN          : in  std_logic;  -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
      SD_TXDIS_OUT       : out std_logic;  -- SFP disable
      -- Status and control port
      STAT_OP            : out std_logic_vector (15 downto 0);
      CTRL_OP            : in  std_logic_vector (15 downto 0);
      STAT_DEBUG         : out std_logic_vector (63 downto 0);
      CTRL_DEBUG         : in  std_logic_vector (63 downto 0)
      );
  end component;





  component trb_net16_med_ecp_sfp_gbe is
    generic(
      SERDES_NUM  : integer range 0 to 3 := 0;
      EXT_CLOCK   : integer range 0 to 1 := c_NO;
      USE_200_MHZ : integer range 0 to 1 := c_NO
      );
    port(
      CLK                : in  std_logic;  -- SerDes clock
      SYSCLK             : in  std_logic;  -- fabric clock
      RESET              : in  std_logic;  -- synchronous reset
      CLEAR              : in  std_logic;  -- asynchronous reset
      CLK_EN             : in  std_logic;
      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic;
      MED_READ_OUT       : out std_logic;
      MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic;
      MED_READ_IN        : in  std_logic;
      REFCLK2CORE_OUT    : out std_logic;
      --SFP Connection
      SD_RXD_P_IN        : in  std_logic;
      SD_RXD_N_IN        : in  std_logic;
      SD_TXD_P_OUT       : out std_logic;
      SD_TXD_N_OUT       : out std_logic;
      SD_REFCLK_P_IN     : in  std_logic;
      SD_REFCLK_N_IN     : in  std_logic;
      SD_PRSNT_N_IN      : in  std_logic;  -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
      SD_LOS_IN          : in  std_logic;  -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
      SD_TXDIS_OUT       : out std_logic;  -- SFP disable
      -- Status and control port
      STAT_OP            : out std_logic_vector (15 downto 0);
      CTRL_OP            : in  std_logic_vector (15 downto 0);
      STAT_DEBUG         : out std_logic_vector (63 downto 0);
      CTRL_DEBUG         : in  std_logic_vector (63 downto 0)
      );
  end component;




  component trb_net16_med_ecp_sfp_4 is
    generic(
      REVERSE_ORDER : integer range 0 to 1 := c_NO
      --  USED_PORTS : std_logic-vector(3 downto 0) := "1111"
      );
    port(
      CLK                : in  std_logic;  -- SerDes clock
      SYSCLK             : in  std_logic;  -- fabric clock
      RESET              : in  std_logic;  -- synchronous reset
      CLEAR              : in  std_logic;  -- asynchronous reset
      CLK_EN             : in  std_logic;
      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic_vector(3 downto 0);
      MED_READ_OUT       : out std_logic_vector(3 downto 0);
      MED_DATA_OUT       : out std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic_vector(3 downto 0);
      MED_READ_IN        : in  std_logic_vector(3 downto 0);
      REFCLK2CORE_OUT    : out std_logic;
      --SFP Connection
      SD_RXD_P_IN        : in  std_logic_vector(3 downto 0);
      SD_RXD_N_IN        : in  std_logic_vector(3 downto 0);
      SD_TXD_P_OUT       : out std_logic_vector(3 downto 0);
      SD_TXD_N_OUT       : out std_logic_vector(3 downto 0);
      SD_REFCLK_P_IN     : in  std_logic;
      SD_REFCLK_N_IN     : in  std_logic;
      SD_PRSNT_N_IN      : in  std_logic_vector(3 downto 0);
      SD_LOS_IN          : in  std_logic_vector(3 downto 0);
      SD_TXDIS_OUT       : out std_logic_vector(3 downto 0);
      -- Status and control port
      STAT_OP            : out std_logic_vector (4*16-1 downto 0);
      CTRL_OP            : in  std_logic_vector (4*16-1 downto 0);
      STAT_DEBUG         : out std_logic_vector (63 downto 0);
      CTRL_DEBUG         : in  std_logic_vector (63 downto 0)
      );
  end component;



  component trb_net16_med_ecp_sfp_4_gbe is
    generic(
      REVERSE_ORDER : integer range 0 to 1 := c_NO
      --  USED_PORTS : std_logic-vector(3 downto 0) := "1111"
      );
    port(
      CLK                : in  std_logic;  -- SerDes clock
      SYSCLK             : in  std_logic;  -- fabric clock
      RESET              : in  std_logic;  -- synchronous reset
      CLEAR              : in  std_logic;  -- asynchronous reset
      CLK_EN             : in  std_logic;
      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic_vector(3 downto 0);
      MED_READ_OUT       : out std_logic_vector(3 downto 0);
      MED_DATA_OUT       : out std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic_vector(3 downto 0);
      MED_READ_IN        : in  std_logic_vector(3 downto 0);
      REFCLK2CORE_OUT    : out std_logic;
      --SFP Connection
      SD_RXD_P_IN        : in  std_logic_vector(3 downto 0);
      SD_RXD_N_IN        : in  std_logic_vector(3 downto 0);
      SD_TXD_P_OUT       : out std_logic_vector(3 downto 0);
      SD_TXD_N_OUT       : out std_logic_vector(3 downto 0);
      SD_REFCLK_P_IN     : in  std_logic;
      SD_REFCLK_N_IN     : in  std_logic;
      SD_PRSNT_N_IN      : in  std_logic_vector(3 downto 0);
      SD_LOS_IN          : in  std_logic_vector(3 downto 0);
      SD_TXDIS_OUT       : out std_logic_vector(3 downto 0);
      -- Status and control port
      STAT_OP            : out std_logic_vector (4*16-1 downto 0);
      CTRL_OP            : in  std_logic_vector (4*16-1 downto 0);
      STAT_DEBUG         : out std_logic_vector (63 downto 0);
      CTRL_DEBUG         : in  std_logic_vector (63 downto 0)
      );
  end component;


  component trb_net16_med_ecp3_sfp is
    generic(
      SERDES_NUM  : integer range 0 to 3 := 0;
      EXT_CLOCK   : integer range 0 to 1 := c_NO;
      USE_200_MHZ : integer range 0 to 1 := c_YES;
      USE_125_MHZ : integer range 0 to 1 := c_NO;
      USE_CTC     : integer range 0 to 1 := c_YES;
      USE_SLAVE   : integer range 0 to 1 := c_NO
      );
    port(
      CLK                : in  std_logic;  -- SerDes clock
      SYSCLK             : in  std_logic;  -- fabric clock
      RESET              : in  std_logic;  -- synchronous reset
      CLEAR              : in  std_logic;  -- asynchronous reset
      CLK_EN             : in  std_logic;
      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic;
      MED_READ_OUT       : out std_logic;
      MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic;
      MED_READ_IN        : in  std_logic;
      REFCLK2CORE_OUT    : out std_logic;
      CLK_RX_HALF_OUT    : out std_logic;
      CLK_RX_FULL_OUT    : out std_logic;

      --SFP Connection
      SD_RXD_P_IN    : in  std_logic;
      SD_RXD_N_IN    : in  std_logic;
      SD_TXD_P_OUT   : out std_logic;
      SD_TXD_N_OUT   : out std_logic;
      SD_REFCLK_P_IN : in  std_logic;
      SD_REFCLK_N_IN : in  std_logic;
      SD_PRSNT_N_IN  : in  std_logic;  -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
      SD_LOS_IN      : in  std_logic;  -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
      SD_TXDIS_OUT   : out std_logic;   -- SFP disable
      --Control Interface
      SCI_DATA_IN    : in  std_logic_vector(7 downto 0) := (others => '0');
      SCI_DATA_OUT   : out std_logic_vector(7 downto 0) := (others => '0');
      SCI_ADDR       : in  std_logic_vector(8 downto 0) := (others => '0');
      SCI_READ       : in  std_logic                    := '0';
      SCI_WRITE      : in  std_logic                    := '0';
      SCI_ACK        : out std_logic                    := '0';
      -- Status and control port
      STAT_OP        : out std_logic_vector (15 downto 0);
      CTRL_OP        : in  std_logic_vector (15 downto 0);
      STAT_DEBUG     : out std_logic_vector (63 downto 0);
      CTRL_DEBUG     : in  std_logic_vector (63 downto 0)
      );
  end component;

  component trb_net16_med_ecp3_sfp_4_onboard is
    generic(
      REVERSE_ORDER : integer range 0 to 1     := c_NO;
      FREQUENCY     : integer range 125 to 200 := 200
--  USED_PORTS : std_logic-vector(3 downto 0) := "1111"
      );
    port(
      CLK                : in  std_logic;  -- SerDes clock
      SYSCLK             : in  std_logic;  -- fabric clock
      RESET              : in  std_logic;  -- synchronous reset
      CLEAR              : in  std_logic;  -- asynchronous reset
      CLK_EN             : in  std_logic;
      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic_vector(3 downto 0);
      MED_READ_OUT       : out std_logic_vector(3 downto 0);
      MED_DATA_OUT       : out std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic_vector(3 downto 0);
      MED_READ_IN        : in  std_logic_vector(3 downto 0);
      REFCLK2CORE_OUT    : out std_logic;
      --SFP Connection
      SD_RXD_P_IN        : in  std_logic_vector(3 downto 0);
      SD_RXD_N_IN        : in  std_logic_vector(3 downto 0);
      SD_TXD_P_OUT       : out std_logic_vector(3 downto 0);
      SD_TXD_N_OUT       : out std_logic_vector(3 downto 0);
      SD_REFCLK_P_IN     : in  std_logic;
      SD_REFCLK_N_IN     : in  std_logic;
      SD_PRSNT_N_IN      : in  std_logic_vector(3 downto 0);  -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
      SD_LOS_IN          : in  std_logic_vector(3 downto 0);  -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
      SD_TXDIS_OUT       : out std_logic_vector(3 downto 0);  -- SFP disable
      --Control Interface
      SCI_DATA_IN        : in  std_logic_vector(7 downto 0) := (others => '0');
      SCI_DATA_OUT       : out std_logic_vector(7 downto 0) := (others => '0');
      SCI_ADDR           : in  std_logic_vector(8 downto 0) := (others => '0');
      SCI_READ           : in  std_logic                    := '0';
      SCI_WRITE          : in  std_logic                    := '0';
      SCI_ACK            : out std_logic                    := '0';
      -- Status and control port
      STAT_OP            : out std_logic_vector (4*16-1 downto 0);
      CTRL_OP            : in  std_logic_vector (4*16-1 downto 0);
      STAT_DEBUG         : out std_logic_vector (64*4-1 downto 0);
      CTRL_DEBUG         : in  std_logic_vector (63 downto 0)
      );
  end component;


  component trb_net16_med_ecp3_sfp_4 is
    generic(
      REVERSE_ORDER : integer range 0 to 1     := c_NO;
      FREQUENCY     : integer range 125 to 200 := 200         --200 or 125
      --  USED_PORTS : std_logic-vector(3 downto 0) := "1111"
      );
    port(
      CLK                : in  std_logic;  -- SerDes clock
      SYSCLK             : in  std_logic;  -- fabric clock
      RESET              : in  std_logic;  -- synchronous reset
      CLEAR              : in  std_logic;  -- asynchronous reset
      CLK_EN             : in  std_logic;
      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic_vector(3 downto 0);
      MED_READ_OUT       : out std_logic_vector(3 downto 0);
      MED_DATA_OUT       : out std_logic_vector(4*c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(4*c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic_vector(3 downto 0);
      MED_READ_IN        : in  std_logic_vector(3 downto 0);
      REFCLK2CORE_OUT    : out std_logic;
      --SFP Connection
      SD_RXD_P_IN        : in  std_logic_vector(3 downto 0);
      SD_RXD_N_IN        : in  std_logic_vector(3 downto 0);
      SD_TXD_P_OUT       : out std_logic_vector(3 downto 0);
      SD_TXD_N_OUT       : out std_logic_vector(3 downto 0);
      SD_REFCLK_P_IN     : in  std_logic;
      SD_REFCLK_N_IN     : in  std_logic;
      SD_PRSNT_N_IN      : in  std_logic_vector(3 downto 0);  -- SFP Present ('0' = SFP in place, '1' = no SFP mounted)
      SD_LOS_IN          : in  std_logic_vector(3 downto 0);  -- SFP Loss Of Signal ('0' = OK, '1' = no signal)
      SD_TXDIS_OUT       : out std_logic_vector(3 downto 0);  -- SFP disable
      --Control Interface
      SCI_DATA_IN        : in  std_logic_vector(7 downto 0) := (others => '0');
      SCI_DATA_OUT       : out std_logic_vector(7 downto 0) := (others => '0');
      SCI_ADDR           : in  std_logic_vector(8 downto 0) := (others => '0');
      SCI_READ           : in  std_logic                    := '0';
      SCI_WRITE          : in  std_logic                    := '0';
      SCI_ACK            : out std_logic                    := '0';
      -- Status and control port
      STAT_OP            : out std_logic_vector (4*16-1 downto 0);
      CTRL_OP            : in  std_logic_vector (4*16-1 downto 0);
      STAT_DEBUG         : out std_logic_vector (64*4-1 downto 0);
      CTRL_DEBUG         : in  std_logic_vector (63 downto 0)
      );
  end component;


  component trb_net16_med_16_CC is
    port(
      CLK    : in std_logic;
      CLK_EN : in std_logic;
      RESET  : in std_logic;

      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic;
      MED_READ_OUT       : out std_logic;
      MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic;
      MED_READ_IN        : in  std_logic;

      DATA_OUT       : out std_logic_vector(15 downto 0);
      DATA_VALID_OUT : out std_logic;
      DATA_CTRL_OUT  : out std_logic;
      DATA_IN        : in  std_logic_vector(15 downto 0);
      DATA_VALID_IN  : in  std_logic;
      DATA_CTRL_IN   : in  std_logic;

      STAT_OP    : out std_logic_vector(15 downto 0);
      CTRL_OP    : in  std_logic_vector(15 downto 0);
      STAT_DEBUG : out std_logic_vector(63 downto 0)
      );
  end component;




  component trb_net16_med_16_IC is
    generic(
      DATA_CLK_OUT_PHASE : std_logic := '1'
      );
    port(
      CLK    : in std_logic;
      CLK_EN : in std_logic;
      RESET  : in std_logic;

      --Internal Connection
      MED_DATA_IN        : in  std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_IN   : in  std_logic;
      MED_READ_OUT       : out std_logic;
      MED_DATA_OUT       : out std_logic_vector(c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic;
      MED_READ_IN        : in  std_logic;

      DATA_OUT       : out std_logic_vector(15 downto 0);
      DATA_VALID_OUT : out std_logic;
      DATA_CTRL_OUT  : out std_logic;
      DATA_CLK_OUT   : out std_logic;
      DATA_IN        : in  std_logic_vector(15 downto 0);
      DATA_VALID_IN  : in  std_logic;
      DATA_CTRL_IN   : in  std_logic;
      DATA_CLK_IN    : in  std_logic;

      STAT_OP    : out std_logic_vector(15 downto 0);
      CTRL_OP    : in  std_logic_vector(15 downto 0);
      STAT_DEBUG : out std_logic_vector(63 downto 0)
      );
  end component;




  component trb_net16_med_tlk is
    port (
      RESET              : in  std_logic;
      CLK                : in  std_logic;
      TLK_CLK            : in  std_logic;
      TLK_ENABLE         : out std_logic;
      TLK_LCKREFN        : out std_logic;
      TLK_LOOPEN         : out std_logic;
      TLK_PRBSEN         : out std_logic;
      TLK_RXD            : in  std_logic_vector(15 downto 0);
      TLK_RX_CLK         : in  std_logic;
      TLK_RX_DV          : in  std_logic;
      TLK_RX_ER          : in  std_logic;
      TLK_TXD            : out std_logic_vector(15 downto 0);
      TLK_TX_EN          : out std_logic;
      TLK_TX_ER          : out std_logic;
      SFP_LOS            : in  std_logic;
      SFP_TX_DIS         : out std_logic;
      MED_DATAREADY_IN   : in  std_logic;
      MED_READ_IN        : in  std_logic;
      MED_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_DATAREADY_OUT  : out std_logic;
      MED_READ_OUT       : out std_logic;
      MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      STAT               : out std_logic_vector (63 downto 0);
      STAT_MONITOR       : out std_logic_vector (100 downto 0);
      STAT_OP            : out std_logic_vector (15 downto 0);
      CTRL_OP            : in  std_logic_vector (15 downto 0)
      --connect STAT(0) to LED
      );
  end component;





  component trb_net_onewire is
    generic(
      USE_TEMPERATURE_READOUT : integer range 0 to 1 := 1;
      PARASITIC_MODE          : integer range 0 to 1 := c_NO;
      CLK_PERIOD              : integer              := 10  --clk period in ns
      );
    port(
      CLK               : in    std_logic;
      RESET             : in    std_logic;
      READOUT_ENABLE_IN : in    std_logic := '1';
      --connection to 1-wire interface
      ONEWIRE           : inout std_logic;
      MONITOR_OUT       : out   std_logic;
      --connection to id ram, according to memory map in TrbNetRegIO
      DATA_OUT          : out   std_logic_vector(15 downto 0);
      ADDR_OUT          : out   std_logic_vector(2 downto 0);
      WRITE_OUT         : out   std_logic;
      TEMP_OUT          : out   std_logic_vector(11 downto 0);
      ID_OUT            : out   std_logic_vector(63 downto 0);
      STAT              : out   std_logic_vector(31 downto 0)
      );
  end component;






  component trb_net_onewire_listener is
    port(
      CLK        : in  std_logic;
      CLK_EN     : in  std_logic;
      RESET      : in  std_logic;
      MONITOR_IN : in  std_logic;
      DATA_OUT   : out std_logic_vector(15 downto 0);
      ADDR_OUT   : out std_logic_vector(2 downto 0);
      WRITE_OUT  : out std_logic;
      TEMP_OUT   : out std_logic_vector(11 downto 0);
      ID_OUT     : out std_logic_vector(63 downto 0);
      STAT       : out std_logic_vector(31 downto 0)
      );
  end component;






  component trb_net16_obuf is
    generic (
      DATA_COUNT_WIDTH : integer              := 5;
      USE_ACKNOWLEDGE  : integer range 0 to 1 := std_USE_ACKNOWLEDGE;
      USE_CHECKSUM     : integer range 0 to 1 := c_YES;
      SBUF_VERSION     : integer range 0 to 6 := std_SBUF_VERSION
      );
    port(
      --  Misc
      CLK                : in  std_logic;
      RESET              : in  std_logic;
      CLK_EN             : in  std_logic;
      --  Media direction port
      MED_DATAREADY_OUT  : out std_logic;
      MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_IN        : in  std_logic;
      -- Internal direction port
      INT_DATAREADY_IN   : in  std_logic;
      INT_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_IN  : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_READ_OUT       : out std_logic;
      -- Status and control port
      STAT_BUFFER        : out std_logic_vector (31 downto 0);
      CTRL_BUFFER        : in  std_logic_vector (31 downto 0);
      CTRL_SETTINGS      : in  std_logic_vector (15 downto 0);
      STAT_DEBUG         : out std_logic_vector (31 downto 0);
      TIMER_TICKS_IN     : in  std_logic_vector (1 downto 0)
      );
  end component;








  component trb_net16_obuf_nodata is
    port(
      --  Misc
      CLK                : in  std_logic;
      RESET              : in  std_logic;
      CLK_EN             : in  std_logic;
      --  Media direction port
      MED_DATAREADY_OUT  : out std_logic;
      MED_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_IN        : in  std_logic;
      --STAT
      STAT_BUFFER        : out std_logic_vector (31 downto 0);
      CTRL_BUFFER        : in  std_logic_vector (31 downto 0);
      STAT_DEBUG         : out std_logic_vector (31 downto 0)
      );
  end component;




  component pll_in100_out100 is
    port (
      CLK   : in  std_logic;
      CLKOP : out std_logic;
      CLKOS : out std_logic;
      LOCK  : out std_logic
      );
  end component;



  component pll_in100_out20 is
    port (
      CLK   : in  std_logic;
      CLKOP : out std_logic;
      LOCK  : out std_logic
      );
  end component;


  component pll_in200_out100 is
    port (
      RESET : in  std_logic := '0';
      CLK   : in  std_logic;
      CLKOP : out std_logic;
      CLKOK : out std_logic;
      CLKOS : out std_logic;
      LOCK  : out std_logic
      );
  end component;


  component pll_in100_out25 is
    port (
      CLK   : in  std_logic;
      CLKOP : out std_logic;
      LOCK  : out std_logic
      );
  end component;


  component pll25 is
    port(
      CLK   : in  std_logic;
      RESET : in  std_logic;
      CLKOP : out std_logic;
      CLKOK : out std_logic;
      LOCK  : out std_logic
      );
  end component;






  component pll_in25_out100 is
    port (
      CLK   : in  std_logic;
      CLKOP : out std_logic;
      LOCK  : out std_logic
      );
  end component;






  component trb_net_pattern_gen is
    generic (
      WIDTH : integer := 6
      );
    port(
      INPUT_IN   : in  std_logic_vector (WIDTH-1 downto 0);
      RESULT_OUT : out std_logic_vector (2**WIDTH-1 downto 0)
      );
  end component;



  component priority_arbiter is
    generic(
      INPUT_WIDTH : integer := 8
      );
    port(
      CLK        : in  std_logic;
      ENABLE     : in  std_logic;
      INPUT      : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
      OUTPUT_VEC : out std_logic_vector(INPUT_WIDTH-1 downto 0);
      OUTPUT_NUM : out integer range 0 to INPUT_WIDTH-1
      );
  end component;



  component trb_net_priority_arbiter is
    generic (
      WIDTH : integer := 2
      );
    port(
      --  Misc
      CLK        : in  std_logic;
      RESET      : in  std_logic;
      CLK_EN     : in  std_logic;
      INPUT_IN   : in  std_logic_vector (WIDTH-1 downto 0);
      RESULT_OUT : out std_logic_vector (WIDTH-1 downto 0);
      ENABLE     : in  std_logic;
      CTRL       : in  std_logic_vector (9 downto 0)
      );
  end component;



  component pulse_sync is
    port(
      CLK_A_IN    : in  std_logic;
      RESET_A_IN  : in  std_logic;
      PULSE_A_IN  : in  std_logic;
      CLK_B_IN    : in  std_logic;
      RESET_B_IN  : in  std_logic;
      PULSE_B_OUT : out std_logic
      );
  end component;



  component ram_dp is
    generic(
      depth : integer := 3;
      width : integer := 16
      );
    port(
      CLK   : in  std_logic;
      wr1   : in  std_logic;
      a1    : in  std_logic_vector(depth-1 downto 0);
      dout1 : out std_logic_vector(width-1 downto 0);
      din1  : in  std_logic_vector(width-1 downto 0);
      a2    : in  std_logic_vector(depth-1 downto 0);
      dout2 : out std_logic_vector(width-1 downto 0)
      );
  end component;




  component ram_dp_rw
    generic(
      depth : integer := 3;
      width : integer := 16
      );
    port(
      CLK   : in  std_logic;
      wr1   : in  std_logic;
      a1    : in  std_logic_vector(depth-1 downto 0);
      din1  : in  std_logic_vector(width-1 downto 0);
      a2    : in  std_logic_vector(depth-1 downto 0);
      dout2 : out std_logic_vector(width-1 downto 0)
      );
  end component;




  component trb_net16_regIO is
    generic (
      NUM_STAT_REGS     : integer range 0 to 6                   := 4;  --log2 of number of status registers
      NUM_CTRL_REGS     : integer range 0 to 6                   := 3;  --log2 of number of ctrl registers
      --standard values for output registers
      INIT_CTRL_REGS    : std_logic_vector(2**(4)*32-1 downto 0) := (others => '0');
      --set to 0 for unused ctrl registers to save resources
      USED_CTRL_REGS    : std_logic_vector(2**(4)-1 downto 0)    := (others => '1');
      --set to 0 for each unused bit in a register
      USED_CTRL_BITMASK : std_logic_vector(2**(4)*32-1 downto 0) := (others => '1');
      USE_DAT_PORT      : integer range 0 to 1                   := c_YES;  --internal data port
      INIT_ADDRESS      : std_logic_vector(15 downto 0)          := x"FFFF";
      INIT_UNIQUE_ID    : std_logic_vector(63 downto 0)          := x"1000_2000_3654_4876";
      INIT_BOARD_INFO   : std_logic_vector(31 downto 0)          := x"1111_2222";
      INIT_ENDPOINT_ID  : std_logic_vector(15 downto 0)          := x"0001";
      COMPILE_TIME      : std_logic_vector(31 downto 0)          := x"00000000";
      COMPILE_VERSION   : std_logic_vector(15 downto 0)          := x"0001";
      HARDWARE_VERSION  : std_logic_vector(31 downto 0)          := x"12345678";
      CLOCK_FREQ        : integer range 1 to 200                 := 100  --MHz
      );
    port(
--  Misc
      CLK                    : in  std_logic;
      RESET                  : in  std_logic;
      CLK_EN                 : in  std_logic;
-- Port to API
      API_DATA_OUT           : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      API_PACKET_NUM_OUT     : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      API_DATAREADY_OUT      : out std_logic;
      API_READ_IN            : in  std_logic;
      API_SHORT_TRANSFER_OUT : out std_logic;
      API_DTYPE_OUT          : out std_logic_vector (3 downto 0);
      API_ERROR_PATTERN_OUT  : out std_logic_vector (31 downto 0);
      API_SEND_OUT           : out std_logic;
      -- Receiver port
      API_DATA_IN            : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      API_PACKET_NUM_IN      : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      API_TYP_IN             : in  std_logic_vector (2 downto 0);
      API_DATAREADY_IN       : in  std_logic;
      API_READ_OUT           : out std_logic;
      -- APL Control port
      API_RUN_IN             : in  std_logic;
      API_SEQNR_IN           : in  std_logic_vector (7 downto 0);

      --Port to write Unique ID (-> 1-wire)
      IDRAM_DATA_IN  : in  std_logic_vector(15 downto 0);
      IDRAM_DATA_OUT : out std_logic_vector(15 downto 0);
      IDRAM_ADDR_IN  : in  std_logic_vector(2 downto 0);
      IDRAM_WR_IN    : in  std_logic;

      --Informations
      MY_ADDRESS_OUT      : out std_logic_vector(15 downto 0);
      TRIGGER_MONITOR     : in  std_logic;
      GLOBAL_TIME         : out std_logic_vector(31 downto 0);  --global time, microseconds
      LOCAL_TIME          : out std_logic_vector(7 downto 0);  --local time running with chip frequency
      TIME_SINCE_LAST_TRG : out std_logic_vector(31 downto 0);  --local time, resetted with each trigger
      TIMER_US_TICK       : out std_logic;  --1 tick every microsecond
      TIMER_MS_TICK       : out std_logic;  --1 tick every 1024 microseconds

--Common Register in / out
      COMMON_STAT_REG_IN     : in  std_logic_vector(std_COMSTATREG*c_REGIO_REG_WIDTH-1 downto 0);
      COMMON_CTRL_REG_OUT    : out std_logic_vector(std_COMCTRLREG*c_REGIO_REG_WIDTH-1 downto 0);
--Custom Register in / out
      REGISTERS_IN           : in  std_logic_vector(c_REGIO_REG_WIDTH*2**(NUM_STAT_REGS)-1 downto 0);
      REGISTERS_OUT          : out std_logic_vector(c_REGIO_REG_WIDTH*2**(NUM_CTRL_REGS)-1 downto 0);
      COMMON_STAT_REG_STROBE : out std_logic_vector((std_COMSTATREG)-1 downto 0);
      COMMON_CTRL_REG_STROBE : out std_logic_vector((std_COMCTRLREG)-1 downto 0);
      STAT_REG_STROBE        : out std_logic_vector(2**(NUM_STAT_REGS)-1 downto 0);
      CTRL_REG_STROBE        : out std_logic_vector(2**(NUM_CTRL_REGS)-1 downto 0);
--Internal Data Port
      DAT_ADDR_OUT           : out std_logic_vector(c_REGIO_ADDRESS_WIDTH-1 downto 0);
      DAT_READ_ENABLE_OUT    : out std_logic;
      DAT_WRITE_ENABLE_OUT   : out std_logic;
      DAT_DATA_OUT           : out std_logic_vector(c_REGIO_REG_WIDTH-1 downto 0);
      DAT_DATA_IN            : in  std_logic_vector(c_REGIO_REG_WIDTH-1 downto 0);
      DAT_DATAREADY_IN       : in  std_logic;
      DAT_NO_MORE_DATA_IN    : in  std_logic;
      DAT_WRITE_ACK_IN       : in  std_logic;
      DAT_UNKNOWN_ADDR_IN    : in  std_logic;
      DAT_TIMEOUT_OUT        : out std_logic;

--Additional write access to ctrl registers
      STAT            : out std_logic_vector(31 downto 0);
      STAT_ADDR_DEBUG : out std_logic_vector(15 downto 0)
      );
  end component;





  component trb_net16_regio_bus_handler is
    generic(
      PORT_NUMBER    : integer range 1 to c_BUS_HANDLER_MAX_PORTS := 3;
      PORT_ADDRESSES : c_BUS_HANDLER_ADDR_t                       := (others => (others => '0'));
      PORT_ADDR_MASK : c_BUS_HANDLER_WIDTH_t                      := (others => 0);
      PORT_MASK_ENABLE : integer range 0 to 1
      );
    port(
      CLK                  : in  std_logic;
      RESET                : in  std_logic;
      DAT_ADDR_IN          : in  std_logic_vector(15 downto 0);  -- address bus
      DAT_DATA_IN          : in  std_logic_vector(31 downto 0);  -- data from TRB endpoint
      DAT_DATA_OUT         : out std_logic_vector(31 downto 0);  -- data to TRB endpoint
      DAT_READ_ENABLE_IN   : in  std_logic;  -- read pulse
      DAT_WRITE_ENABLE_IN  : in  std_logic;  -- write pulse
      DAT_TIMEOUT_IN       : in  std_logic;  -- access timed out
      DAT_DATAREADY_OUT    : out std_logic;  -- your data, master, as requested
      DAT_WRITE_ACK_OUT    : out std_logic;  -- data accepted
      DAT_NO_MORE_DATA_OUT : out std_logic;  -- don't disturb me now
      DAT_UNKNOWN_ADDR_OUT : out std_logic;  -- noone here to answer your request

      BUS_ADDR_OUT         : out std_logic_vector(PORT_NUMBER*16-1 downto 0);
      BUS_DATA_OUT         : out std_logic_vector(PORT_NUMBER*32-1 downto 0);
      BUS_READ_ENABLE_OUT  : out std_logic_vector(PORT_NUMBER-1 downto 0);
      BUS_WRITE_ENABLE_OUT : out std_logic_vector(PORT_NUMBER-1 downto 0);
      BUS_TIMEOUT_OUT      : out std_logic_vector(PORT_NUMBER-1 downto 0);

      BUS_DATA_IN         : in std_logic_vector(32*PORT_NUMBER-1 downto 0);
      BUS_DATAREADY_IN    : in std_logic_vector(PORT_NUMBER-1 downto 0);
      BUS_WRITE_ACK_IN    : in std_logic_vector(PORT_NUMBER-1 downto 0);
      BUS_NO_MORE_DATA_IN : in std_logic_vector(PORT_NUMBER-1 downto 0);
      BUS_UNKNOWN_ADDR_IN : in std_logic_vector(PORT_NUMBER-1 downto 0);

      STAT_DEBUG : out std_logic_vector(31 downto 0)
      );
  end component;




  component trb_net_reset_handler is
    generic(
      RESET_DELAY : std_logic_vector(15 downto 0) := x"1fff"
      );
    port(
      CLEAR_IN      : in  std_logic;    -- reset input (high active, async)
      CLEAR_N_IN    : in  std_logic;    -- reset input (low active, async)
      CLK_IN        : in  std_logic;    -- raw master clock, NOT from PLL/DLL!
      SYSCLK_IN     : in  std_logic;    -- PLL/DLL remastered clock
      PLL_LOCKED_IN : in  std_logic;    -- master PLL lock signal (async)
      RESET_IN      : in  std_logic;    -- general reset signal (SYSCLK)
      TRB_RESET_IN  : in  std_logic;    -- TRBnet reset signal (SYSCLK)
      CLEAR_OUT     : out std_logic;    -- async reset out, USE WITH CARE!
      RESET_OUT     : out std_logic;    -- synchronous reset out (SYSCLK)
      DEBUG_OUT     : out std_logic_vector(15 downto 0)
      );
  end component;



  component rom_16x8 is
    generic(
      INIT0 : std_logic_vector(15 downto 0) := x"0000";
      INIT1 : std_logic_vector(15 downto 0) := x"0000";
      INIT2 : std_logic_vector(15 downto 0) := x"0000";
      INIT3 : std_logic_vector(15 downto 0) := x"0000";
      INIT4 : std_logic_vector(15 downto 0) := x"0000";
      INIT5 : std_logic_vector(15 downto 0) := x"0000";
      INIT6 : std_logic_vector(15 downto 0) := x"0000";
      INIT7 : std_logic_vector(15 downto 0) := x"0000"
      );
    port(
      CLK  : in  std_logic;
      a    : in  std_logic_vector(2 downto 0);
      dout : out std_logic_vector(15 downto 0)
      );
  end component;



  component trb_net16_rx_control is
    port(
      RESET_IN               : in  std_logic;
      QUAD_RST_IN            : in  std_logic;
      -- raw data from SerDes receive path
      CLK_IN                 : in  std_logic;
      RX_DATA_IN             : in  std_logic_vector(7 downto 0);
      RX_K_IN                : in  std_logic;
      RX_CV_IN               : in  std_logic;
      RX_DISP_ERR_IN         : in  std_logic;
      RX_ALLOW_IN            : in  std_logic;
      -- media interface
      SYSCLK_IN              : in  std_logic;  -- 100MHz master clock
      MED_DATA_OUT           : out std_logic_vector(15 downto 0);
      MED_DATAREADY_OUT      : out std_logic;
      MED_READ_IN            : in  std_logic;
      MED_PACKET_NUM_OUT     : out std_logic_vector(2 downto 0);
      -- request retransmission in case of error while receiving
      REQUEST_RETRANSMIT_OUT : out std_logic;  -- one pulse
      REQUEST_POSITION_OUT   : out std_logic_vector(7 downto 0);
      -- command decoding
      START_RETRANSMIT_OUT   : out std_logic;
      START_POSITION_OUT     : out std_logic_vector(7 downto 0);
      -- reset handling
      SEND_RESET_WORDS_OUT   : out std_logic;
      MAKE_TRBNET_RESET_OUT  : out std_logic;
      -- Status signals
      PACKET_TIMEOUT_OUT     : out std_logic;
      ENABLE_CORRECTION_IN   : in  std_logic;
      -- Debugging
      DEBUG_OUT              : out std_logic_vector(31 downto 0);
      STAT_REG_OUT           : out std_logic_vector(95 downto 0)
      );
  end component;




  component trb_net16_sbuf is
    generic (
      VERSION : integer := 0
      );
    port(
      --  Misc
      CLK                : in  std_logic;
      RESET              : in  std_logic;
      CLK_EN             : in  std_logic;
      --  port to combinatorial logic
      COMB_DATAREADY_IN  : in  std_logic;  --comb logic provides data word
      COMB_next_READ_OUT : out std_logic;  --sbuf can read in NEXT cycle
      COMB_READ_IN       : in  std_logic;  --comb logic IS reading
      COMB_DATA_IN       : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      COMB_PACKET_NUM_IN : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      -- Port to synchronous output.
      SYN_DATAREADY_OUT  : out std_logic;
      SYN_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      SYN_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      SYN_READ_IN        : in  std_logic;
      -- Status and control port
      DEBUG_OUT          : out std_logic_vector(15 downto 0);
      STAT_BUFFER        : out std_logic
      );
  end component;





  component trb_net_sbuf is
    generic (
      DATA_WIDTH : integer := 18;
      VERSION    : integer := std_SBUF_VERSION);
    port(
      --  Misc
      CLK                : in  std_logic;
      RESET              : in  std_logic;
      CLK_EN             : in  std_logic;
      --  port to combinatorial logic
      COMB_DATAREADY_IN  : in  std_logic;  --comb logic provides data word
      COMB_next_READ_OUT : out std_logic;  --sbuf can read in NEXT cycle
      COMB_READ_IN       : in  std_logic;  --comb logic IS reading
      COMB_DATA_IN       : in  std_logic_vector (DATA_WIDTH-1 downto 0);
      SYN_DATAREADY_OUT  : out std_logic;
      SYN_DATA_OUT       : out std_logic_vector (DATA_WIDTH-1 downto 0);
      SYN_READ_IN        : in  std_logic;
      DEBUG_OUT          : out std_logic_vector(15 downto 0);
      STAT_BUFFER        : out std_logic
      );
  end component;


  component trb_net_sbuf2 is
    generic (
      DATA_WIDTH : integer := 18
      );
    port(
      --  Misc
      CLK                : in  std_logic;
      RESET              : in  std_logic;
      CLK_EN             : in  std_logic;
      --  port to combinatorial logic
      COMB_DATAREADY_IN  : in  std_logic;  --comb logic provides data word
      COMB_next_READ_OUT : out std_logic;  --sbuf can read in NEXT cycle
      COMB_READ_IN       : in  std_logic;  --comb logic IS reading
      COMB_DATA_IN       : in  std_logic_vector (DATA_WIDTH-1 downto 0);
      SYN_DATAREADY_OUT  : out std_logic;
      SYN_DATA_OUT       : out std_logic_vector (DATA_WIDTH-1 downto 0);
      SYN_READ_IN        : in  std_logic;
      STAT_BUFFER        : out std_logic
      );
  end component;

  component trb_net_sbuf3 is
    generic (
      DATA_WIDTH : integer := 18
      );
    port(
      --  Misc
      CLK                : in  std_logic;
      RESET              : in  std_logic;
      CLK_EN             : in  std_logic;
      --  port to combinatorial logic
      COMB_DATAREADY_IN  : in  std_logic;  --comb logic provides data word
      COMB_next_READ_OUT : out std_logic;  --sbuf can read in NEXT cycle
      COMB_READ_IN       : in  std_logic;  --comb logic IS reading
      COMB_DATA_IN       : in  std_logic_vector (DATA_WIDTH-1 downto 0);
      SYN_DATAREADY_OUT  : out std_logic;
      SYN_DATA_OUT       : out std_logic_vector (DATA_WIDTH-1 downto 0);
      SYN_READ_IN        : in  std_logic;
      STAT_BUFFER        : out std_logic
      );
  end component;

  component trb_net_sbuf4 is
    generic (
      DATA_WIDTH : integer := 18
      );
    port(
      --  Misc
      CLK                : in  std_logic;
      RESET              : in  std_logic;
      CLK_EN             : in  std_logic;
      --  port to combinatorial logic
      COMB_DATAREADY_IN  : in  std_logic;  --comb logic provides data word
      COMB_next_READ_OUT : out std_logic;  --sbuf can read in NEXT cycle
      COMB_READ_IN       : in  std_logic;  --comb logic IS reading
      COMB_DATA_IN       : in  std_logic_vector (DATA_WIDTH-1 downto 0);
      SYN_DATAREADY_OUT  : out std_logic;
      SYN_DATA_OUT       : out std_logic_vector (DATA_WIDTH-1 downto 0);
      SYN_READ_IN        : in  std_logic;
      STAT_BUFFER        : out std_logic
      );
  end component;

  component trb_net_sbuf5 is
    port(
      --  Misc
      CLK                : in  std_logic;
      RESET              : in  std_logic;
      CLK_EN             : in  std_logic;
      -- input
      COMB_DATAREADY_IN  : in  std_logic;
      COMB_next_READ_OUT : out std_logic;
      COMB_DATA_IN       : in  std_logic_vector(18 downto 0);
      -- output
      SYN_DATAREADY_OUT  : out std_logic;
      SYN_DATA_OUT       : out std_logic_vector(18 downto 0);  -- Data word
      SYN_READ_IN        : in  std_logic;
      -- Status and control port
      DEBUG              : out std_logic_vector(7 downto 0);
      DEBUG_BSM          : out std_logic_vector(3 downto 0);
      DEBUG_WCNT         : out std_logic_vector(4 downto 0);
      STAT_BUFFER        : out std_logic
      );
  end component;

  component trb_net_sbuf6 is
    port(
      --  Misc
      CLK                : in  std_logic;
      RESET              : in  std_logic;
      CLK_EN             : in  std_logic;
      -- input
      COMB_DATAREADY_IN  : in  std_logic;
      COMB_next_READ_OUT : out std_logic;
      COMB_DATA_IN       : in  std_logic_vector(18 downto 0);
      -- output
      SYN_DATAREADY_OUT  : out std_logic;
      SYN_DATA_OUT       : out std_logic_vector(18 downto 0);
      SYN_READ_IN        : in  std_logic;
      -- Status and control port
      DEBUG              : out std_logic_vector(7 downto 0);
      DEBUG_BSM          : out std_logic_vector(3 downto 0);
      DEBUG_WCNT         : out std_logic_vector(4 downto 0);
      STAT_BUFFER        : out std_logic
      );
  end component;

  component slv_mac_memory is
    port(
      CLK          : in  std_logic;
      RESET        : in  std_logic;
      BUSY_IN      : in  std_logic;
      -- Slave bus
      SLV_ADDR_IN  : in  std_logic_vector(7 downto 0);
      SLV_READ_IN  : in  std_logic;
      SLV_WRITE_IN : in  std_logic;
      SLV_BUSY_OUT : out std_logic;
      SLV_ACK_OUT  : out std_logic;
      SLV_DATA_IN  : in  std_logic_vector(31 downto 0);
      SLV_DATA_OUT : out std_logic_vector(31 downto 0);
      -- I/O to the backend
      MEM_CLK_IN   : in  std_logic;
      MEM_ADDR_IN  : in  std_logic_vector(7 downto 0);
      MEM_DATA_OUT : out std_logic_vector(31 downto 0);
      -- Status lines
      STAT         : out std_logic_vector(31 downto 0)  -- DEBUG
      );
  end component;



  component slv_register is
    generic(
      RESET_VALUE : std_logic_vector(31 downto 0) := x"0000_0000"
      );
    port(
      CLK_IN       : in  std_logic;
      RESET_IN     : in  std_logic;
      BUSY_IN      : in  std_logic;
      -- Slave bus
      SLV_READ_IN  : in  std_logic;
      SLV_WRITE_IN : in  std_logic;
      SLV_BUSY_OUT : out std_logic;
      SLV_ACK_OUT  : out std_logic;
      SLV_DATA_IN  : in  std_logic_vector(31 downto 0);
      SLV_DATA_OUT : out std_logic_vector(31 downto 0);
      -- I/O to the backend
      REG_DATA_IN  : in  std_logic_vector(31 downto 0);
      REG_DATA_OUT : out std_logic_vector(31 downto 0);
      -- Status lines
      STAT         : out std_logic_vector(31 downto 0)  -- DEBUG
      );
  end component;



  component spi_databus_memory is
    port(
      CLK_IN        : in  std_logic;
      RESET_IN      : in  std_logic;
      -- Slave bus
      BUS_ADDR_IN   : in  std_logic_vector(5 downto 0);
      BUS_READ_IN   : in  std_logic;
      BUS_WRITE_IN  : in  std_logic;
      BUS_ACK_OUT   : out std_logic;
      BUS_DATA_IN   : in  std_logic_vector(31 downto 0);
      BUS_DATA_OUT  : out std_logic_vector(31 downto 0);
      -- state machine connections
      BRAM_ADDR_IN  : in  std_logic_vector(7 downto 0);
      BRAM_WR_D_OUT : out std_logic_vector(7 downto 0);
      BRAM_RD_D_IN  : in  std_logic_vector(7 downto 0);
      BRAM_WE_IN    : in  std_logic;
      -- Status lines
      STAT          : out std_logic_vector(63 downto 0)  -- DEBUG
      );
  end component;


  component spi_dpram_32_to_8 is
    port (
      DataInA  : in  std_logic_vector(31 downto 0);
      DataInB  : in  std_logic_vector(7 downto 0);
      AddressA : in  std_logic_vector(5 downto 0);
      AddressB : in  std_logic_vector(7 downto 0);
      ClockA   : in  std_logic;
      ClockB   : in  std_logic;
      ClockEnA : in  std_logic;
      ClockEnB : in  std_logic;
      WrA      : in  std_logic;
      WrB      : in  std_logic;
      ResetA   : in  std_logic;
      ResetB   : in  std_logic;
      QA       : out std_logic_vector(31 downto 0);
      QB       : out std_logic_vector(7 downto 0));
  end component;


  component spi_slim is
    port(
      SYSCLK      : in  std_logic;      -- 100MHz sysclock
      RESET       : in  std_logic;      -- synchronous reset
      -- Command interface
      START_IN    : in  std_logic;      -- one start pulse
      BUSY_OUT    : out std_logic;      -- SPI transactions are ongoing
      CMD_IN      : in  std_logic_vector(7 downto 0);  -- SPI command byte
      ADL_IN      : in  std_logic_vector(7 downto 0);  -- low address byte
      ADM_IN      : in  std_logic_vector(7 downto 0);  -- mid address byte
      ADH_IN      : in  std_logic_vector(7 downto 0);  -- high address byte
      MAX_IN      : in  std_logic_vector(7 downto 0);  -- number of bytes to write / read (PP/RDCMD)
      TXDATA_IN   : in  std_logic_vector(7 downto 0);  -- byte to be transmitted next
      TX_RD_OUT   : out std_logic;
      RXDATA_OUT  : out std_logic_vector(7 downto 0);  -- current received byte
      RX_WR_OUT   : out std_logic;
      TX_RX_A_OUT : out std_logic_vector(7 downto 0);  -- memory block counter for PP/RDCMD
      -- SPI interface
      SPI_SCK_OUT : out std_logic;
      SPI_CS_OUT  : out std_logic;
      SPI_SDI_IN  : in  std_logic;
      SPI_SDO_OUT : out std_logic;
      -- DEBUG
      CLK_EN_OUT  : out std_logic;
      BSM_OUT     : out std_logic_vector(7 downto 0);
      DEBUG_OUT   : out std_logic_vector(31 downto 0)
      );
  end component;





  component spi_master is
    port(
      CLK_IN        : in  std_logic;
      RESET_IN      : in  std_logic;
      -- Slave bus
      BUS_READ_IN   : in  std_logic;
      BUS_WRITE_IN  : in  std_logic;
      BUS_BUSY_OUT  : out std_logic;
      BUS_ACK_OUT   : out std_logic;
      BUS_ADDR_IN   : in  std_logic_vector(0 downto 0);
      BUS_DATA_IN   : in  std_logic_vector(31 downto 0);
      BUS_DATA_OUT  : out std_logic_vector(31 downto 0);
      -- SPI connections
      SPI_CS_OUT    : out std_logic;
      SPI_SDI_IN    : in  std_logic;
      SPI_SDO_OUT   : out std_logic;
      SPI_SCK_OUT   : out std_logic;
      -- BRAM for read/write data
      BRAM_A_OUT    : out std_logic_vector(7 downto 0);
      BRAM_WR_D_IN  : in  std_logic_vector(7 downto 0);
      BRAM_RD_D_OUT : out std_logic_vector(7 downto 0);
      BRAM_WE_OUT   : out std_logic;
      -- Status lines
      STAT          : out std_logic_vector(31 downto 0)  -- DEBUG
      );
  end component;



  component spi_ltc2600 is
    generic (
      BITS       : integer range 8 to 32;
      WAITCYCLES : integer range 2 to 1024);
    port (
      CLK_IN       : in  std_logic;
      RESET_IN     : in  std_logic;
      -- Slave bus
      BUS_READ_IN  : in  std_logic;
      BUS_WRITE_IN : in  std_logic;
      BUS_BUSY_OUT : out std_logic;
      BUS_ACK_OUT  : out std_logic;
      BUS_ADDR_IN  : in  std_logic_vector(4 downto 0);
      BUS_DATA_IN  : in  std_logic_vector(31 downto 0);
      BUS_DATA_OUT : out std_logic_vector(31 downto 0);
      -- SPI connections
      SPI_CS_OUT   : out std_logic_vector(15 downto 0);
      SPI_SDI_IN   : in  std_logic;
      SPI_SDO_OUT  : out std_logic;
      SPI_SCK_OUT  : out std_logic;
      SPI_CLR_OUT  : out std_logic_vector(15 downto 0));
  end component spi_ltc2600;
  
  component signal_sync is
    generic(
      WIDTH : integer := 1;             --
      DEPTH : integer := 3
      );
    port(
      RESET : in  std_logic;  --Reset is neceessary to avoid optimization to shift register
      CLK0  : in  std_logic;            --clock for first FF
      CLK1  : in  std_logic;            --Clock for other FF
      D_IN  : in  std_logic_vector(WIDTH-1 downto 0);  --Data input
      D_OUT : out std_logic_vector(WIDTH-1 downto 0)   --Data output
      );
  end component;







  component trb_net16_term is
    generic (
      USE_APL_PORT : integer range 0 to 1 := c_YES;
      --even when 0, ERROR_PACKET_IN is used for automatic replys
      SECURE_MODE  : integer range 0 to 1 := std_TERM_SECURE_MODE
      --if secure_mode is not used, apl must provide error pattern and dtype until
      --next trigger comes in. In secure mode these need to be available while relase_trg is high
      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      INT_DATAREADY_OUT  : out std_logic;
      INT_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);  -- Data word
      INT_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_READ_IN        : in  std_logic;

      INT_DATAREADY_IN     : in  std_logic;
      INT_DATA_IN          : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);  -- Data word
      INT_PACKET_NUM_IN    : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_READ_OUT         : out std_logic;
      APL_ERROR_PATTERN_IN : in  std_logic_vector(31 downto 0)
      );
  end component;





  component trb_net16_term_buf is
    port(
      --  Misc
      CLK                      : in  std_logic;
      RESET                    : in  std_logic;
      CLK_EN                   : in  std_logic;
      MED_INIT_DATAREADY_OUT   : out std_logic;
      MED_INIT_DATA_OUT        : out std_logic_vector (c_DATA_WIDTH-1 downto 0);  -- Data word
      MED_INIT_PACKET_NUM_OUT  : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_INIT_READ_IN         : in  std_logic;
      MED_REPLY_DATAREADY_OUT  : out std_logic;
      MED_REPLY_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);  -- Data word
      MED_REPLY_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_REPLY_READ_IN        : in  std_logic;
      MED_DATAREADY_IN         : in  std_logic;
      MED_DATA_IN              : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);  -- Data word
      MED_PACKET_NUM_IN        : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      MED_READ_OUT             : out std_logic
      );
  end component;





  component trb_net16_term_ibuf is
    generic(
      SECURE_MODE  : integer range 0 to 1 := std_TERM_SECURE_MODE;
      SBUF_VERSION : integer range 0 to 1 := std_SBUF_VERSION
      );
    port(
      --  Misc
      CLK                : in  std_logic;
      RESET              : in  std_logic;
      CLK_EN             : in  std_logic;
      --  Media direction port
      MED_DATAREADY_IN   : in  std_logic;
      MED_DATA_IN        : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      MED_PACKET_NUM_IN  : in  std_logic_vector(c_NUM_WIDTH-1 downto 0);
      MED_READ_OUT       : out std_logic;
      MED_ERROR_IN       : in  std_logic_vector (2 downto 0);
      -- Internal direction port
      INT_DATAREADY_OUT  : out std_logic;
      INT_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_OUT : out std_logic_vector(c_NUM_WIDTH-1 downto 0);
      INT_READ_IN        : in  std_logic;
      INT_ERROR_OUT      : out std_logic_vector (2 downto 0);
      -- Status and control port
      STAT_BUFFER        : out std_logic_vector (31 downto 0)
      );
  end component;




  component trb_net16_trigger is
    generic (
      USE_TRG_PORT : integer range 0 to 1 := c_YES;
      --even when NO, ERROR_PACKET_IN is used for automatic replys
      SECURE_MODE  : integer range 0 to 1 := std_TERM_SECURE_MODE
      --if secure_mode is not used, apl must provide error pattern and dtype until
      --next trigger comes in. In secure mode these need to be available while relase_trg is high only
      );
    port(
      --  Misc
      CLK    : in std_logic;
      RESET  : in std_logic;
      CLK_EN : in std_logic;

      INT_DATAREADY_OUT  : out std_logic;
      INT_DATA_OUT       : out std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_OUT : out std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_READ_IN        : in  std_logic;

      INT_DATAREADY_IN  : in  std_logic;
      INT_DATA_IN       : in  std_logic_vector (c_DATA_WIDTH-1 downto 0);
      INT_PACKET_NUM_IN : in  std_logic_vector (c_NUM_WIDTH-1 downto 0);
      INT_READ_OUT      : out std_logic;

      -- Trigger information output
      TRG_TYPE_OUT         : out std_logic_vector (3 downto 0);
      TRG_NUMBER_OUT       : out std_logic_vector (15 downto 0);
      TRG_CODE_OUT         : out std_logic_vector (7 downto 0);
      TRG_INFORMATION_OUT  : out std_logic_vector (23 downto 0);
      TRG_RECEIVED_OUT     : out std_logic;
      TRG_RELEASE_IN       : in  std_logic;
      TRG_ERROR_PATTERN_IN : in  std_logic_vector (31 downto 0)
      );
  end component;



  component trb_net16_tx_control is
    port(
      TXCLK_IN  : in std_logic;
      RXCLK_IN  : in std_logic;
      SYSCLK_IN : in std_logic;
      RESET_IN  : in std_logic;

      TX_DATA_IN          : in  std_logic_vector(15 downto 0);
      TX_PACKET_NUMBER_IN : in  std_logic_vector(2 downto 0);
      TX_WRITE_IN         : in  std_logic;
      TX_READ_OUT         : out std_logic;

      TX_DATA_OUT : out std_logic_vector(7 downto 0);
      TX_K_OUT    : out std_logic;

      REQUEST_RETRANSMIT_IN : in std_logic;
      REQUEST_POSITION_IN   : in std_logic_vector(7 downto 0);

      START_RETRANSMIT_IN : in std_logic;
      START_POSITION_IN   : in std_logic_vector(7 downto 0);

      SEND_LINK_RESET_IN : in std_logic;
      TX_ALLOW_IN        : in std_logic;

      DEBUG_OUT    : out std_logic_vector(31 downto 0);
      STAT_REG_OUT : out std_logic_vector(31 downto 0)
      );
  end component;




  component wide_adder_17x16 is
    generic(
      SIZE  : integer := 16;
      WORDS : integer := 17             --fixed
      );
    port(
      CLK           : in  std_logic;
      CLK_EN        : in  std_logic;
      RESET         : in  std_logic;
      INPUT_IN      : in  std_logic_vector(SIZE*WORDS-1 downto 0);
      START_IN      : in  std_logic;
      VAL_ENABLE_IN : in  std_logic_vector(WORDS-1 downto 0);
      RESULT_OUT    : out std_logic_vector(SIZE-1 downto 0);
      OVERFLOW_OUT  : out std_logic;
      READY_OUT     : out std_logic
      );
  end component;


  component trb_net_bridge_etrax_apl is
    port(
      CLK                    : in  std_logic;
      RESET                  : in  std_logic;
      CLK_EN                 : in  std_logic;
      APL_DATA_OUT           : out std_logic_vector (c_DATA_WIDTH*2**(c_MUX_WIDTH)-1 downto 0);
      APL_PACKET_NUM_OUT     : out std_logic_vector (c_NUM_WIDTH*2**(c_MUX_WIDTH)-1 downto 0);
      APL_DATAREADY_OUT      : out std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_READ_IN            : in  std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_SHORT_TRANSFER_OUT : out std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_DTYPE_OUT          : out std_logic_vector (4*2**(c_MUX_WIDTH)-1 downto 0);
      APL_ERROR_PATTERN_OUT  : out std_logic_vector (32*2**(c_MUX_WIDTH)-1 downto 0);
      APL_SEND_OUT           : out std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_TARGET_ADDRESS_OUT : out std_logic_vector (16*2**(c_MUX_WIDTH)-1 downto 0);
      APL_DATA_IN            : in  std_logic_vector (c_DATA_WIDTH*2**(c_MUX_WIDTH)-1 downto 0);
      APL_PACKET_NUM_IN      : in  std_logic_vector (c_NUM_WIDTH*2**(c_MUX_WIDTH)-1 downto 0);
      APL_TYP_IN             : in  std_logic_vector (3*2**(c_MUX_WIDTH)-1 downto 0);
      APL_DATAREADY_IN       : in  std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_READ_OUT           : out std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_RUN_IN             : in  std_logic_vector (2**(c_MUX_WIDTH)-1 downto 0);
      APL_SEQNR_IN           : in  std_logic_vector (8*2**(c_MUX_WIDTH)-1 downto 0);
      CPU_READ               : in  std_logic;
      CPU_WRITE              : in  std_logic;
      CPU_DATA_OUT           : out std_logic_vector (31 downto 0);
      CPU_DATA_IN            : in  std_logic_vector (31 downto 0);
      CPU_DATAREADY_OUT      : out std_logic;
      CPU_ADDRESS            : in  std_logic_vector (15 downto 0);
      STAT                   : out std_logic_vector (31 downto 0);
      CTRL                   : in  std_logic_vector (31 downto 0)
      );
  end component;


end package;
