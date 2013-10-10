module JTAGE ( TCK, TMS, TDI, JTDO1, JTDO2,
  TDO, JTDI, JTCK, JRTI1, JRTI2, JSHIFT, JUPDATE, JRSTN, JCE1, JCE2)  
  /* synthesis syn_black_box syn_noprune=1 */;
 parameter ER1 = "ENABLED";
 parameter ER2 = "ENABLED";
input TCK, TMS, TDI, JTDO1, JTDO2;
output TDO, JTDI, JTCK, JRTI1, JRTI2;
output JSHIFT, JUPDATE, JRSTN, JCE1, JCE2;
endmodule