-- VHDL module instantiation generated by SCUBA Diamond_1.3_Production (92)
-- Module  Version: 5.4
-- Thu Sep 22 11:22:35 2011

-- parameterized module component declaration
component fifo_32kx16x8_mb
    port (Data: in  std_logic_vector(15 downto 0); 
        WrClock: in  std_logic; RdClock: in  std_logic; 
        WrEn: in  std_logic; RdEn: in  std_logic; Reset: in  std_logic; 
        RPReset: in  std_logic; 
        AmEmptyThresh: in  std_logic_vector(15 downto 0); 
        AmFullThresh: in  std_logic_vector(14 downto 0); 
        Q: out  std_logic_vector(7 downto 0); 
        WCNT: out  std_logic_vector(15 downto 0); 
        RCNT: out  std_logic_vector(16 downto 0); Empty: out  std_logic; 
        Full: out  std_logic; AlmostEmpty: out  std_logic; 
        AlmostFull: out  std_logic);
end component;

-- parameterized module component instance
__ : fifo_32kx16x8_mb
    port map (Data(15 downto 0)=>__, WrClock=>__, RdClock=>__, WrEn=>__, 
        RdEn=>__, Reset=>__, RPReset=>__, AmEmptyThresh(15 downto 0)=>__, 
        AmFullThresh(14 downto 0)=>__, Q(7 downto 0)=>__, WCNT(15 downto 0)=>__, 
        RCNT(16 downto 0)=>__, Empty=>__, Full=>__, AlmostEmpty=>__, 
        AlmostFull=>__);
