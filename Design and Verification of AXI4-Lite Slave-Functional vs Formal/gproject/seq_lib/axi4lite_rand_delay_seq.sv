class axi4lite_rand_delay_seq extends axi4lite_base_seq;
  `uvm_object_utils(axi4lite_rand_delay_seq)

  function new(string name = "axi4lite_rand_delay_seq");
    super.new(name);
  endfunction

  virtual task body();
    axi4lite_seq_item req;
    
    // Generate 50 transactions with forced delays
    for (int i = 0; i < 50; i++) begin
      req = axi4lite_seq_item::type_id::create("req");
      
      start_item(req);
      
      // Force the delay variables into the 1-5 range to hit short and medium bins
      /*if (!req.randomize() with {
        addr_delay inside {[0:5]};
        data_delay inside {[0:5]};
        resp_delay inside {[0:5]};
      })*/
      if (!req.randomize() with {
        dir inside {AXI4LITE_WRITE, AXI4LITE_READ};
        addr_delay dist { 0 := 1, [1:2] := 1, [3:5] := 1 };
        data_delay dist { 0 := 1, [1:2] := 1, [3:5] := 1 };
        resp_delay dist { 0 := 1, [1:2] := 1, [3:5] := 1 };
      }) begin
        `uvm_error("SEQ", "Randomization failed for delay item")
      end
     // `uvm_info("delay_seq",$sformatf("Txn %0d Delays: Addr=%0d, Data=%0d, Resp=%0d",i, req.addr_delay, req.data_delay, req.resp_delay),UVM_LOW)
      finish_item(req);
    end
  endtask
endclass
