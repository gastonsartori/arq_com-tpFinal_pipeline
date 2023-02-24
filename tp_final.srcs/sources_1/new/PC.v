`timescale 1ns / 1ps

module PC#(
       parameter    NB_PC = 32,
       parameter    HALT_OPCODE = 'hffffffff,
       parameter    INST_MEMORY_BITS=26
    )    
    (
        input wire                                  i_pc_enable,
        input wire                                  i_pc_clock,
        input wire                                  i_pc_reset,    
        input wire                                  i_pc_halt,
        input wire    [NB_PC - 1 : 0]               i_pc_mux,
   
        output wire   [NB_PC - 1 : 0]               o_pc
    );
    
    reg [NB_PC - 1 : 0] pc;
    
    assign o_pc = pc;
    
    always@(posedge i_pc_clock)
        if(i_pc_reset) 
        begin
            pc <= 0;
        end
        else if(i_pc_enable && ~i_pc_halt)
        begin
            pc <= i_pc_mux;
        end
        else 
        begin
            pc <= pc;
        end
       
endmodule