// AXI4-Lite Monitor
//
// Passively observes all 5 AXI4-Lite channels and reconstructs
// complete write and read transactions. Publishes via analysis ports.

/*class axi4lite_monitor extends uvm_monitor;

  `uvm_component_utils(axi4lite_monitor)

  virtual axi4lite_if vif;

  uvm_analysis_port #(axi4lite_seq_item) ap;       // complete transactions
  uvm_analysis_port #(axi4lite_seq_item) wr_ap;    // write transactions only
  uvm_analysis_port #(axi4lite_seq_item) rd_ap;    // read transactions only

  // Handshake event counters (exposed for coverage)
  int unsigned aw_count, w_count, b_count, ar_count, r_count;

  function new(string name = "axi4lite_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap    = new("ap", this);
    wr_ap = new("wr_ap", this);
    rd_ap = new("rd_ap", this);
    if (!uvm_config_db#(virtual axi4lite_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for axi4lite_monitor")
  endfunction

  task run_phase(uvm_phase phase);
    aw_count = 0; w_count = 0; b_count = 0;
    ar_count = 0; r_count = 0;

    forever begin
      wait (vif.aresetn === 1'b1);
      fork
        monitor_writes();
        monitor_reads();
        detect_reset();
      join_any
      disable fork;
    end
  endtask

  // ----------------------------------------------------------------------
  // Write monitor: collect AW, W, then B
  // ----------------------------------------------------------------------
  task monitor_writes();
    axi4lite_seq_item item;
    bit [31:0] aw_addr;
    bit [2:0]  aw_prot;
    bit [31:0] w_data;
    bit [3:0]  w_strb;

    forever begin
      // Collect AW and W in parallel (they can arrive in any order)
      fork
        begin // AW channel
          forever begin
            @(posedge vif.aclk);
            if (vif.monitor_cb.awvalid && vif.monitor_cb.awready) begin
              aw_addr = vif.monitor_cb.awaddr;
              aw_prot = vif.monitor_cb.awprot;
              aw_count++;
              break;
            end
          end
        end
        begin // W channel
          forever begin
            @(posedge vif.aclk);
            if (vif.monitor_cb.wvalid && vif.monitor_cb.wready) begin
              w_data = vif.monitor_cb.wdata;
              w_strb = vif.monitor_cb.wstrb;
              w_count++;
              break;
            end
          end
        end
      join

      // Wait for B channel
      forever begin
        @(posedge vif.aclk);
        if (vif.monitor_cb.bvalid && vif.monitor_cb.bready) begin
          b_count++;
          break;
        end
      end

      // Build transaction
      item = axi4lite_seq_item::type_id::create("wr_item");
      item.dir   = AXI4LITE_WRITE;
      item.addr  = aw_addr;
      item.prot  = aw_prot;
      item.data  = w_data;
      item.strb  = w_strb;
      item.resp  = axi4lite_resp_t'(vif.monitor_cb.bresp);
      item.rdata = '0;

      `uvm_info("MON", $sformatf("Write observed: %s", item.convert2string()), UVM_HIGH)
      ap.write(item);
      wr_ap.write(item);
    end
  endtask

  // ----------------------------------------------------------------------
  // Read monitor: collect AR then R
  // ----------------------------------------------------------------------
  task monitor_reads();
    axi4lite_seq_item item;

    forever begin
      // Wait for AR handshake
      forever begin
        @(posedge vif.aclk);
        if (vif.monitor_cb.arvalid && vif.monitor_cb.arready) begin
          ar_count++;
          break;
        end
      end

      item = axi4lite_seq_item::type_id::create("rd_item");
      item.dir  = AXI4LITE_READ;
      item.addr = vif.monitor_cb.araddr;
      item.prot = vif.monitor_cb.arprot;

      // Wait for R handshake
      forever begin
        @(posedge vif.aclk);
        if (vif.monitor_cb.rvalid && vif.monitor_cb.rready) begin
          r_count++;
          break;
        end
      end

      item.rdata = vif.monitor_cb.rdata;
      item.resp  = axi4lite_resp_t'(vif.monitor_cb.rresp);
      item.data  = item.rdata;

      `uvm_info("MON", $sformatf("Read observed: %s", item.convert2string()), UVM_HIGH)
      ap.write(item);
      rd_ap.write(item);
    end
  endtask

  // ----------------------------------------------------------------------
  // Reset detection - kills monitor threads on reset assertion
  // ----------------------------------------------------------------------
  task detect_reset();
    @(negedge vif.aresetn);
    `uvm_info("MON", "Reset asserted - monitor restarting", UVM_MEDIUM)
  endtask

endclass */

// AXI4-Lite Monitor
//
// Passively observes all 5 AXI4-Lite channels and reconstructs
// complete write and read transactions. Publishes via analysis ports.

class axi4lite_monitor extends uvm_monitor;

  `uvm_component_utils(axi4lite_monitor)

  virtual axi4lite_if vif;

  uvm_analysis_port #(axi4lite_seq_item) ap;       // complete transactions
  uvm_analysis_port #(axi4lite_seq_item) wr_ap;    // write transactions only
  uvm_analysis_port #(axi4lite_seq_item) rd_ap;    // read transactions only

  // Handshake event counters (exposed for coverage)
  int unsigned aw_count, w_count, b_count, ar_count, r_count;

  function new(string name = "axi4lite_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap    = new("ap", this);
    wr_ap = new("wr_ap", this);
    rd_ap = new("rd_ap", this);
    if (!uvm_config_db#(virtual axi4lite_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for axi4lite_monitor")
  endfunction

  task run_phase(uvm_phase phase);
    aw_count = 0; w_count = 0; b_count = 0;
    ar_count = 0; r_count = 0;

    forever begin
      wait (vif.aresetn === 1'b1);
      fork
        monitor_writes();
        monitor_reads();
        detect_reset();
      join_any
      disable fork;
    end
  endtask

  // ----------------------------------------------------------------------
  // Write monitor: collect AW, W, then B with delay profiling
  // ----------------------------------------------------------------------
  task monitor_writes();
    axi4lite_seq_item item;
    bit [31:0] aw_addr;
    bit [2:0]  aw_prot;
    bit [31:0] w_data;
    bit [3:0]  w_strb;
    int a_delay, d_delay, r_delay;

    forever begin
      a_delay = 0;
      d_delay = 0;
      r_delay = 0;

      // Collect AW and W in parallel (they can arrive in any order)
      fork
        begin // AW channel
          forever begin
            @(posedge vif.aclk);
            if (vif.monitor_cb.awvalid && vif.monitor_cb.awready) begin
              aw_addr = vif.monitor_cb.awaddr;
              aw_prot = vif.monitor_cb.awprot;
              aw_count++;
              break;
            end else if (!vif.monitor_cb.awvalid) begin
              a_delay++;
            end
          end
        end
        begin // W channel
          forever begin
            @(posedge vif.aclk);
            if (vif.monitor_cb.wvalid && vif.monitor_cb.wready) begin
              w_data = vif.monitor_cb.wdata;
              w_strb = vif.monitor_cb.wstrb;
              w_count++;
              break;
            end else if (!vif.monitor_cb.wvalid) begin
              d_delay++;
            end
          end
        end
      join

      // Wait for B channel handshake
      forever begin
        @(posedge vif.aclk);
        if (vif.monitor_cb.bvalid && vif.monitor_cb.bready) begin
          b_count++;
          break;
        end else if (!vif.monitor_cb.bready) begin
          r_delay++;
        end
      end

      // Build transaction
      item = axi4lite_seq_item::type_id::create("wr_item");
      item.dir        = AXI4LITE_WRITE;
      item.addr       = aw_addr;
      item.prot       = aw_prot;
      item.data       = w_data;
      item.strb       = w_strb;
      item.resp       = axi4lite_resp_t'(vif.monitor_cb.bresp);
      item.rdata      = '0;
      
      // Inject captured delays
      item.addr_delay = (a_delay > 0) ? (a_delay - 1) : 0;
      item.data_delay = d_delay;
      item.resp_delay = r_delay;

      `uvm_info("MON", $sformatf("Write observed: %s", item.convert2string()), UVM_HIGH)
      ap.write(item);
      wr_ap.write(item);
    end
  endtask

  // ----------------------------------------------------------------------
  // Read monitor: collect AR then R with delay profiling
  // ----------------------------------------------------------------------
  task monitor_reads();
    axi4lite_seq_item item;
    int a_delay, r_delay;

    forever begin
      a_delay = 0;
      r_delay = 0;

      // Wait for AR handshake
      forever begin
        @(posedge vif.aclk);
        if (vif.monitor_cb.arvalid && vif.monitor_cb.arready) begin
          ar_count++;
          break;
        end else if (!vif.monitor_cb.arvalid) begin
          a_delay++;
        end
      end

      item = axi4lite_seq_item::type_id::create("rd_item");
      item.dir  = AXI4LITE_READ;
      item.addr = vif.monitor_cb.araddr;
      item.prot = vif.monitor_cb.arprot;

      // Wait for R handshake
      forever begin
        @(posedge vif.aclk);
        if (vif.monitor_cb.rvalid && vif.monitor_cb.rready) begin
          r_count++;
          break;
        end else if (!vif.monitor_cb.rready) begin
          r_delay++;
        end
      end

      item.rdata = vif.monitor_cb.rdata;
      item.resp  = axi4lite_resp_t'(vif.monitor_cb.rresp);
      item.data  = item.rdata;
      
      // Inject captured delays
      item.addr_delay = (a_delay > 0) ? (a_delay - 1) : 0;
      item.data_delay = 0;
      item.resp_delay = r_delay;

      `uvm_info("MON", $sformatf("Read observed: %s", item.convert2string()), UVM_HIGH)
      ap.write(item);
      rd_ap.write(item);
    end
  endtask

  // ----------------------------------------------------------------------
  // Reset detection - kills monitor threads on reset assertion
  // ----------------------------------------------------------------------
  task detect_reset();
    @(negedge vif.aresetn);
    `uvm_info("MON", "Reset asserted - monitor restarting", UVM_MEDIUM)
  endtask

endclass
