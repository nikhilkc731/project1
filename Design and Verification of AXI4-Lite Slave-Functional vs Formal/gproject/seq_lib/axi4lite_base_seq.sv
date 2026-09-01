// AXI4-Lite Base Sequence
//
// Provides helper tasks for single write and read operations.
// All other sequences extend this.

class axi4lite_base_seq extends uvm_sequence #(axi4lite_seq_item);

  `uvm_object_utils(axi4lite_base_seq)

  function new(string name = "axi4lite_base_seq");
    super.new(name);
  endfunction

  // ----------------------------------------------------------------------
  // Helper: single write
  // ----------------------------------------------------------------------
  task axi_write(bit [31:0] addr, bit [31:0] data,
                 bit [3:0] strb = 4'hF, bit [2:0] prot = 3'b000,
                 int unsigned addr_dly = 0, int unsigned data_dly = 0,
                 int unsigned resp_dly = 0);
    axi4lite_seq_item item;
    item = axi4lite_seq_item::type_id::create("wr_item");
    start_item(item);
    assert(item.randomize() with {
      dir        == AXI4LITE_WRITE;
      addr       == local::addr;
      data       == local::data;
      strb       == local::strb;
      prot       == local::prot;
      addr_delay == local::addr_dly;
      data_delay == local::data_dly;
      resp_delay == local::resp_dly;
    }) else `uvm_fatal("SEQ", "Randomization failed for write item")
    finish_item(item);
  endtask

  // ----------------------------------------------------------------------
  // Helper: single read (returns read data via output)
  // ----------------------------------------------------------------------
  task axi_read(bit [31:0] addr, output bit [31:0] rdata,
                input bit [2:0] prot = 3'b000,
                input int unsigned addr_dly = 0,
                input int unsigned resp_dly = 0);
    axi4lite_seq_item item;
    item = axi4lite_seq_item::type_id::create("rd_item");
    start_item(item);
    assert(item.randomize() with {
      dir        == AXI4LITE_READ;
      addr       == local::addr;
      prot       == local::prot;
      addr_delay == local::addr_dly;
      resp_delay == local::resp_dly;
    }) else `uvm_fatal("SEQ", "Randomization failed for read item")
    finish_item(item);
    rdata = item.rdata;
  endtask

  task body();
    `uvm_info("SEQ", "axi4lite_base_seq: override body() in derived sequences", UVM_MEDIUM)
  endtask

endclass
