// Top-level testbench for AXI4-Lite Slave UVM verification

`timescale 1ns/1ps

module tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import axi4lite_agent_pkg::*;
  import axi4lite_seq_pkg::*;
  import axi4lite_env_pkg::*;
  import axi4lite_test_pkg::*;

  // ----------------------------------------------------------------------
  // Parameters
  // ----------------------------------------------------------------------
  localparam ADDR_WIDTH = 4;
  localparam DATA_WIDTH = 32;
  localparam CLK_PERIOD = 10; // 100 MHz

  // ----------------------------------------------------------------------
  // Clock generation
  // ----------------------------------------------------------------------
  logic aclk;
  initial aclk = 1'b0;
  always #(CLK_PERIOD/2) aclk = ~aclk;

  // ----------------------------------------------------------------------
  // Interface instantiation
  // aresetn lives inside the interface as a logic signal so that
  // both tb_top and UVM classes can drive it.
  // ----------------------------------------------------------------------
  axi4lite_if #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
  ) axi_if (
    .aclk (aclk)
  );

  // ----------------------------------------------------------------------
  // DUT instantiation
  // ----------------------------------------------------------------------
  axi4lite_slave_example #(
    .C_AXI_DATA_WIDTH (DATA_WIDTH),
    .C_AXI_ADDR_WIDTH (ADDR_WIDTH)
  ) dut (
    .S_AXI_ACLK    (aclk),
    .S_AXI_ARESETN (axi_if.aresetn),

    .S_AXI_AWADDR  (axi_if.awaddr),
    .S_AXI_AWPROT  (axi_if.awprot),
    .S_AXI_AWVALID (axi_if.awvalid),
    .S_AXI_AWREADY (axi_if.awready),

    .S_AXI_WDATA   (axi_if.wdata),
    .S_AXI_WSTRB   (axi_if.wstrb),
    .S_AXI_WVALID  (axi_if.wvalid),
    .S_AXI_WREADY  (axi_if.wready),

    .S_AXI_BRESP   (axi_if.bresp),
    .S_AXI_BVALID  (axi_if.bvalid),
    .S_AXI_BREADY  (axi_if.bready),

    .S_AXI_ARADDR  (axi_if.araddr),
    .S_AXI_ARPROT  (axi_if.arprot),
    .S_AXI_ARVALID (axi_if.arvalid),
    .S_AXI_ARREADY (axi_if.arready),

    .S_AXI_RDATA   (axi_if.rdata),
    .S_AXI_RRESP   (axi_if.rresp),
    .S_AXI_RVALID  (axi_if.rvalid),
    .S_AXI_RREADY  (axi_if.rready)
  );

  // ----------------------------------------------------------------------
  // Config DB and UVM launch
  // ----------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual axi4lite_if)::set(null, "*", "vif", axi_if);
    run_test();
  end

  // ----------------------------------------------------------------------
  // Waveform dump (VCS)
  // ----------------------------------------------------------------------
  initial begin
    if ($test$plusargs("dump_waves")) begin
      $fsdbDumpfile("waves.fsdb");
      $fsdbDumpvars(0, tb_top, "+all");
      $fsdbDumpSVA;
    end
    if ($test$plusargs("dump_vpd")) begin
      $vcdpluson;
      $vcdplusmemon;
    end
  end

  // ----------------------------------------------------------------------
  // Timeout watchdog
  // ----------------------------------------------------------------------
  initial begin
    #1_000_000;
    `uvm_fatal("TIMEOUT", "Simulation timed out at 1ms")
  end

endmodule
