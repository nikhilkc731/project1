// AXI4-Lite Interface
//
// aresetn is a logic member (not an input port) so that both the
// tb_top module and UVM classes can drive it for reset testing.

interface axi4lite_if #(
  parameter ADDR_WIDTH = 4,
  parameter DATA_WIDTH = 32
) (
  input logic aclk
);

  localparam STRB_WIDTH = DATA_WIDTH / 8;

  // Reset - writable from tb_top and from UVM classes via vif
  logic aresetn;

  // Write Address Channel
  logic [ADDR_WIDTH-1:0] awaddr;
  logic [2:0]            awprot;
  logic                  awvalid;
  logic                  awready;

  // Write Data Channel
  logic [DATA_WIDTH-1:0] wdata;
  logic [STRB_WIDTH-1:0] wstrb;
  logic                  wvalid;
  logic                  wready;

  // Write Response Channel
  logic [1:0]            bresp;
  logic                  bvalid;
  logic                  bready;

  // Read Address Channel
  logic [ADDR_WIDTH-1:0] araddr;
  logic [2:0]            arprot;
  logic                  arvalid;
  logic                  arready;

  // Read Data Channel
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0]            rresp;
  logic                  rvalid;
  logic                  rready;

  // ----------------------------------------------------------------------
  // Clocking blocks
  // ----------------------------------------------------------------------

  clocking master_cb @(posedge aclk);
    default input #1step output #1;
    output awaddr, awprot, awvalid;
    input  awready;
    output wdata, wstrb, wvalid;
    input  wready;
    input  bresp, bvalid;
    output bready;
    output araddr, arprot, arvalid;
    input  arready;
    input  rdata, rresp, rvalid;
    output rready;
  endclocking

  clocking monitor_cb @(posedge aclk);
    default input #1step;
    input awaddr, awprot, awvalid, awready;
    input wdata, wstrb, wvalid, wready;
    input bresp, bvalid, bready;
    input araddr, arprot, arvalid, arready;
    input rdata, rresp, rvalid, rready;
    input aresetn;
  endclocking

  // ----------------------------------------------------------------------
  // Modports
  // ----------------------------------------------------------------------

  modport master_mp  (clocking master_cb,  input aclk, input aresetn);
  modport monitor_mp (clocking monitor_cb, input aclk, input aresetn);

  // ----------------------------------------------------------------------
  // Protocol assertions (SVA)
  // ----------------------------------------------------------------------
  //
  //a17: assert property (@(posedge aclk) $rose(aresetn) |-> !awvalid && !wvalid && arvalid;)
  // Handshake hold: VALID must stay high until READY
 /* property p_awvalid_hold;
    @(posedge aclk) disable iff (!aresetn)
    awvalid && !awready |=> awvalid;
  endproperty

  property p_wvalid_hold;
    @(posedge aclk) disable iff (!aresetn)
    wvalid && !wready |=> wvalid;
  endproperty

  property p_bvalid_hold;
    @(posedge aclk) disable iff (!aresetn)
    bvalid && !bready |=> bvalid;
  endproperty

  property p_arvalid_hold;
    @(posedge aclk) disable iff (!aresetn)
    arvalid && !arready |=> arvalid;
  endproperty

  property p_rvalid_hold;
    @(posedge aclk) disable iff (!aresetn)
    rvalid && !rready |=> rvalid;
  endproperty

  // Stability: payload must not change during stall
  property p_awaddr_stable;
    @(posedge aclk) disable iff (!aresetn)
    awvalid && !awready |=> $stable(awaddr);
  endproperty

  property p_wdata_stable;
    @(posedge aclk) disable iff (!aresetn)
    wvalid && !wready |=> $stable(wdata);
  endproperty

  property p_wstrb_stable;
    @(posedge aclk) disable iff (!aresetn)
    wvalid && !wready |=> $stable(wstrb);
  endproperty

  property p_araddr_stable;
    @(posedge aclk) disable iff (!aresetn)
    arvalid && !arready |=> $stable(araddr);
  endproperty

  property p_bresp_stable;
    @(posedge aclk) disable iff (!aresetn)
    bvalid && !bready |=> $stable(bresp);
  endproperty

  property p_rdata_stable;
    @(posedge aclk) disable iff (!aresetn)
    rvalid && !rready |=> $stable(rdata);
  endproperty

  property p_rresp_stable;
    @(posedge aclk) disable iff (!aresetn)
    rvalid && !rready |=> $stable(rresp);
  endproperty

  // No EXOKAY in AXI4-Lite
  property p_bresp_no_exokay;
    @(posedge aclk) disable iff (!aresetn)
    bvalid |-> bresp != 2'b01;
  endproperty

  property p_rresp_no_exokay;
    @(posedge aclk) disable iff (!aresetn)
    rvalid |-> rresp != 2'b01;
  endproperty

  // Reset: slave VALID signals must be low after reset
  property p_reset_bvalid;
    @(posedge aclk) !aresetn |=> !bvalid;
  endproperty

  property p_reset_rvalid;
    @(posedge aclk) !aresetn |=> !rvalid;
  endproperty

 a1: assert property (p_awvalid_hold)    else $error("AXI4LITE: AWVALID deasserted before AWREADY");
 a2: assert property (p_wvalid_hold)     else $error("AXI4LITE: WVALID deasserted before WREADY");
 a3: assert property (p_bvalid_hold)     else $error("AXI4LITE: BVALID deasserted before BREADY");
 a4: assert property (p_arvalid_hold)    else $error("AXI4LITE: ARVALID deasserted before ARREADY");
 a5: assert property (p_rvalid_hold)     else $error("AXI4LITE: RVALID deasserted before RREADY");
 a6: assert property (p_awaddr_stable)   else $error("AXI4LITE: AWADDR changed during stall");
 a7: assert property (p_wdata_stable)    else $error("AXI4LITE: WDATA changed during stall");
 a8: assert property (p_wstrb_stable)    else $error("AXI4LITE: WSTRB changed during stall");
 a9: assert property (p_araddr_stable)   else $error("AXI4LITE: ARADDR changed during stall");
 a10: assert property (p_bresp_stable)    else $error("AXI4LITE: BRESP changed during stall");
 a11: assert property (p_rdata_stable)    else $error("AXI4LITE: RDATA changed during stall");
 a12: assert property (p_rresp_stable)    else $error("AXI4LITE: RRESP changed during stall");
 a13: assert property (p_bresp_no_exokay) else $error("AXI4LITE: BRESP is EXOKAY (illegal)");
 a14: assert property (p_rresp_no_exokay) else $error("AXI4LITE: RRESP is EXOKAY (illegal)");
 a15: assert property (p_reset_bvalid)    else $error("AXI4LITE: BVALID not low after reset");
 a16: assert property (p_reset_rvalid)    else $error("AXI4LITE: RVALID not low after reset"); */

// ----------------------------------------------------------------------
  // Protocol assertions (SVA)
  // ----------------------------------------------------------------------

 // ----------------------------------------------------------------------
  // DUT-Specific SVA (axi4lite_slave_example.sv)
  // ----------------------------------------------------------------------

  // 1. Reset Behavior: All slave-driven signals initialize to 0[cite: 16, 20, 26, 33, 37].
  property p_reset_slave_signals;
    @(posedge aclk) !aresetn |=> (!awready && !wready && !arready && !bvalid && !rvalid);
  endproperty
  a1: assert property (p_reset_slave_signals) else $error("AXI4LITE: Slave signals not 0 after reset");

  // 2. Pulse Behavior: Ready signals in this specific RTL assert for exactly 1 cycle[cite: 18, 19, 23, 25, 35, 36].
  property p_awready_pulse;
    @(posedge aclk) disable iff (!aresetn)
    awready |=> !awready;
  endproperty
  a2: assert property (p_awready_pulse) else $error("AXI4LITE: AWREADY asserted for >1 cycle");

  property p_wready_pulse;
    @(posedge aclk) disable iff (!aresetn)
    wready |=> !wready;
  endproperty
  a3: assert property (p_wready_pulse) else $error("AXI4LITE: WREADY asserted for >1 cycle");

  property p_arready_pulse;
    @(posedge aclk) disable iff (!aresetn)
    arready |=> !arready;
  endproperty
  a4: assert property (p_arready_pulse) else $error("AXI4LITE: ARREADY asserted for >1 cycle");

  // 3. Handshake Deassertion: BVALID and RVALID clear immediately upon handshake[cite: 28, 38].
  property p_bvalid_clear;
    @(posedge aclk) disable iff (!aresetn)
    (bvalid && bready) |=> !bvalid;
  endproperty
  a5: assert property (p_bvalid_clear) else $error("AXI4LITE: BVALID did not deassert after BREADY");

  property p_rvalid_clear;
    @(posedge aclk) disable iff (!aresetn)
    (rvalid && rready) |=> !rvalid;
  endproperty
  a6: assert property (p_rvalid_clear) else $error("AXI4LITE: RVALID did not deassert after RREADY");

  // 4. Fixed Responses: BRESP and RRESP are statically driven to 2'b00 (OKAY)[cite: 27, 30, 38, 40].
  property p_bresp_okay;
    @(posedge aclk) disable iff (!aresetn)
    bvalid |-> (bresp == 2'b00);
  endproperty
  a7: assert property (p_bresp_okay) else $error("AXI4LITE: BRESP is not OKAY (2'b00)");

  property p_rresp_okay;
    @(posedge aclk) disable iff (!aresetn)
    rvalid |-> (rresp == 2'b00);
  endproperty
  a8: assert property (p_rresp_okay) else $error("AXI4LITE: RRESP is not OKAY (2'b00)");
endinterface
