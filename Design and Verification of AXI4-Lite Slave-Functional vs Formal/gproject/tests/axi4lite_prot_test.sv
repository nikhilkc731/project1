// Protection type test - all 8 PROT values on read and write

class axi4lite_prot_test extends axi4lite_base_test;

  `uvm_component_utils(axi4lite_prot_test)

  function new(string name = "axi4lite_prot_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_sequences(uvm_phase phase);
    axi4lite_prot_seq seq;
    seq = axi4lite_prot_seq::type_id::create("seq");
    seq.start(env.vsqr.axi_sqr);
  endtask

endclass
