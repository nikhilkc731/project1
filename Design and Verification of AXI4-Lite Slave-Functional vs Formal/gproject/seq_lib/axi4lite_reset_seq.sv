// Reset sequence - asserts reset mid-operation, then verifies
// the DUT returns to a clean state.

class axi4lite_reset_seq extends axi4lite_base_seq;

  `uvm_object_utils(axi4lite_reset_seq)

  virtual axi4lite_if vif;

  function new(string name = "axi4lite_reset_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] rdata;

    if (!uvm_config_db#(virtual axi4lite_if)::get(null, "", "vif", vif))
      `uvm_fatal("SEQ", "Virtual interface not found for reset sequence")

    `uvm_info("SEQ", "=== Reset Sequence ===", UVM_LOW)

    // Write some data
   // axi_write(32'h0, 32'hDEAD_BEEF);
    //axi_write(32'h4, 32'hCAFE_BABE);

    // Assert reset via interface signal
    `uvm_info("SEQ", "Asserting reset...", UVM_MEDIUM)
    vif.aresetn = 1'b0;

    // Idle master signals during reset
    vif.awvalid = 1'b0;
    vif.wvalid  = 1'b0;
    vif.bready  = 1'b0;
    vif.arvalid = 1'b0;
    vif.rready  = 1'b0;

    repeat (10) @(posedge vif.aclk);
    vif.aresetn = 1'b1;
    repeat (5) @(posedge vif.aclk);
    `uvm_info("SEQ", "Reset released", UVM_MEDIUM)

    // Read back - registers should be 0 after reset
    axi_read(32'h0, rdata);
    if (rdata !== 32'h0)
      `uvm_error("SEQ", $sformatf("Post-reset reg0 = 0x%08h, expected 0x00000000", rdata))

    axi_read(32'h4, rdata);
    if (rdata !== 32'h0)
      `uvm_error("SEQ", $sformatf("Post-reset reg1 = 0x%08h, expected 0x00000000", rdata))

    // Write after reset to confirm functionality restored
    axi_write(32'h0, 32'h1234_5678);
    axi_read(32'h0, rdata);
    if (rdata !== 32'h1234_5678)
      `uvm_error("SEQ", $sformatf("Post-reset write/read failed: got 0x%08h", rdata))
  endtask

endclass
