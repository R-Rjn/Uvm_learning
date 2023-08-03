program automatic simple_test;
  import uvm_pkg::*;
  
  class uvm_world extends uvm_test;
    `uvm_component_utils(uvm_world)
    function new(string name,uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    function int gg(input int nt);
      nt = (nt*2)+3;
      return nt;
    endfunction
    
    virtual task run();
      $display("we have solved value gg = %0d",gg(4));
    endtask
    
  endclass
  initial
    run_test();
endprogram
