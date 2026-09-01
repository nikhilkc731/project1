// AXI4-Lite Environment Package

package axi4lite_env_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import axi4lite_agent_pkg::*;

  `include "axi4lite_scoreboard.sv"
  `include "axi4lite_virtual_sequencer.sv"
  `include "axi4lite_env.sv"

endpackage
