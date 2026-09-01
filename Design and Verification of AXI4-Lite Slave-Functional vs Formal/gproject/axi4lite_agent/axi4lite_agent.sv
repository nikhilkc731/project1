// AXI4-Lite Agent
//
// Configurable as ACTIVE (driver + sequencer + monitor) or
// PASSIVE (monitor only). Always includes coverage collector.

class axi4lite_agent extends uvm_agent;

  `uvm_component_utils(axi4lite_agent)

  axi4lite_driver    drv;
  axi4lite_sequencer sqr;
  axi4lite_monitor   mon;
  axi4lite_coverage  cov;

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  function new(string name = "axi4lite_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Allow override from config_db
    uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active);

    mon = axi4lite_monitor::type_id::create("mon", this);
    cov = axi4lite_coverage::type_id::create("cov", this);

    if (is_active == UVM_ACTIVE) begin
      drv = axi4lite_driver::type_id::create("drv", this);
      sqr = axi4lite_sequencer::type_id::create("sqr", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Monitor -> coverage
    mon.ap.connect(cov.analysis_export);

    if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
  endfunction

endclass
