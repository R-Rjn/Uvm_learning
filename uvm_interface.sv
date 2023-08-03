interface intf();
  bit clk;
  bit[3:0] semi,full;
endinterface
class packet extends uvm_sequence_item;
    randc bit[3:0] semi, full;
    `uvm_object_utils_begin(packet)
    `uvm_field_int(semi, UVM_ALL_ON)
    `uvm_field_int(full, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "packet");
      super.new(name); 
    endfunction
  endclass
    //__________________________________
      
class router_vi_wrapper extends uvm_object;
  virtual intf sigs;
  `uvm_object_utils(router_vi_wrapper)
  function new(string name="",virtual intf sigs = null);
    super.new(name);
    endfunction
endclass
  //_________________________________
    
    class packet_sequencer extends uvm_sequencer #(packet);
      `uvm_sequencer_utils(packet_sequencer)
      function new (string name = "packet_sequencer" , uvm_component parent=null);
        super.new(name,parent);
      endfunction
    endclass
    //___________________________________
    
    class driver extends uvm_driver #(packet);
      router_vi_wrapper router_vi;
      
      `uvm_component_utils_begin(driver)
      `uvm_field_object(router_vi, UVM_DEFAULT)
      `uvm_component_utils_end
      
      function new (string name , uvm_component parent);
      super.new(name,parent);
    endfunction
      
      virtual function void end_of_elaboration();
        if(this.router_vi == null) begin
          `uvm_fatal("V__ERROR", "Interface not connected");
        end 
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
    
    class router_env extends uvm_env;
      `uvm_component_utils(router_env)
      packet_sequencer seqr;
      driver drv;
      
    function new (string name , uvm_component parent);
      super.new(name,parent);
    endfunction
      virtual function void build();
        super.build();
        seqr = packet_sequencer::type_id::create("seqr",this);
        drv = driver::type_id::create("drv",this);
      endfunction
      
      virtual function void connect();
        drv.seq_item_port.connect(seqr.seq_item_export);
      endfunction
    endclass
    
 //+_____________________________________+
    
    class test_base extends uvm_test;
      router_env env;
      router_vi_wrapper router_vi;
      `uvm_component_utils(test_base)
      
      function new (string name , uvm_component parent);
      super.new(name,parent);
    endfunction
      
      virtual function void build();
        super.build();
        router_vi = new("router_vi",ab.sigs);
        env = router_env::type_id::create("env",this); 
        set_config_object("env.*","router_vi",router_vi, 0);
        set_config_string("*.seqr","default_sequence","packet_sequence");
      endfunction
    endclass

//________________________________________

class packet_sequence extends uvm_sequence#(packet);
  packet req;
  `uvm_sequence_utils(packet_sequence,packet_sequencer)
  function new(string name = "packet_sequence");
    super.new(name);
  endfunction
  virtual task body();
    repeat(5) begin
      `uvm_do(req);
    end
  endtask
endclass

//__________________


//-------------___________------------
 module ab;
   intf sigs();
  initial begin
     run_test();
    sigs.clk = 0;
    #5 sigs.clk = ~sigs.clk;
 
   end
 endmodule
