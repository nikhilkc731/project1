// AXI4-Lite Base Test
//
// Builds the environment, handles reset, and provides the
// framework for all derived tests.

class axi4lite_base_test extends uvm_test;

  `uvm_component_utils(axi4lite_base_test)

  axi4lite_env env;
  virtual axi4lite_if vif;

  function new(string name = "axi4lite_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual axi4lite_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found in config_db")

    env = axi4lite_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this, "base_test");

    // Apply reset
    apply_reset();

    // Derived tests override run_sequences()
    run_sequences(phase);

    // Drain time
    #100;
    phase.drop_objection(this, "base_test");
  endtask

  // ----------------------------------------------------------------------
  // Reset: drive aresetn and idle all master signals via interface
  // ----------------------------------------------------------------------
  virtual task apply_reset();
    `uvm_info("TEST", "Applying reset...", UVM_MEDIUM)
    vif.aresetn = 1'b0;

    // Drive all master signals to idle during reset
    vif.awvalid = 1'b0;
    vif.awaddr  = '0;
    vif.awprot  = '0;
    vif.wvalid  = 1'b0;
    vif.wdata   = '0;
    vif.wstrb   = '0;
    vif.bready  = 1'b0;
    vif.arvalid = 1'b0;
    vif.araddr  = '0;
    vif.arprot  = '0;
    vif.rready  = 1'b0;

    repeat (20) @(posedge vif.aclk);
    vif.aresetn = 1'b1;
    repeat (5) @(posedge vif.aclk);
    `uvm_info("TEST", "Reset released", UVM_MEDIUM)
  endtask

  virtual task run_sequences(uvm_phase phase);
    // Override in derived tests
  endtask

  function void report_phase(uvm_phase phase);
    uvm_report_server srv = uvm_report_server::get_server();
    int unsigned err_count = srv.get_severity_count(UVM_ERROR);
    int unsigned fat_count = srv.get_severity_count(UVM_FATAL);

    `uvm_info("TEST", "==================================================", UVM_LOW)
    if (err_count == 0 && fat_count == 0)
      `uvm_info("TEST", "                  TEST PASSED                     ", UVM_LOW)
    else
      `uvm_info("TEST", $sformatf("                  TEST FAILED (%0d errors, %0d fatals)",
                                  err_count, fat_count), UVM_LOW)
    `uvm_info("TEST", "==================================================", UVM_LOW)
  endfunction

endclass
