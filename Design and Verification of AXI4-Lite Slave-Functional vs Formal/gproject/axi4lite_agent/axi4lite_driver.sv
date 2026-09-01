// AXI4-Lite Master Driver
//
// Drives write (AW+W+B) and read (AR+R) transactions on the AXI4-Lite
// interface. Supports configurable inter-channel delays.

class axi4lite_driver extends uvm_driver #(axi4lite_seq_item);

  `uvm_component_utils(axi4lite_driver)

  virtual axi4lite_if vif;

  function new(string name = "axi4lite_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4lite_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for axi4lite_driver")
  endfunction

  task run_phase(uvm_phase phase);
    // Initialize all master outputs to idle
    reset_signals();

    forever begin
      // Wait for reset to deassert
      wait (vif.aresetn === 1'b1);
    //  @(posedge vif.aclk);

      seq_item_port.get_next_item(req);
      `uvm_info("DRV", $sformatf("Driving: %s", req.convert2string()), UVM_HIGH)

      if (req.dir == AXI4LITE_WRITE)
        drive_write(req);
      else
        drive_read(req);

      seq_item_port.item_done();
    end
  endtask

  // ----------------------------------------------------------------------
  // Reset all master-driven signals
  // ----------------------------------------------------------------------
  task reset_signals();
    vif.master_cb.awvalid <= 1'b0;
    vif.master_cb.awaddr  <= '0;
    vif.master_cb.awprot  <= '0;
    vif.master_cb.wvalid  <= 1'b0;
    vif.master_cb.wdata   <= '0;
    vif.master_cb.wstrb   <= '0;
    vif.master_cb.bready  <= 1'b0;
    vif.master_cb.arvalid <= 1'b0;
    vif.master_cb.araddr  <= '0;
    vif.master_cb.arprot  <= '0;
    vif.master_cb.rready  <= 1'b0;
  endtask

  // ----------------------------------------------------------------------
  // Write transaction: AW and W driven concurrently, then wait B
  // ----------------------------------------------------------------------
  task drive_write(axi4lite_seq_item item);
    fork
      drive_aw_channel(item);
      drive_w_channel(item);
    //join

    // Wait for write response
    drive_b_channel(item);
   join
  endtask

  task drive_aw_channel(axi4lite_seq_item item);
    // Pre-valid delay
    repeat (item.addr_delay) @(posedge vif.aclk);

    vif.master_cb.awaddr  <= item.addr;
    vif.master_cb.awprot  <= item.prot;
    vif.master_cb.awvalid <= 1'b1;

    // Wait for handshake
    do @(posedge vif.aclk);
    while (vif.master_cb.awready !== 1'b1);

    vif.master_cb.awvalid <= 1'b0;
    vif.master_cb.awaddr  <= '0;
    vif.master_cb.awprot  <= '0;
  endtask

  task drive_w_channel(axi4lite_seq_item item);
    // Pre-valid delay
    repeat (item.data_delay) @(posedge vif.aclk);

    vif.master_cb.wdata  <= item.data;
    vif.master_cb.wstrb  <= item.strb;
    vif.master_cb.wvalid <= 1'b1;

    // Wait for handshake
    do @(posedge vif.aclk);
    while (vif.master_cb.wready !== 1'b1);

    vif.master_cb.wvalid <= 1'b0;
    vif.master_cb.wdata  <= '0;
    vif.master_cb.wstrb  <= '0;
  endtask

  task drive_b_channel(axi4lite_seq_item item);
    // Pre-ready delay
    repeat (item.resp_delay) @(posedge vif.aclk);

    vif.master_cb.bready <= 1'b1;

    // Wait for BVALID
    do @(posedge vif.aclk);
    while (vif.master_cb.bvalid !== 1'b1);

    item.resp = axi4lite_resp_t'(vif.master_cb.bresp);

    vif.master_cb.bready <= 1'b0;
  endtask

  // ----------------------------------------------------------------------
  // Read transaction: AR then R
  // ----------------------------------------------------------------------
  task drive_read(axi4lite_seq_item item);
    // Pre-valid delay
    fork
    begin
    repeat (item.addr_delay) @(posedge vif.aclk);

    vif.master_cb.araddr  <= item.addr;
    vif.master_cb.arprot  <= item.prot;
    vif.master_cb.arvalid <= 1'b1;

    // Wait for handshake
    do @(posedge vif.aclk);
    while (vif.master_cb.arready !== 1'b1);

    vif.master_cb.arvalid <= 1'b0;
    vif.master_cb.araddr  <= '0;
    vif.master_cb.arprot  <= '0;
    end
    // Pre-ready delay for read data
    begin
    repeat (item.resp_delay) @(posedge vif.aclk);

    vif.master_cb.rready <= 1'b1;

    // Wait for RVALID
    do @(posedge vif.aclk);
    while (vif.master_cb.rvalid !== 1'b1);

    item.rdata = vif.master_cb.rdata;
    item.resp  = axi4lite_resp_t'(vif.master_cb.rresp);

    vif.master_cb.rready <= 1'b0;
   end
   join
  endtask

endclass
