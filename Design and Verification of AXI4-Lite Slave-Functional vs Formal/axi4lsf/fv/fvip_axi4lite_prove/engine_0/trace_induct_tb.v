`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  wire [0:0] PI_clk = clock;
  fvip_top UUT (
    .clk(PI_clk)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/S_AXI_ARREADY[0:0]#sampled$1512  = 1'b1;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/S_AXI_AWREADY[0:0]#sampled$1602  = 1'b1;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/S_AXI_BRESP[1:0]#sampled$1542  = 2'b11;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/S_AXI_BVALID[0:0]#sampled$1552  = 1'b1;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/S_AXI_RDATA[31:0]#sampled$1482  = 32'b11111111111111111111111111111111;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/S_AXI_RRESP[1:0]#sampled$1492  = 2'b11;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/S_AXI_RVALID[0:0]#sampled$1502  = 1'b1;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/S_AXI_WREADY[0:0]#sampled$1562  = 1'b1;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/ar_addr_latch[3:0]#sampled$1532  = 4'b1111;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/ar_pending[0:0]#sampled$1522  = 1'b1;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/aw_addr_latch[3:0]#sampled$1622  = 4'b1111;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/aw_pending[0:0]#sampled$1612  = 1'b1;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/w_data_latch[31:0]#sampled$1582  = 32'b11111111111111111111111111111111;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/w_pending[0:0]#sampled$1572  = 1'b1;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$$0/w_strb_latch[3:0]#sampled$1592  = 4'b1111;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/S_AXI_ARREADY#sampled$1510  = 1'b0;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/S_AXI_AWREADY#sampled$1600  = 1'b0;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/S_AXI_BRESP#sampled$1540  = 2'b00;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/S_AXI_BVALID#sampled$1550  = 1'b0;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/S_AXI_RDATA#sampled$1480  = 32'b00000000000000000000000000000000;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/S_AXI_RRESP#sampled$1490  = 2'b00;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/S_AXI_RVALID#sampled$1500  = 1'b1;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/S_AXI_WREADY#sampled$1560  = 1'b0;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/ar_addr_latch#sampled$1530  = 4'b0011;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/ar_pending#sampled$1520  = 1'b0;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/aw_addr_latch#sampled$1620  = 4'b0011;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/aw_pending#sampled$1610  = 1'b0;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/w_data_latch#sampled$1580  = 32'b00000000000000000000000000000000;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/w_pending#sampled$1570  = 1'b0;
    // UUT.u_dut.$auto$clk2fflogic.\cc:101:sample_data$/w_strb_latch#sampled$1590  = 4'b1000;
    // UUT.u_dut.$auto$clk2fflogic.\cc:190:execute$regs#0#past_clk#/S_AXI_ACLK$1384  = 1'b1;
    // UUT.u_dut.$auto$clk2fflogic.\cc:206:execute$regs#0#en_q$1388  = 32'b00000000000000000000000000000000;
    // UUT.u_dut.$auto$clk2fflogic.\cc:206:execute$regs#4#en_q$1436  = 32'b00000000000000000000000000000000;
    // UUT.u_dut.$auto$clk2fflogic.\cc:206:execute$regs#5#en_q$1448  = 32'b00000000000000000000000000000000;
    // UUT.u_dut.$auto$clk2fflogic.\cc:206:execute$regs#6#en_q$1460  = 32'b00000000000000000000000000000000;
    // UUT.u_dut.$auto$clk2fflogic.\cc:206:execute$regs#7#en_q$1472  = 32'b00000000000000000000000000000000;
    // UUT.u_dut.$auto$clk2fflogic.\cc:209:execute$regs#2#addr_q$1414  = 2'b10;
    // UUT.u_dut.$auto$clk2fflogic.\cc:209:execute$regs#3#addr_q$1426  = 2'b11;
    // UUT.u_dut.$auto$clk2fflogic.\cc:209:execute$regs#4#addr_q$1438  = 2'b11;
    // UUT.u_dut.$auto$clk2fflogic.\cc:209:execute$regs#5#addr_q$1450  = 2'b11;
    // UUT.u_dut.$auto$clk2fflogic.\cc:209:execute$regs#6#addr_q$1462  = 2'b11;
    // UUT.u_dut.$auto$clk2fflogic.\cc:209:execute$regs#7#addr_q$1474  = 2'b11;
    // UUT.u_dut.$auto$clk2fflogic.\cc:212:execute$regs#4#data_q$1440  = 32'b11111111111111111111111111111111;
    // UUT.u_dut.$auto$clk2fflogic.\cc:212:execute$regs#5#data_q$1452  = 32'b11111111111111111111111111111111;
    // UUT.u_dut.$auto$clk2fflogic.\cc:212:execute$regs#6#data_q$1464  = 32'b11111111111111111111111111111111;
    // UUT.u_dut.$auto$clk2fflogic.\cc:212:execute$regs#7#data_q$1476  = 32'b11111111111111111111111111111111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$0$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:505$416$0[0:0]$639#sampled$2478  = 1'b0;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$0/f_ar_cnt[7:0]#sampled$2528  = 8'b11111111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$0/f_aw_cnt[7:0]#sampled$2498  = 8'b11111111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$0/f_b_cnt[7:0]#sampled$2518  = 8'b11111111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$0/f_r_cnt[7:0]#sampled$2538  = 8'b11111111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$0/f_w_cnt[7:0]#sampled$2508  = 8'b11111111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:183$482_EN#sampled$1706  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:211$507_EN#sampled$1762  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:220$520_EN#sampled$1804  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:236$527_EN#sampled$1818  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:237$529_EN#sampled$1832  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:257$533_EN#sampled$1846  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:258$534_EN#sampled$1860  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:259$535_EN#sampled$1874  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:278$543_EN#sampled$1888  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:279$545_EN#sampled$1902  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:280$547_EN#sampled$1916  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:333$563_EN#sampled$2000  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assert$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:450$599_EN#sampled$2112  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assume$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:102$421_EN#sampled$2126  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assume$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:109$430_EN#sampled$2168  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assume$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:133$445_EN#sampled$2196  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assume$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:143$459_EN#sampled$2224  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$assume$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:153$473_EN#sampled$2266  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:110$433_Y#sampled$2160  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:111$435_Y#sampled$2174  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:134$447_Y#sampled$2202  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:135$449_Y#sampled$2216  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:144$461_Y#sampled$2244  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:145$463_Y#sampled$2258  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:154$475_Y#sampled$2286  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:155$477_Y#sampled$2300  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:183$483_Y#sampled$1642  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:184$485_Y#sampled$1656  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:185$487_Y#sampled$1670  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:186$489_Y#sampled$1824  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:187$491_Y#sampled$1698  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:188$493_Y#sampled$1712  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:189$495_Y#sampled$1726  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:190$497_Y#sampled$1838  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:212$509_Y#sampled$1768  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:221$522_Y#sampled$1796  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$eq$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:222$524_Y#sampled$1810  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$gt$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:373$587_Y#sampled$2020  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$gt$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:374$589_Y#sampled$2034  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$gt$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:382$593_Y#sampled$2048  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$le$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:333$564_Y#sampled$1936  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$le$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:334$566_Y#sampled$1950  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$le$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:340$571_Y#sampled$1964  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$le$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:341$574_Y#sampled$1978  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$le$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:347$578_Y#sampled$1992  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$le$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:352$583_Y#sampled$2006  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:102$422_Y#sampled$2132  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:278$544_Y#sampled$2062  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:279$546_Y#sampled$2076  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:280$548_Y#sampled$2104  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:452$604_Y#sampled$2090  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$logic_not$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:454$608_Y#sampled$2118  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:108$381$0#sampled$2836  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:108$382$0#sampled$2846  = 1'b0;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:110$383$0#sampled$2856  = 4'b0000;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:111$384$0#sampled$2866  = 3'b000;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:131$385$0#sampled$2786  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:132$386$0#sampled$2796  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:132$387$0#sampled$2806  = 1'b0;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:134$388$0#sampled$2816  = 4'b0000;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:135$389$0#sampled$2826  = 3'b000;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:141$390$0#sampled$2736  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:142$391$0#sampled$2746  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:142$392$0#sampled$2756  = 1'b0;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:144$393$0#sampled$2766  = 32'b11111111111111111111111111111111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:145$394$0#sampled$2776  = 4'b1111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:151$395$0#sampled$2686  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:152$396$0#sampled$2696  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:152$397$0#sampled$2706  = 1'b0;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:154$398$0#sampled$2716  = 4'b0000;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:155$399$0#sampled$2726  = 3'b000;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:182$400$0#sampled$2676  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:209$401$0#sampled$2636  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:210$402$0#sampled$2646  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:210$403$0#sampled$2656  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:212$404$0#sampled$2666  = 2'b00;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:218$405$0#sampled$2586  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:219$406$0#sampled$2596  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:219$407$0#sampled$2606  = 1'b0;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:221$408$0#sampled$2616  = 32'b00000000000000000000000000000000;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:222$409$0#sampled$2626  = 2'b00;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:277$410$0#sampled$2546  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:278$411$0#sampled$2556  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:279$412$0#sampled$2566  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:280$413$0#sampled$2576  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:449$414$0#sampled$2486  = 1'b0;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:504$415$0#sampled$2466  = 1'b0;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:505$416$0#sampled$2476  = 1'b0;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$$past$/home/nikhil/projects/axi4lsf/fv/fvip_axi4lite_props .\sv:566$417$0#sampled$2456  = 1'b0;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/araddr#sampled$2718  = 4'b1111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/aresetn#sampled$2548  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/arprot#sampled$2728  = 3'b111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/arready#sampled$2578  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/arvalid#sampled$1880  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/arvalid#sampled$2698  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/awaddr#sampled$2818  = 4'b1111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/awprot#sampled$2828  = 3'b111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/awready#sampled$2558  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/awvalid#sampled$1852  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/awvalid#sampled$2798  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/bready#sampled$2658  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/bresp#sampled$2668  = 2'b11;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/bvalid#sampled$1754  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/bvalid#sampled$2648  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/f_ar_cnt#sampled$2526  = 8'b01111001;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/f_aw_cnt#sampled$2496  = 8'b00000001;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/f_b_cnt#sampled$2516  = 8'b00000001;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/f_past_valid#sampled$2876  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/f_r_cnt#sampled$2536  = 8'b01111000;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/f_w_cnt#sampled$2506  = 8'b00000010;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/rdata#sampled$2618  = 32'b11111111111111111111111111111111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/rready#sampled$2608  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/rresp#sampled$2628  = 2'b11;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/rvalid#sampled$1782  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/rvalid#sampled$2598  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/wdata#sampled$2768  = 32'b11111111111111111111111111111111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/wready#sampled$2568  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/wstrb#sampled$2778  = 4'b1111;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/wvalid#sampled$2230  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$/wvalid#sampled$2748  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:101:sample_data$1'1#sampled$2878  = 1'b1;
    // UUT.u_props.$auto$clk2fflogic.\cc:87:sample_control_edge$/clk#sampled$1630  = 1'b1;
    UUT.u_dut.regs[2'b00] = 32'b11111111111111111111111111111111;

    // state 0
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
    end

    // state 2
    if (cycle == 1) begin
    end

    // state 3
    if (cycle == 2) begin
    end

    // state 4
    if (cycle == 3) begin
    end

    // state 5
    if (cycle == 4) begin
    end

    // state 6
    if (cycle == 5) begin
    end

    // state 7
    if (cycle == 6) begin
    end

    // state 8
    if (cycle == 7) begin
    end

    // state 9
    if (cycle == 8) begin
    end

    // state 10
    if (cycle == 9) begin
    end

    // state 11
    if (cycle == 10) begin
    end

    // state 12
    if (cycle == 11) begin
    end

    // state 13
    if (cycle == 12) begin
    end

    // state 14
    if (cycle == 13) begin
    end

    // state 15
    if (cycle == 14) begin
    end

    // state 16
    if (cycle == 15) begin
    end

    // state 17
    if (cycle == 16) begin
    end

    // state 18
    if (cycle == 17) begin
    end

    // state 19
    if (cycle == 18) begin
    end

    // state 20
    if (cycle == 19) begin
    end

    // state 21
    if (cycle == 20) begin
    end

    // state 22
    if (cycle == 21) begin
    end

    // state 23
    if (cycle == 22) begin
    end

    // state 24
    if (cycle == 23) begin
    end

    // state 25
    if (cycle == 24) begin
    end

    // state 26
    if (cycle == 25) begin
    end

    // state 27
    if (cycle == 26) begin
    end

    // state 28
    if (cycle == 27) begin
    end

    // state 29
    if (cycle == 28) begin
    end

    // state 30
    if (cycle == 29) begin
    end

    // state 31
    if (cycle == 30) begin
    end

    // state 32
    if (cycle == 31) begin
    end

    // state 33
    if (cycle == 32) begin
    end

    // state 34
    if (cycle == 33) begin
    end

    // state 35
    if (cycle == 34) begin
    end

    // state 36
    if (cycle == 35) begin
    end

    // state 37
    if (cycle == 36) begin
    end

    // state 38
    if (cycle == 37) begin
    end

    // state 39
    if (cycle == 38) begin
    end

    // state 40
    if (cycle == 39) begin
    end

    genclock <= cycle < 40;
    cycle <= cycle + 1;
  end
endmodule
