// Reset test - asserts reset mid-operation and verifies recovery

class axi4lite_reset_test extends axi4lite_base_test;

  `uvm_component_utils(axi4lite_reset_test)

  function new(string name = "axi4lite_reset_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_sequences(uvm_phase phase);
    axi4lite_reset_seq seq;
    seq = axi4lite_reset_seq::type_id::create("seq");
    seq.start(env.vsqr.axi_sqr);

    // Reset the scoreboard reference model since DUT was reset
    env.scb.reset_ref_model();

    // Run a few more transactions to confirm DUT is functional
    begin
      axi4lite_single_write_seq wr_seq;
      wr_seq = axi4lite_single_write_seq::type_id::create("wr_seq");
      wr_seq.start(env.vsqr.axi_sqr);
    end
  endtask

endclass
