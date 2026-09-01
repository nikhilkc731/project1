// Exercises various inter-channel delay combinations to cover
// timing-related scenarios (zero-delay, stalls, backpressure).

class axi4lite_delay_seq extends axi4lite_base_seq;

  `uvm_object_utils(axi4lite_delay_seq)

  function new(string name = "axi4lite_delay_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] rdata;

    `uvm_info("SEQ", "=== Delay Variation Sequence ===", UVM_LOW)

    // Zero-delay (fastest path)
    axi_write(32'h0, 32'hAAAA_AAAA, 4'hF, 3'b000, 0, 0, 0);
    axi_read(32'h0, rdata, 3'b000, 0, 0);

    // AW arrives before W (addr_delay=0, data_delay=3)
    axi_write(32'h4, 32'hBBBB_BBBB, 4'hF, 3'b000, 0, 3, 0);
    axi_read(32'h4, rdata);

    // W arrives before AW (addr_delay=3, data_delay=0)
    axi_write(32'h8, 32'hCCCC_CCCC, 4'hF, 3'b000, 3, 0, 0);
    axi_read(32'h8, rdata);

    // Delayed BREADY (resp_delay=5)
    axi_write(32'hC, 32'hDDDD_DDDD, 4'hF, 3'b000, 0, 0, 5);
    axi_read(32'hC, rdata, 3'b000, 0, 5);

    // All delays active
    axi_write(32'h0, 32'hEEEE_EEEE, 4'hF, 3'b000, 2, 4, 3);
    axi_read(32'h0, rdata, 3'b000, 2, 3);

    // Long delays
    axi_write(32'h4, 32'h1111_1111, 4'hF, 3'b000, 5, 5, 5);
    axi_read(32'h4, rdata, 3'b000, 5, 5);
  endtask

endclass
