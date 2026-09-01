// Back-to-back test - covers WW, WR, RW, RR ordering

class axi4lite_b2b_test extends axi4lite_base_test;

  `uvm_component_utils(axi4lite_b2b_test)

  function new(string name = "axi4lite_b2b_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_sequences(uvm_phase phase);
    axi4lite_write_read_b2b_seq seq;
    seq = axi4lite_write_read_b2b_seq::type_id::create("seq");
    seq.start(env.vsqr.axi_sqr);
  endtask

endclass
