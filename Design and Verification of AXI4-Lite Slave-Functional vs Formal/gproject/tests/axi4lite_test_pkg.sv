// AXI4-Lite Test Package

package axi4lite_test_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import axi4lite_agent_pkg::*;
  import axi4lite_seq_pkg::*;
  import axi4lite_env_pkg::*;

  `include "axi4lite_base_test.sv"
  `include "axi4lite_write_test.sv"
  `include "axi4lite_read_test.sv"
  `include "axi4lite_b2b_test.sv"
  `include "axi4lite_strobe_test.sv"
  `include "axi4lite_prot_test.sv"
  `include "axi4lite_delay_test.sv"
  `include "axi4lite_data_pattern_test.sv"
  `include "axi4lite_random_test.sv"
  `include "axi4lite_reset_test.sv"
  `include "axi4lite_rand_delay_test.sv"
  `include "axi4lite_full_coverage_test.sv"

endpackage
