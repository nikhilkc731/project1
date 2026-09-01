// Fully randomized sequence - fires N random transactions to fill
// coverage holes left by directed sequences.

class axi4lite_random_seq extends axi4lite_base_seq;

  `uvm_object_utils(axi4lite_random_seq)

  rand int unsigned num_txns;

  constraint c_num_txns {
    num_txns inside {[50:200]};
  }

  function new(string name = "axi4lite_random_seq");
    super.new(name);
  endfunction

  task body();
    axi4lite_seq_item item;

    `uvm_info("SEQ", $sformatf("=== Random Sequence: %0d transactions ===", num_txns), UVM_LOW)

    repeat (num_txns) begin
      item = axi4lite_seq_item::type_id::create("rand_item");
      start_item(item);
      assert(item.randomize() with {addr_delay==2;data_delay==3;resp_delay==4;}) else
        `uvm_fatal("SEQ", "Randomization failed for random item")
      finish_item(item);
    end
  endtask

endclass
