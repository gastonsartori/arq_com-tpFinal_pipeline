`timescale 1ns / 1ps

module IF#(
    parameter   NB_PC = 32,         //Cantidad de bits del PC
    parameter   NB_INSTR = 32,       // Ancho de bits de las instrucciones
    parameter   NB_INST_INDEX = 26, //Cantidad de bits de instr_index
    parameter   CANT_SUMADOR = 4,    // Cantidad a sumar  en sumador
    parameter   HALT_INSTR = 32'b11111111111111111111111111111111
)(
    input               i_if_clock,
    input               i_if_reset,
    input [NB_PC-1:0]   i_if_pc_register,       //PC direccionado por rs (instr JR, JALR)
    input [NB_PC-1:0]   i_if_pc_offset,         //PC = PC+4+offset (ints Branch)
    input [NB_PC-1:0]   i_if_pc_jump,           //PC = PC_ID[31:28],inst_index[25:0],b'00            
    input [1:0]         i_if_mux_selector,      //Selector del mux de entrada del PC
    input               i_if_PCWrite,         // PC enable
    input               i_if_execute_branch,
    //Inputs para utilizar Debug Unit a traves de UART
    input               i_if_instr_done,        // Enable para escritura debug
    //input               i_if_read_e,         // Enable para lecutra debug
    input                i_if_mem_enable,     // Memoria enable
    input [NB_PC-1:0]    i_if_instr_addr,     // Direccion de escritura de instruccion
    input [NB_INSTR-1:0] i_if_instr_data,     // Instruccion a escribir en memoria de instrucciones

    output wire [NB_INSTR-1:0]   o_if_instruction,       //salida del banco de memoria, instruccion direccionada por PC
    output wire [NB_PC-1:0]      o_if_pc_sum,            //siguente PC, PC+4 (o PC+1)
    output reg                   o_if_halt,              //se activa cuando se leyo un halt desde la memoria de instrucciones
    output [NB_PC-1:0]               o_if_pc    //valor del pc a la debug unit
    );
    

//wire [NB_PC-1:0]    wire_instruction;  //salida de la memoria, instruccion

wire [NB_PC-1:0]    pc_sum;       //salida del sumador, pc sumado
wire [NB_PC-1:0]    mux_pc;
wire [NB_PC-1:0]    pc_mem;
wire [NB_PC-1:0]    mux1_mux2;

assign o_if_pc_sum = pc_sum;
assign o_if_pc = pc_mem;

always @ (*) begin
    if(o_if_instruction == HALT_INSTR)
        o_if_halt <= 1;
    else
        o_if_halt <= 0;
end

//Modules
Mux_4a1 Mux_4a1_IF(
    .i_mux_control(i_if_mux_selector),
    //.i_mux_control(reg_mux_selector),
    .i_mux_1(pc_sum),
    .i_mux_2(0),
    .i_mux_3(i_if_pc_jump),
    .i_mux_4(i_if_pc_register),
    .o_mux(mux1_mux2)
);

//mux para poder ejecutar un branch cuando sea detectado
Mux_2a1 Mux_2a1_IF(
    .i_mux_control(i_if_execute_branch),
    //.i_mux_control(reg_mux_selector),
    .i_mux_1(mux1_mux2),
    .i_mux_2(i_if_pc_offset),
    .o_mux(mux_pc)
);

PC PC(
    .i_pc_enable(i_if_PCWrite),
    .i_pc_clock(i_if_clock),
    .i_pc_reset(i_if_reset),
    .i_pc_halt(o_if_halt), // Ver para que esta
    .i_pc_mux(mux_pc),
    .o_pc(pc_mem)
);

Sumador Sumador_IF(
    .i_sum_1(pc_mem),
    .i_sum_2(CANT_SUMADOR),
    .o_sum(pc_sum)
);

Mem_instruction Mem_instruction(
    .i_instmem_clock(i_if_clock),
    .i_instmem_reset(i_if_reset),
    .i_instmem_read_e(i_if_read_e),
    .i_instmem_enable(i_if_mem_enable),
    .i_instmem_instr_addr(i_if_instr_addr),
    .i_instmem_instr_data(i_if_instr_data),
    .i_instmem_instr_done(i_if_instr_done),
    .i_instmem_pc(pc_mem),
    .o_instmem(o_if_instruction)
);
      

endmodule


