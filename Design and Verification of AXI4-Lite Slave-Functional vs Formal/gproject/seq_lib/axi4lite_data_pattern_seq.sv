// Exercises boundary and special data patterns to hit cg_write_data bins.

class axi4lite_data_pattern_seq extends axi4lite_base_seq;

  `uvm_object_utils(axi4lite_data_pattern_seq)

  function new(string name = "axi4lite_data_pattern_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] rdata;
    bit [31:0] patterns [$] = '{
      32'h0000_0000,  // zero
      32'hFFFF_FFFF,  // all ones
      32'h0000_0001,  // walking 1 bit 0
      32'h8000_0000,  // walking 1 bit 31
      32'h5A5A_5A5A,  // alternating
      32'hA5A5_A5A5,  // alternating inverse
      32'h0000_000F,  // low nibble
      32'h0000_ABCD,  // mid range
      32'hFEDC_BA98   // high range
    };

    `uvm_info("SEQ", "=== Data Pattern Sequence ===", UVM_LOW)

    foreach (patterns[i]) begin
      axi_write(32'h0, patterns[i]);
      axi_read(32'h0, rdata);
      `uvm_info("SEQ", $sformatf("pattern=0x%08h readback=0x%08h", patterns[i], rdata), UVM_MEDIUM)
    end
  endtask

endclass
