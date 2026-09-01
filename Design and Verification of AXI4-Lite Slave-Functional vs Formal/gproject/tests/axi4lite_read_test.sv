// Read test - reads all registers after reset (expect zeros)

class axi4lite_read_test extends axi4lite_base_test;

  `uvm_component_utils(axi4lite_read_test)

  function new(string name = "axi4lite_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_sequences(uvm_phase phase);
    axi4lite_single_read_seq seq;
    seq = axi4lite_single_read_seq::type_id::create("seq");
    seq.start(env.vsqr.axi_sqr);
  endtask

endclass
