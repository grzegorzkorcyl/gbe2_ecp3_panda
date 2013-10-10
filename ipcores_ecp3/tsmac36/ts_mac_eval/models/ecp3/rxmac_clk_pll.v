`timescale 1 ns / 1 ps
module rxmac_clk_pll (CLK, RESET, CLKFB, CLKOP, CLKOS, CLKOK, LOCK);
    input wire CLK;
    input wire RESET;
    input wire CLKFB;
    output wire CLKOP;
    output wire CLKOS;
    output wire CLKOK;
    output wire LOCK;

    wire CLKOS_t;
    wire CLKOP_t;
    wire scuba_vlo;

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam PLLInst_0.FEEDBK_PATH = "USERCLOCK" ;
    defparam PLLInst_0.CLKOK_BYPASS = "DISABLED" ;
    defparam PLLInst_0.CLKOS_BYPASS = "DISABLED" ;
    defparam PLLInst_0.CLKOP_BYPASS = "DISABLED" ;
    defparam PLLInst_0.CLKOK_INPUT = "CLKOP" ;
    defparam PLLInst_0.DELAY_PWD = "DISABLED" ;
    defparam PLLInst_0.DELAY_VAL = 0 ;
    defparam PLLInst_0.CLKOS_TRIM_DELAY = 0 ;
    defparam PLLInst_0.CLKOS_TRIM_POL = "RISING" ;
    defparam PLLInst_0.CLKOP_TRIM_DELAY = 0 ;
    defparam PLLInst_0.CLKOP_TRIM_POL = "RISING" ;
    defparam PLLInst_0.PHASE_DELAY_CNTL = "STATIC" ;
    defparam PLLInst_0.DUTY = 8 ;
    defparam PLLInst_0.PHASEADJ = "0.0" ;
    defparam PLLInst_0.CLKOK_DIV = 2 ;
    defparam PLLInst_0.CLKOP_DIV = 8 ;
    defparam PLLInst_0.CLKFB_DIV = 1 ;
    defparam PLLInst_0.CLKI_DIV = 1 ;
    defparam PLLInst_0.FIN = "125.000000" ;
    EHXPLLF PLLInst_0 (.CLKI(CLK), .CLKFB(CLKFB), .RST(RESET), .RSTK(scuba_vlo), 
        .WRDEL(scuba_vlo), .DRPAI3(scuba_vlo), .DRPAI2(scuba_vlo), .DRPAI1(scuba_vlo), 
        .DRPAI0(scuba_vlo), .DFPAI3(scuba_vlo), .DFPAI2(scuba_vlo), .DFPAI1(scuba_vlo), 
        .DFPAI0(scuba_vlo), .FDA3(scuba_vlo), .FDA2(scuba_vlo), .FDA1(scuba_vlo), 
        .FDA0(scuba_vlo), .CLKOP(CLKOP_t), .CLKOS(CLKOS_t), .CLKOK(CLKOK), 
        .CLKOK2(), .LOCK(LOCK), .CLKINTFB())
             /* synthesis FREQUENCY_PIN_CLKOS="125.000000" */
             /* synthesis FREQUENCY_PIN_CLKOP="125.000000" */
             /* synthesis FREQUENCY_PIN_CLKI="125.000000" */
             /* synthesis FREQUENCY_PIN_CLKOK="62.500000" */;

    assign CLKOS = CLKOS_t;
    assign CLKOP = CLKOP_t;


    // exemplar begin
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKOS 125.000000
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKOP 125.000000
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKI 125.000000
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKOK 62.500000
    // exemplar end

endmodule

