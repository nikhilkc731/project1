// Full coverage test - runs all directed sequences followed by
// a large random sequence to maximize functional coverage.

class axi4lite_full_coverage_test extends axi4lite_base_test;

  `uvm_component_utils(axi4lite_full_coverage_test)

  function new(string name = "axi4lite_full_coverage_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_sequences(uvm_phase phase);
    axi4lite_single_read_seq       rd_seq;
    axi4lite_single_write_seq      wr_seq;
    axi4lite_write_read_b2b_seq    b2b_seq;
    axi4lite_strobe_seq            strb_seq;
    axi4lite_prot_seq              prot_seq;
    axi4lite_delay_seq             dly_seq;
    axi4lite_data_pattern_seq      dp_seq;
    axi4lite_random_seq            rand_seq;

    `uvm_info("TEST", "=== Full Coverage Test ===", UVM_LOW)

    // 1. Read after reset (all zeros)
    rd_seq = axi4lite_single_read_seq::type_id::create("rd_seq");
    rd_seq.start(env.vsqr.axi_sqr);

    // 2. Write all registers and read back
    wr_seq = axi4lite_single_write_seq::type_id::create("wr_seq");
    wr_seq.start(env.vsqr.axi_sqr);

    // 3. Back-to-back ordering
    b2b_seq = axi4lite_write_read_b2b_seq::type_id::create("b2b_seq");
    b2b_seq.start(env.vsqr.axi_sqr);

    // 4. Strobe patterns
    strb_seq = axi4lite_strobe_seq::type_id::create("strb_seq");
    strb_seq.start(env.vsqr.axi_sqr);

    // 5. Protection types
    prot_seq = axi4lite_prot_seq::type_id::create("prot_seq");
    prot_seq.start(env.vsqr.axi_sqr);

    // 6. Delay variations
    dly_seq = axi4lite_delay_seq::type_id::create("dly_seq");
    dly_seq.start(env.vsqr.axi_sqr);

    // 7. Data patterns
    dp_seq = axi4lite_data_pattern_seq::type_id::create("dp_seq");
    dp_seq.start(env.vsqr.axi_sqr);

    // 8. Random to fill remaining holes
    rand_seq = axi4lite_random_seq::type_id::create("rand_seq");
    assert(rand_seq.randomize() with { num_txns == 200; }) else
      `uvm_fatal("TEST", "Failed to randomize")
    rand_seq.start(env.vsqr.axi_sqr);
  endtask

endclass
