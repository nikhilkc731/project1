// AXI4-Lite Functional Coverage Collector
//
// Comprehensive covergroups targeting 100% functional coverage of the
// axi4lite_slave_example DUT (4 registers, 32-bit data, 4-bit address).

class axi4lite_coverage extends uvm_subscriber #(axi4lite_seq_item);

  `uvm_component_utils(axi4lite_coverage)

  axi4lite_seq_item txn;
  virtual axi4lite_if vif;

  // Track previous transaction for back-to-back and ordering coverage
  axi4lite_dir_t prev_dir;
  bit            prev_valid;

  //
  // Covergroup: Transaction-level coverage
  //
  covergroup cg_transaction;
    option.per_instance = 1;
    option.name = "cg_transaction";

    cp_dir: coverpoint txn.dir {
      bins write = {AXI4LITE_WRITE};
      bins read  = {AXI4LITE_READ};
    }

    cp_addr: coverpoint txn.addr[3:0] {
      bins reg0 = {4'h0};
      bins reg1 = {4'h4};
      bins reg2 = {4'h8};
      bins reg3 = {4'hC};
    }

    // This DUT always returns OKAY. SLVERR/DECERR are defined as
    // ignore_bins so they don't block 100% coverage. EXOKAY is
    // illegal per AXI4-Lite spec.
    cp_resp: coverpoint txn.resp {
      bins okay = {AXI_RESP_OKAY};
      ignore_bins slverr = {AXI_RESP_SLVERR};
      ignore_bins decerr = {AXI_RESP_DECERR};
      illegal_bins exokay = {AXI_RESP_EXOKAY};
    }

    cx_dir_addr: cross cp_dir, cp_addr;
    cx_dir_resp: cross cp_dir, cp_resp;
  endgroup

  //
  // Covergroup: Write strobe patterns
  //
  covergroup cg_write_strobe;
    option.per_instance = 1;
    option.name = "cg_write_strobe";

    cp_strb: coverpoint txn.strb {
      bins all_bytes    = {4'b1111};
      bins byte0_only   = {4'b0001};
      bins byte1_only   = {4'b0010};
      bins byte2_only   = {4'b0100};
      bins byte3_only   = {4'b1000};
      bins lower_half   = {4'b0011};
      bins upper_half   = {4'b1100};
      bins byte0_byte2  = {4'b0101};
      bins byte1_byte3  = {4'b1010};
      bins lower_three  = {4'b0111};
      bins upper_three  = {4'b1110};
      bins other_combos = default;
    }

    cp_strb_addr: coverpoint txn.addr[3:0] {
      bins reg0 = {4'h0};
      bins reg1 = {4'h4};
      bins reg2 = {4'h8};
      bins reg3 = {4'hC};
    }

    cx_strb_addr: cross cp_strb, cp_strb_addr;
  endgroup

  //
  // Covergroup: Write data patterns
  //
  covergroup cg_write_data;
    option.per_instance = 1;
    option.name = "cg_write_data";

    cp_data: coverpoint txn.data {
      bins zero       = {32'h0000_0000};
      bins all_ones   = {32'hFFFF_FFFF};
      bins walk1_0    = {32'h0000_0001};
      bins walk1_31   = {32'h8000_0000};
      bins alt_5a     = {32'h5A5A_5A5A};
      bins alt_a5     = {32'hA5A5_A5A5};
      bins low_nibble = {[32'h0000_0001 : 32'h0000_000F]};
      bins mid_range  = {[32'h0000_0010 : 32'h0000_FFFF]};
      bins high_range = {[32'h0001_0000 : 32'hFFFF_FFFE]};
    }
  endgroup

  //
  // Covergroup: Protection type
  //
  covergroup cg_prot;
    option.per_instance = 1;
    option.name = "cg_prot";

    cp_prot: coverpoint txn.prot {
      bins unpriv_secure_data  = {3'b000};
      bins priv_secure_data    = {3'b001};
      bins unpriv_nonsec_data  = {3'b010};
      bins priv_nonsec_data    = {3'b011};
      bins unpriv_secure_instr = {3'b100};
      bins priv_secure_instr   = {3'b101};
      bins unpriv_nonsec_instr = {3'b110};
      bins priv_nonsec_instr   = {3'b111};
    }

    cp_prot_dir: coverpoint txn.dir {
      bins write = {AXI4LITE_WRITE};
      bins read  = {AXI4LITE_READ};
    }

    cx_prot_dir: cross cp_prot, cp_prot_dir;
  endgroup

  //
  // Covergroup: Transaction ordering and back-to-back
  //
  covergroup cg_ordering;
    option.per_instance = 1;
    option.name = "cg_ordering";

    cp_curr_dir: coverpoint txn.dir {
      bins write = {AXI4LITE_WRITE};
      bins read  = {AXI4LITE_READ};
    }

    cp_prev_dir: coverpoint prev_dir {
      bins write = {AXI4LITE_WRITE};
      bins read  = {AXI4LITE_READ};
    }

    cx_b2b: cross cp_prev_dir, cp_curr_dir;
  endgroup

  //
  // Covergroup: Delay / timing variations
  //
  covergroup cg_delays;
    option.per_instance = 1;
    option.name = "cg_delays";

    cp_addr_delay: coverpoint txn.addr_delay {
      bins zero1     = {0};
      bins short_d1  = {[1:2]};
      bins medium_d1 = {[3:5]};
    }

    cp_data_delay: coverpoint txn.data_delay {
      bins zero2     = {0};
      bins short_d2  = {[1:2]};
      bins medium_d2 = {[3:5]};
    }

    cp_resp_delay: coverpoint txn.resp_delay {
      bins zero3     = {0};
      bins short_d3  = {[1:2]};
      bins medium_d3 = {[3:5]};
    }

    cp_dir: coverpoint txn.dir {
      bins write = {AXI4LITE_WRITE};
      bins read  = {AXI4LITE_READ};
    }

    cx_addr_delay_dir: cross cp_addr_delay, cp_dir;
    cx_resp_delay_dir: cross cp_resp_delay, cp_dir;
  endgroup

  //
  // Covergroup: Read-after-write to same address
  //
  bit       raw_hit;
  bit [3:0] raw_addr;

  covergroup cg_raw;
    option.per_instance = 1;
    option.name = "cg_raw";

    cp_raw: coverpoint raw_hit {
      bins no_raw = {1'b0};
      bins raw    = {1'b1};
    }

    cp_raw_addr: coverpoint raw_addr {
      bins reg0 = {4'h0};
      bins reg1 = {4'h4};
      bins reg2 = {4'h8};
      bins reg3 = {4'hC};
    }

    cx_raw_addr: cross cp_raw, cp_raw_addr {
      ignore_bins no_raw_x = binsof(cp_raw) intersect {1'b0};
    }
  endgroup

  //
  // Covergroup: Handshake-level (interface signals)
  //
  // Sampled explicitly from sample_handshakes() no clock event
  // in the declaration to avoid VCS issues with null vif at elab.
  //
  bit aw_hsk, w_hsk, b_hsk, ar_hsk, r_hsk;
  bit aw_stall, w_stall, ar_stall, b_stall, r_stall;

  covergroup cg_handshake;
    option.per_instance = 1;
    option.name = "cg_handshake";

    cp_aw_stall: coverpoint aw_stall {
      bins no_stall = {1'b0};
      bins stall    = {1'b1};
    }

    cp_w_stall: coverpoint w_stall {
      bins no_stall = {1'b0};
      bins stall    = {1'b1};
    }

    cp_ar_stall: coverpoint ar_stall {
      bins no_stall = {1'b0};
      bins stall    = {1'b1};
    }

    cp_b_stall: coverpoint b_stall {
      bins no_stall = {1'b0};
      bins stall    = {1'b1};
    }

    cp_r_stall: coverpoint r_stall {
      bins no_stall = {1'b0};
      bins stall    = {1'b1};
    }

    cp_aw_w_simul: coverpoint (aw_hsk && w_hsk) {
      bins simultaneous = {1'b1};
      bins not_simul    = {1'b0};
    }
  endgroup

  //
  // Covergroup: Reset coverage
  //
  bit reset_during_aw, reset_during_w, reset_during_ar;
  bit reset_during_b, reset_during_r;
  bit reset_applied;

  covergroup cg_reset;
    option.per_instance = 1;
    option.name = "cg_reset";

    cp_reset: coverpoint reset_applied {
      bins applied = {1'b1};
    }

    cp_rst_aw: coverpoint reset_during_aw {
      bins idle   = {1'b0};
     // bins active = {1'b1};
    }

    cp_rst_w: coverpoint reset_during_w {
      bins idle   = {1'b0};
      //bins active = {1'b1};
    }

    cp_rst_ar: coverpoint reset_during_ar {
      bins idle   = {1'b0};
      //bins active = {1'b1};
    }

    cp_rst_b: coverpoint reset_during_b {
      bins idle   = {1'b0};
      //bins active = {1'b1};
    }

    cp_rst_r: coverpoint reset_during_r {
      bins idle   = {1'b0};
      //bins active = {1'b1};
    }
  endgroup
//covergroup:rdata
  covergroup cg_read_data;
  option.per_instance = 1;
  option.name = "cg_read_data";

  cp_data: coverpoint txn.data iff (txn.dir == AXI4LITE_READ) {
    bins zero       = {32'h0000_0000};
    bins all_ones   = {32'hFFFF_FFFF};
    bins walk1_0    = {32'h0000_0001};
    bins walk1_31   = {32'h8000_0000};
    bins alt_5a     = {32'h5A5A_5A5A};
    bins alt_a5     = {32'hA5A5_A5A5};
  }
endgroup

  //
  // Constructor
  //
  function new(string name = "axi4lite_coverage", uvm_component parent = null);
    super.new(name, parent);
    cg_transaction  = new();
    cg_write_strobe = new();
    cg_write_data   = new();
    cg_prot         = new();
    cg_ordering     = new();
    cg_delays       = new();
    cg_raw          = new();
    cg_handshake    = new();
    cg_reset        = new();
    cg_read_data    = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4lite_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for axi4lite_coverage")
  endfunction

  //
  // Subscriber write called for every observed transaction
  //
  bit [3:0] last_wr_addr;
  bit       last_was_write;

  function void write(axi4lite_seq_item t);
    txn = t;

    // RAW calculation
    if (t.dir == AXI4LITE_READ && last_was_write && t.addr[3:0] == last_wr_addr) begin
      raw_hit  = 1'b1;
      raw_addr = t.addr[3:0];
    end else begin
      raw_hit  = 1'b0;
      raw_addr = t.addr[3:0];
    end

    // Sample covergroups
    cg_transaction.sample();
    cg_prot.sample();
    cg_delays.sample();
    cg_raw.sample();

    if (t.dir == AXI4LITE_WRITE) begin
      cg_write_strobe.sample();
      cg_write_data.sample();
    end
    else
      begin
       cg_read_data.sample();
      end

    if (prev_valid)
      cg_ordering.sample();

    // Update state
    prev_dir   = t.dir;
    prev_valid = 1'b1;

    if (t.dir == AXI4LITE_WRITE) begin
      last_was_write = 1'b1;
      last_wr_addr   = t.addr[3:0];
    end else begin
      last_was_write = 1'b0;
    end
  endfunction

  //
  // Handshake and reset sampling (runs in parallel)
  //
  task run_phase(uvm_phase phase);
    fork
      sample_handshakes();
      sample_reset();
    join_none
  endtask

  task sample_handshakes();
    forever begin
      @(posedge vif.aclk);
      if (vif.aresetn) begin
        aw_hsk = vif.monitor_cb.awvalid && vif.monitor_cb.awready;
        w_hsk  = vif.monitor_cb.wvalid && vif.monitor_cb.wready;
        b_hsk  = vif.monitor_cb.bvalid && vif.monitor_cb.bready;
        ar_hsk = vif.monitor_cb.arvalid && vif.monitor_cb.arready;
        r_hsk  = vif.monitor_cb.rvalid && vif.monitor_cb.rready;

        aw_stall = vif.monitor_cb.awvalid && !vif.monitor_cb.awready;
        w_stall  = vif.monitor_cb.wvalid && !vif.monitor_cb.wready;
        ar_stall = vif.monitor_cb.arvalid && !vif.monitor_cb.arready;
        b_stall  = vif.monitor_cb.bvalid && !vif.monitor_cb.bready;
        r_stall  = vif.monitor_cb.rvalid && !vif.monitor_cb.rready;

        cg_handshake.sample();
      end
    end
  endtask

  task sample_reset();
    forever begin
      @(negedge vif.aresetn);
      reset_applied   = 1'b1;
      reset_during_aw = vif.awvalid;
      reset_during_w  = vif.wvalid;
      reset_during_ar = vif.arvalid;
      reset_during_b  = vif.bready;
      reset_during_r  = vif.rready;

      cg_reset.sample();
      @(posedge vif.aresetn);
    end
  endtask

  //
  // Report coverage at end of simulation
  //
  function void report_phase(uvm_phase phase);
    `uvm_info("COV", "=== AXI4-Lite Functional Coverage Report ===", UVM_LOW)
    `uvm_info("COV", $sformatf("  cg_transaction : %.2f%%", cg_transaction.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("  cg_write_strobe: %.2f%%", cg_write_strobe.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("  cg_write_data  : %.2f%%", cg_write_data.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("  cg_prot        : %.2f%%", cg_prot.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("  cg_ordering    : %.2f%%", cg_ordering.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("  cg_delays      : %.2f%%", cg_delays.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("  cg_raw         : %.2f%%", cg_raw.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("  cg_handshake   : %.2f%%", cg_handshake.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("  cg_reset       : %.2f%%", cg_reset.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("  OVERALL        : %.2f%%", $get_coverage()), UVM_LOW)
  endfunction

endclass
