// Exercises all 8 PROT field values on both write and read channels.

class axi4lite_prot_seq extends axi4lite_base_seq;

  `uvm_object_utils(axi4lite_prot_seq)

  function new(string name = "axi4lite_prot_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] rdata;

    `uvm_info("SEQ", "=== Protection Type Sequence ===", UVM_LOW)

    for (int p = 0; p < 8; p++) begin
      axi_write(32'h0, 32'h1000_0000 + p, 4'hF, p[2:0]);
      axi_read(32'h0, rdata, p[2:0]);
      `uvm_info("SEQ", $sformatf("prot=0b%03b write_data=0x%08h read_data=0x%08h",
                                 p[2:0], 32'h1000_0000 + p, rdata), UVM_MEDIUM)
    end
  endtask

endclass
