// Code your testbench here
// or browse Examples
class packet extends uvm_sequence_item;
    randc bit[3:0] semi, full;
    randc bit[7:0] payload[$];
//     string gg = "goodgame";
//     string nt="nicetrygame";
    constraint valid {payload.size inside {[2:100]};}
  
    `uvm_object_utils_begin(packet)
  `uvm_field_int(semi, UVM_ALL_ON)
    `uvm_field_int(full, UVM_ALL_ON)
     `uvm_field_queue_int(payload, UVM_ALL_ON)
//     `uvm_field_string(gg, UVM_ALL_ON)
//     `uvm_field_string(nt, UVM_ALL_ON)
    `uvm_object_utils_end
    
  function bit comp(packet tr);
    return this.compare(tr);
  endfunction
    function new(string name = "packet");
      super.new(name); 
    endfunction
  endclass
    //__________________________________
    
    class packet_sequencer extends uvm_sequencer #(packet);
      `uvm_sequencer_utils(packet_sequencer)
      function new (string name = "packet_sequencer" , uvm_component parent=null);
        super.new(name,parent);
//         `uvm_update_sequence_lib_and_item(packet)
      endfunction
    endclass
    //___________________________________
    
    class driver extends uvm_driver #(packet);
      `uvm_component_utils(driver)
      function new (string name , uvm_component parent);
      super.new(name,parent);
    endfunction
      virtual task run();
        `uvm_info("Trace","Driver sequence test" , UVM_MEDIUM)
        forever begin
           seq_item_port.get_next_item(req);
          req.print();
          seq_item_port.item_done();
       end
       
      endtask
       
    endclass
    //____________________________________

class inled extends uvm_monitor;
  `uvm_component_utils(inled)
  function new (string name , uvm_component parent);
      super.new(name,parent);
    endfunction
  uvm_analysis_port #(packet) analysis_port;
  virtual function void build();
    super.build();
    analysis_port = new("analysis_port",this);
    endfunction
   virtual task run();
     forever begin
      packet tr = packet::type_id::create("tr");
      get_packet(tr);
      analysis_port.write(tr);
     end
   endtask
  virtual task get_packet(packet tr);
    tr = packet::type_id::create("tr",this); 
  endtask
    endclass

class outled extends uvm_monitor;
  `uvm_component_utils (outled)
  function new (string name , uvm_component parent);
      super.new(name,parent);
    endfunction
  uvm_analysis_port #(packet) analysis_port;
  virtual function void build();
    super.build();
    analysis_port = new("analysis_port",this);
    endfunction
  virtual task run();
    forever begin
      packet tr = packet::type_id::create("tr");
      get_packet(tr);
      analysis_port.write(tr);
    end
  endtask
  virtual task get_packet(packet tr);
  endtask
    endclass

//-------------___________------------
    
    class scoreboard extends uvm_scoreboard;
      `uvm_component_utils(scoreboard)
      function new (string name , uvm_component parent);
      super.new(name,parent);
    endfunction
      typedef uvm_in_order_class_comparator #(packet) cmpr_type;
      cmpr_type cmpr;
      uvm_analysis_export #(packet) before_export;
      uvm_analysis_export #(packet) after_export;
      virtual function void build();
        super.build();
        before_export = new("before_export",this);
        after_export = new("after_export",this);
        cmpr = cmpr_type::type_id::create("cmpr",this);
      endfunction
      virtual function void connect();
        before_export.connect(cmpr.before_export);
        after_export.connect(cmpr.after_export);
      endfunction
      virtual function void report();
        `uvm_info("Scoreboard Report",
                  $psprintf("Matches = %0d, MMismatches = %0d", cmpr.m_matches,cmpr.m_mismatches), UVM_MEDIUM);
      endfunction
    endclass
    
//________________________________________


//_________________________________________
    
    class router_env extends uvm_env;
      `uvm_component_utils(router_env)
      packet_sequencer seqr;
      driver drv;
       inled before_mon;
       outled after_mon;
       scoreboard sb;
    function new (string name , uvm_component parent);
      super.new(name,parent);
    endfunction
      virtual function void build();
        super.build();
        before_mon = inled::type_id::create("before_mon",this);
        after_mon = outled::type_id::create("after_mon",this);
         sb = scoreboard::type_id::create("sb",this);
        seqr = packet_sequencer::type_id::create("seqr",this);
        drv = driver::type_id::create("drv",this);
      endfunction
      
      virtual function void connect();
         before_mon.analysis_port.connect(sb.before_export);
         after_mon.analysis_port.connect(sb.after_export);
        drv.seq_item_port.connect(seqr.seq_item_export);
      endfunction
    endclass
    
 //+_____________________________________+
    
    class test_base extends uvm_test;
      router_env env;
      packet pkt;
      `uvm_component_utils(test_base)
      
      function new (string name , uvm_component parent);
      super.new(name,parent);
    endfunction
      
      virtual function void build();
        super.build();
        env = router_env::type_id::create("env",this); 
        set_config_string("*.seqr","default_sequence","packet_sequence");
      endfunction
      virtual task run();
        `uvm_info("id","working",UVM_MEDIUM)
      endtask
    endclass

//________________________________________

class packet_sequence extends uvm_sequence#(packet);
  packet req;
  `uvm_sequence_utils(packet_sequence,packet_sequencer)
  function new(string name = "packet_sequence");
    super.new(name);
  endfunction
  virtual task body();
   // repeat(5) begin
      `uvm_do(req);
  //  end
  endtask
endclass

//__________________

    //_________________________________
 module ab;
   
//   packet pkt;
  initial begin
  run_test();
//     pkt = packet::type_id::create();
//    // tb = test_base::type_id::create();
//     pkt.randomize;
//     pkt.print();
   end
 endmodule
