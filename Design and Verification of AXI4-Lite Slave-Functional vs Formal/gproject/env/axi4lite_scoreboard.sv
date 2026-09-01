// AXI4-Lite Scoreboard
//
// Contains a register-file reference model that mirrors the DUT.
// Checks every write response and read-data against expected values.

// Analysis imp declarations must precede the class that uses them
`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)

class axi4lite_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi4lite_scoreboard)

  uvm_analysis_imp_wr #(axi4lite_seq_item, axi4lite_scoreboard) wr_imp;
  uvm_analysis_imp_rd #(axi4lite_seq_item, axi4lite_scoreboard) rd_imp;

  // Reference model: 4 x 32-bit registers
  localparam NUM_REGS = 4;
  localparam ADDR_LSB = 2; // $clog2(32/8)
  localparam REG_BITS = 2; // $clog2(4)

  bit [31:0] ref_regs [NUM_REGS];

  // Statistics
  int unsigned wr_count;
  int unsigned rd_count;
  int unsigned wr_pass;
  int unsigned wr_fail;
  int unsigned rd_pass;
  int unsigned rd_fail;

  function new(string name = "axi4lite_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_imp = new("wr_imp", this);
    rd_imp = new("rd_imp", this);
  endfunction

  function void reset_ref_model();
    for (int i = 0; i < NUM_REGS; i++)
      ref_regs[i] = 32'h0;
    `uvm_info("SCB", "Reference model reset", UVM_MEDIUM)
  endfunction

  // ----------------------------------------------------------------------
  // Write transaction handler
  // ----------------------------------------------------------------------
  function void write_wr(axi4lite_seq_item t);
    int unsigned reg_idx;
    wr_count++;

    reg_idx = t.addr[ADDR_LSB +: REG_BITS];

    if (t.resp == AXI_RESP_OKAY) begin
      // Apply write with byte strobes to reference model
      for (int i = 0; i < 4; i++) begin
        if (t.strb[i])
          ref_regs[reg_idx][i*8 +: 8] = t.data[i*8 +: 8];
      end
      wr_pass++;
      `uvm_info("SCB", $sformatf("WRITE OK: reg[%0d] = 0x%08h (strb=0b%04b)",
                                 reg_idx, ref_regs[reg_idx], t.strb), UVM_HIGH)
    end else begin
      `uvm_info("SCB", $sformatf("WRITE resp=%s at addr=0x%0h",
                                 t.resp.name(), t.addr), UVM_MEDIUM)
      wr_pass++;
    end
  endfunction

  // ----------------------------------------------------------------------
  // Read transaction handler
  // ----------------------------------------------------------------------
  function void write_rd(axi4lite_seq_item t);
    int unsigned reg_idx;
    bit [31:0] expected;
    rd_count++;

    reg_idx = t.addr[ADDR_LSB +: REG_BITS];
    expected = ref_regs[reg_idx];

    if (t.resp == AXI_RESP_OKAY) begin
      if (t.rdata === expected) begin
        rd_pass++;
        `uvm_info("SCB", $sformatf("READ PASS: reg[%0d] addr=0x%0h exp=0x%08h got=0x%08h",
                                   reg_idx, t.addr, expected, t.rdata), UVM_HIGH)
      end else begin
        rd_fail++;
        `uvm_error("SCB", $sformatf("READ MISMATCH: reg[%0d] addr=0x%0h exp=0x%08h got=0x%08h",
                                    reg_idx, t.addr, expected, t.rdata))
      end
    end else begin
      `uvm_info("SCB", $sformatf("READ resp=%s at addr=0x%0h",
                                 t.resp.name(), t.addr), UVM_MEDIUM)
      rd_pass++;
    end
  endfunction

  // ----------------------------------------------------------------------
  // Report
  // ----------------------------------------------------------------------
  function void report_phase(uvm_phase phase);
    `uvm_info("SCB", "=== Scoreboard Summary ===", UVM_LOW)
    `uvm_info("SCB", $sformatf("  Writes: %0d total, %0d pass, %0d fail",
                               wr_count, wr_pass, wr_fail), UVM_LOW)
    `uvm_info("SCB", $sformatf("  Reads : %0d total, %0d pass, %0d fail",
                               rd_count, rd_pass, rd_fail), UVM_LOW)

    if (wr_fail > 0 || rd_fail > 0)
      `uvm_error("SCB", $sformatf("TEST FAILED: %0d write failures, %0d read failures",
                                  wr_fail, rd_fail))
    else
      `uvm_info("SCB", "ALL CHECKS PASSED", UVM_LOW)
  endfunction

endclass
