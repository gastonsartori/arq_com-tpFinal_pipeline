`timescale 1ns / 1ps

`define CLK_PERIOD      10

module test_bench_IF();
    
    //Parameters
    parameter PC_WIDTH = 32;
    parameter WORD_WIDTH = 8;
    parameter INST_WIDTH = 32;
    parameter INST_INDEX_WIDTH = 26;
    parameter INST_MEMORY_DEPTH = 12;
    
    parameter   NB_PC = 32;         //Cantidad de bits del PC
    parameter   NB_INSTR = 32;       // Ancho de bits de las instrucciones
    parameter   NB_INST_INDEX = 26; //Cantidad de bits de instr_index
    parameter   CANT_SUMADOR = 1;    // Cantidad a sumar  en sumador
    
    //IF_top inputs
	reg clk, reset, enable;
    reg [1:0] pc_src;
    reg [NB_PC-1:0] pc_offset;
    reg [NB_PC-1:0] pc_jump;
    reg [NB_PC-1:0] pc_register;

    wire [NB_PC - 1 :0] pc_adder;
    wire [NB_INSTR - 1 :0] instruction;
    wire [NB_INST_INDEX-1 : 0] instr_index;
    wire tick;

    //Test Variables
    reg [INST_WIDTH-1:0] ram [INST_MEMORY_DEPTH-1:0]  ;
    reg     [$clog2 (INST_MEMORY_DEPTH) - 1 : 0]  i;
    reg     [$clog2 (INST_MEMORY_DEPTH) - 1 : 0]  j;
    integer fp_r;
	
	always #`CLK_PERIOD clk = !clk;

    initial
    begin
        $readmemh("out.mem",ram, 0);         //Cargo instrucciones
        enable = 1'b0;
        clk = 1'b0;

        // Pc multiplexor input
        pc_offset = 'haa;
        pc_src = 2'b00;
        pc_jump = 'h08;
        pc_register = 'hcc;

        @(posedge clk) #1;   
        reset = 1'b1;
        repeat(10)                                  //Resetear y esperar 10 ciclos de reloj
        @(posedge clk) #1;                   
        reset= 0;
        enable = 1'b1;
        
        @(posedge clk) #1;                   
        pc_src = 2'b10;
        
        @(posedge clk) #1;                   
        pc_src = 2'b00;
       
        #1000
        
        $finish;
    end
    
    IF IF(
        //Inputs
        .i_if_clock(clk),
        .i_if_reset(reset),

        .i_if_pc_offset(pc_offset),
        .i_if_pc_register(pc_register),
        .i_if_pc_jump(pc_jump),
        .i_if_pc_enable(enable),
        .i_if_mux_selector(pc_src),
        
        //outputs
        .o_if_pc_sum(pc_adder),
        .o_if_instruction(instruction)
    );  
    
endmodule
