// AXI4-Lite Sequence Item

class axi4lite_seq_item extends uvm_sequence_item;

  // ----------------------------------------------------------------------
  // Fields
  // ----------------------------------------------------------------------

  rand axi4lite_dir_t  dir;
  rand bit [31:0]      addr;
  rand bit [31:0]      data;
  rand bit [3:0]       strb;
  rand bit [2:0]       prot;

  // Response (filled by driver/monitor)
  axi4lite_resp_t      resp;
  bit [31:0]           rdata;

  // Delays (master-side knobs)
  rand int unsigned    addr_delay;  // cycles before asserting AxVALID
  rand int unsigned    data_delay;  // cycles before asserting WVALID (write only)
  rand int unsigned    resp_delay;  // cycles before asserting BREADY/RREADY

  // ----------------------------------------------------------------------
  // Constraints
  // ----------------------------------------------------------------------

  // Address aligned to data width (word-aligned for 32-bit)
  constraint c_addr_aligned {
    addr[1:0] == 2'b00;
  }

  // Address within 4-register space (0x00..0x0C)
  constraint c_addr_range {
    addr[31:4] == 28'h0;
    addr[3:0] inside {4'h0, 4'h4, 4'h8, 4'hC};
  }

  // At least one strobe bit active on writes
  constraint c_strb_valid {
    dir == AXI4LITE_WRITE -> strb != 4'h0;
  }

  // Reasonable delays
  constraint c_delays {
    addr_delay inside {[0:5]};
    data_delay inside {[0:5]};
    resp_delay inside {[0:5]};
  }

  // ----------------------------------------------------------------------
  // UVM automation
  // ----------------------------------------------------------------------

  `uvm_object_utils_begin(axi4lite_seq_item)
    `uvm_field_enum(axi4lite_dir_t, dir,      UVM_ALL_ON)
    `uvm_field_int(addr,                      UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(data,                      UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(strb,                      UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(prot,                      UVM_ALL_ON | UVM_BIN)
    `uvm_field_enum(axi4lite_resp_t, resp,    UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(rdata,                     UVM_ALL_ON | UVM_HEX | UVM_NOCOMPARE)
    `uvm_field_int(addr_delay,                UVM_ALL_ON | UVM_NOCOMPARE | UVM_DEC)
    `uvm_field_int(data_delay,                UVM_ALL_ON | UVM_NOCOMPARE | UVM_DEC)
    `uvm_field_int(resp_delay,                UVM_ALL_ON | UVM_NOCOMPARE | UVM_DEC)
  `uvm_object_utils_end

  function new(string name = "axi4lite_seq_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("%s addr=0x%0h data=0x%0h strb=0b%04b prot=0b%03b resp=%s rdata=0x%0h",
                     dir.name(), addr, data, strb, prot, resp.name(), rdata);
  endfunction

endclass
