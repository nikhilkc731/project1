// Read all 4 registers (initial values should be 0 after reset)

class axi4lite_single_read_seq extends axi4lite_base_seq;

  `uvm_object_utils(axi4lite_single_read_seq)

  function new(string name = "axi4lite_single_read_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] rdata;
    bit [31:0] addrs [$] = '{32'h0, 32'h4, 32'h8, 32'hC};

    `uvm_info("SEQ", "=== Single Read Sequence (post-reset) ===", UVM_LOW)

    foreach (addrs[i]) begin
      axi_read(addrs[i], rdata);
      `uvm_info("SEQ", $sformatf("Read 0x%08h from addr 0x%0h", rdata, addrs[i]), UVM_MEDIUM)
    end
  endtask

endclass
