// Code your testbench here
// or browse Examples
// program automatic simple_test;
  import uvm_pkg::*;
  
  class packet extends uvm_sequence_item;
    randc bit[3:0] semi, full;
    randc bit[7:0] payload[$];
    string gg = "goodgame";
    string nt="nicetrygame";
    constraint valid {payload.size inside {[2:100]};}
    `uvm_object_utils_begin(packet)
    `uvm_field_int(semi, UVM_ALL_ON)
    `uvm_field_int(full, UVM_ALL_ON)
    `uvm_field_queue_int(payload, UVM_ALL_ON)
    `uvm_field_string(gg, UVM_ALL_ON)
    `uvm_field_string(nt, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "packet");
      super.new(name); 
    endfunction
    
  endclass

module ab();
  packet pkt;
  packet pkt2;
  initial begin
    //pkt = packet::type_id::create();
    pkt = new();
    pkt2 = new();
    pkt.randomize();
    pkt.print();
    pkt2.randomize();
    pkt2.print();
    
    //compare method
    if(pkt.compare(pkt2))
      `uvm_info("","packet1 is matching with packet2", UVM_LOW)
    else
      `uvm_error("","packet2 is not matching with packet1")
    
    //---------------Matching Case------------------------------  
      pkt2.copy(pkt); //copy seq_item_0 to seq_item_1
    //compare method
    if(pkt.compare(pkt2))
      `uvm_info("","packet1 is matching with packet2", UVM_LOW)
    else
      `uvm_error("","packet1 is not matching with packet2")  
    
  end
endmodule
 //initial run_test("packet");
//endprogram
