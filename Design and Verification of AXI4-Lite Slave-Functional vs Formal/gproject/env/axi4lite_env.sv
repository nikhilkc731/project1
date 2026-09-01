// AXI4-Lite Verification Environment

class axi4lite_env extends uvm_env;

  `uvm_component_utils(axi4lite_env)

  axi4lite_agent             agt;
  axi4lite_scoreboard        scb;
  axi4lite_virtual_sequencer vsqr;

  function new(string name = "axi4lite_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt  = axi4lite_agent::type_id::create("agt", this);
    scb  = axi4lite_scoreboard::type_id::create("scb", this);
    vsqr = axi4lite_virtual_sequencer::type_id::create("vsqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Monitor analysis ports -> scoreboard
    agt.mon.wr_ap.connect(scb.wr_imp);
    agt.mon.rd_ap.connect(scb.rd_imp);

    // Virtual sequencer -> agent sequencer
    vsqr.axi_sqr = agt.sqr;
  endfunction

endclass
