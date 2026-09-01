// ============================================================================
// fvip_top.sv
//
// Formal Verification Top-Level Wrapper
// Instantiates:
//   1. axi4lite_slave_example  — DUT
//   2. fvip_axi4lite_props     — property / assumption module
//
// No `ifdef.  No bind.  Both modules wired through explicit port connections.
// This file is the sole top-level module passed to SymbiYosys.
// ============================================================================

`default_nettype none

module fvip_top #(
    parameter C_AXI_DATA_WIDTH = 32,
    parameter C_AXI_ADDR_WIDTH = 4
) ((* gclk *) input clk);

    // -------------------------------------------------------------------------
    // Free clock / reset
    // Declared as reg so SymbiYosys treats them as unconstrained inputs that
    // the solver may assign freely each cycle.  The property module's
    // "assume(!aresetn)" in cycle-0 anchors the reset sequence.
    // -------------------------------------------------------------------------
    //(* gclk *) input clk;
    (* keep *) reg aresetn;

    // -------------------------------------------------------------------------
    // AXI4-Lite signal wires — master-side signals are free (reg),
    // slave-side outputs are driven by the DUT (wire).
    // -------------------------------------------------------------------------

    // --- Write Address channel ---
    (* keep *) reg  [C_AXI_ADDR_WIDTH-1:0]       awaddr;
    (* keep *) reg  [2:0]                        awprot;
    (* keep *) reg                               awvalid;
    wire                              awready;

    // --- Write Data channel ---
    (* keep *) reg  [C_AXI_DATA_WIDTH-1:0]       wdata;
    (* keep *) reg  [(C_AXI_DATA_WIDTH/8)-1:0]   wstrb;
    (* keep *) reg                               wvalid;
     wire                              wready;

    // --- Write Response channel ---
    wire [1:0]                        bresp;
    wire                              bvalid;
    (* keep *) reg                               bready;

    // --- Read Address channel ---
    (* keep *) reg  [C_AXI_ADDR_WIDTH-1:0]       araddr;
    (* keep *) reg  [2:0]                        arprot;
    (* keep *) reg                               arvalid;
     wire                              arready;

    // --- Read Data channel ---
    wire [C_AXI_DATA_WIDTH-1:0]       rdata;
    wire [1:0]                        rresp;
    wire                              rvalid;
    (* keep *) reg                               rready;

    // =========================================================================
    // DUT instantiation
    // =========================================================================
    axi4lite_slave_example #(
        .C_AXI_DATA_WIDTH (C_AXI_DATA_WIDTH),
        .C_AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH)
    ) u_dut (
        .S_AXI_ACLK     (clk),
        .S_AXI_ARESETN  (aresetn),

        .S_AXI_AWADDR   (awaddr),
        .S_AXI_AWPROT   (awprot),
        .S_AXI_AWVALID  (awvalid),
        .S_AXI_AWREADY  (awready),

        .S_AXI_WDATA    (wdata),
        .S_AXI_WSTRB    (wstrb),
        .S_AXI_WVALID   (wvalid),
        .S_AXI_WREADY   (wready),

        .S_AXI_BRESP    (bresp),
        .S_AXI_BVALID   (bvalid),
        .S_AXI_BREADY   (bready),

        .S_AXI_ARADDR   (araddr),
        .S_AXI_ARPROT   (arprot),
        .S_AXI_ARVALID  (arvalid),
        .S_AXI_ARREADY  (arready),

        .S_AXI_RDATA    (rdata),
        .S_AXI_RRESP    (rresp),
        .S_AXI_RVALID   (rvalid),
        .S_AXI_RREADY   (rready)
    );

    // =========================================================================
    // Properties module instantiation
    // =========================================================================
    fvip_axi4lite_props #(
        .C_AXI_DATA_WIDTH (C_AXI_DATA_WIDTH),
        .C_AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH),
        .NUM_REGS         (4)
    ) u_props (
        .clk      (clk),
        .aresetn  (aresetn),

        .awaddr   (awaddr),
        .awprot   (awprot),
        .awvalid  (awvalid),
        .awready  (awready),

        .wdata    (wdata),
        .wstrb    (wstrb),
        .wvalid   (wvalid),
        .wready   (wready),

        .bresp    (bresp),
        .bvalid   (bvalid),
        .bready   (bready),

        .araddr   (araddr),
        .arprot   (arprot),
        .arvalid  (arvalid),
        .arready  (arready),

        .rdata    (rdata),
        .rresp    (rresp),
        .rvalid   (rvalid),
        .rready   (rready)
    );

endmodule

`default_nettype wire

