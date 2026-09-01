// Random test - fully randomized transactions to fill coverage holes

class axi4lite_random_test extends axi4lite_base_test;

  `uvm_component_utils(axi4lite_random_test)

  function new(string name = "axi4lite_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_sequences(uvm_phase phase);
    axi4lite_random_seq seq;
    seq = axi4lite_random_seq::type_id::create("seq");
    assert(seq.randomize() with { num_txns == 200; }) else
      `uvm_fatal("TEST", "Failed to randomize random sequence")
    seq.start(env.vsqr.axi_sqr);
  endtask

endclass
