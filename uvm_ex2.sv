class packet extends uvm_sequence_item;
  rand bit[7:0] semi, full;
    rand bit[7:0] payload[$];
   // string gg = "goodgame";
    //string nt="nicetrygame";
    constraint valid {payload.size inside {[2:100]};}
    `uvm_object_utils_begin(packet)
  `uvm_field_int(semi, UVM_ALL_ON )
  `uvm_field_int(full, UVM_ALL_ON )
  `uvm_field_queue_int(payload, UVM_ALL_ON )
  //`uvm_field_string(gg, UVM_ALL_ON | UVM_NOPRINT)
  //`uvm_field_string(nt, UVM_ALL_ON | UVM_NOPRINT)
    `uvm_object_utils_end
    function new(string name = "packet");
      super.new(name); 
    endfunction
    
endclass

module trn();
  packet pkt0,pkt1,pkt2;
  bit  bit_stream[];
  int stream_value;
  initial begin
    pkt0 = packet::type_id::create("pkt0");
    pkt1 = packet::type_id::create("pkt1");
    pkt0.semi = 10;
    //pkt0.randomize();
    pkt0.print();
    pkt0.copy(pkt1);
    
    $cast(pkt2,pkt1.clone());
    
    if(!pkt0.compare(pkt2)) begin
      `uvm_fatal("!!The DATA IS MISMATCHED!!" ,{"\n" , pkt0.sprint(),pkt2.sprint()});
    end
    bit_stream = new[8];
    pkt0.pack(bit_stream);
    `uvm_info("A", $sformatf("bit_stream=%p",bit_stream), UVM_LOW)
   $display("________________________");
    stream_value = pkt2.unpack(bit_stream);
    `uvm_info("B", $sformatf("unpack value = 0X%0h",stream_value), UVM_LOW)
   // `uvm_info("","this is working",UVM_MEDIUM)
  end
endmodule
