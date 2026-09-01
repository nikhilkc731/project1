// Exercises all meaningful write strobe patterns on every register.

class axi4lite_strobe_seq extends axi4lite_base_seq;

  `uvm_object_utils(axi4lite_strobe_seq)

  function new(string name = "axi4lite_strobe_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] rdata;
    bit [31:0] addrs [$] = '{32'h0, 32'h4, 32'h8, 32'hC};
    bit [3:0] strobes[$] = '{4'b0001, 4'b0010, 4'b0100, 4'b1000,
                             4'b0011, 4'b1100, 4'b0101, 4'b1010,
                             4'b0111, 4'b1110, 4'b1111};

    `uvm_info("SEQ", "=== Strobe Pattern Sequence ===", UVM_LOW)

    foreach (addrs[a]) begin
      foreach (strobes[s]) begin
        // Clear register first
        axi_write(addrs[a], 32'h0, 4'hF);

        // Write with specific strobe
        axi_write(addrs[a], 32'hFF_FF_FF_FF, strobes[s]);

        // Read back to verify partial write
        axi_read(addrs[a], rdata);

        `uvm_info("SEQ", $sformatf("addr=0x%0h strb=0b%04b rdata=0x%08h",
                                   addrs[a], strobes[s], rdata), UVM_MEDIUM)
      end
    end
  endtask

endclass
