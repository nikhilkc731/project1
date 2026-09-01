// Back-to-back write-then-read to every register.
// Covers WW, WR, RR, RW ordering patterns.

class axi4lite_write_read_b2b_seq extends axi4lite_base_seq;

  `uvm_object_utils(axi4lite_write_read_b2b_seq)

  function new(string name = "axi4lite_write_read_b2b_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] rdata;
    bit [31:0] addrs [$] = '{32'h0, 32'h4, 32'h8, 32'hC};

    `uvm_info("SEQ", "=== Back-to-Back Write/Read Sequence ===", UVM_LOW)

    // WW: consecutive writes
    foreach (addrs[i])
      axi_write(addrs[i], 32'hAA00_0000 + i);

    // RR: consecutive reads
    foreach (addrs[i])
      axi_read(addrs[i], rdata);

    // WR: write immediately followed by read to same address
    foreach (addrs[i]) begin
      axi_write(addrs[i], 32'hBB00_0000 + i);
      axi_read(addrs[i], rdata);
    end

    // RW: read then write to same address
    foreach (addrs[i]) begin
      axi_read(addrs[i], rdata);
      axi_write(addrs[i], 32'hCC00_0000 + i);
    end
  endtask

endclass
