// Write to all 4 registers with full strobe, then read back and verify

class axi4lite_single_write_seq extends axi4lite_base_seq;

  `uvm_object_utils(axi4lite_single_write_seq)

  function new(string name = "axi4lite_single_write_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] rdata;
    bit [31:0] addrs [$] = '{32'h0, 32'h4, 32'h8, 32'hC};
    bit [31:0] wdata [$] = '{32'hDEAD_BEEF, 32'hCAFE_BABE, 32'h1234_5678, 32'hA5A5_A5A5};

    `uvm_info("SEQ", "=== Single Write Sequence ===", UVM_LOW)

    foreach (addrs[i]) begin
      axi_write(addrs[i], wdata[i]);
      `uvm_info("SEQ", $sformatf("Wrote 0x%08h to addr 0x%0h", wdata[i], addrs[i]), UVM_MEDIUM)
    end

    // Read back
    foreach (addrs[i]) begin
      axi_read(addrs[i], rdata);
      `uvm_info("SEQ", $sformatf("Read 0x%08h from addr 0x%0h (exp 0x%08h)",
                                 rdata, addrs[i], wdata[i]), UVM_MEDIUM)
    end
  endtask

endclass
