// AXI4-Lite Virtual Sequencer

class axi4lite_virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils(axi4lite_virtual_sequencer)

  axi4lite_sequencer axi_sqr;

  function new(string name = "axi4lite_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass
