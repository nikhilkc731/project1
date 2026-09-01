// AXI4-Lite Sequence Library Package

package axi4lite_seq_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import axi4lite_agent_pkg::*;

  `include "axi4lite_base_seq.sv"
  `include "axi4lite_single_write_seq.sv"
  `include "axi4lite_single_read_seq.sv"
  `include "axi4lite_write_read_b2b_seq.sv"
  `include "axi4lite_strobe_seq.sv"
  `include "axi4lite_prot_seq.sv"
  `include "axi4lite_delay_seq.sv"
  `include "axi4lite_data_pattern_seq.sv"
  `include "axi4lite_random_seq.sv"
  `include "axi4lite_reset_seq.sv"
  `include "axi4lite_rand_delay_seq.sv"

endpackage
