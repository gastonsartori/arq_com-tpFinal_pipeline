`timescale 1ns / 1ps

module MEM#(
    parameter   NB_PC = 32,         //Cantidad de bits del PC
    parameter   NB_RD = 5,          //Cantidad de bits del campo rd en las instrucciones
    parameter   NB_REG = 32        // Cantidad de bits de los registros
    
)(  
    input                               i_mem_clock,
    input                               i_mem_reset,
    input [NB_REG - 1 : 0]              i_mem_dataALU,          //Salida de la ALU, que direcciona la memoria
    input [NB_REG - 1 : 0]              i_mem_dataW,            //Segundo operando, que se guarda en intr STORE
    input [NB_RD - 1 : 0]               i_mem_write_reg,        //Registro de destino
    input [NB_PC - 1 : 0]               i_mem_pc,               //PC, para guardar direccion de retorno
    input                               i_mem_MemRead,          //Señal de control
    input                               i_mem_MemWrite,         //Señal de control
    input                               i_mem_RegWrite,         //Señal de control
    input [1:0]                         i_mem_MemtoReg,         //Señal de control
    input                               i_mem_enable,
    input [1:0]                         i_mem_BHW,              //Señal de control que indica el tamaño del direccioonamiento (00->byte, 01->halfword, 10->word) 
    input                               i_mem_ExtSign,          //Señal de control que indica si extender el signo del dato leido o no

    output [NB_REG - 1 : 0]             o_mem_dataR,            //Dato leido de memoria
    output [NB_REG - 1 : 0]             o_mem_dataALU,          //Dato de salida de la alu
    output [NB_RD - 1 : 0]              o_mem_write_reg,        //Registro de destino
    output [NB_PC - 1 : 0]              o_mem_pc,
    output [1:0]                        o_mem_MemtoReg,
    output                              o_mem_RegWrite
);

Memoria_datos Mem_data(
    .i_datamem_clock(i_mem_clock),
    .i_datamem_reset(i_mem_reset),
    .i_datamem_enable(i_mem_enable),
    .i_datamem_MemWrite(i_mem_MemWrite),
    .i_datamem_MemRead(i_mem_MemRead),
    .i_datamem_BHW(i_mem_BHW),
    .i_datamem_ExtSign(i_mem_ExtSign),
    .i_datamem_addr(i_mem_dataALU),
    .i_datamem_dataW(i_mem_dataW),
    .o_datamem_dataR(o_mem_dataR) 
);

assign o_mem_dataALU = i_mem_dataALU;
assign o_mem_write_reg = i_mem_write_reg;
assign o_mem_pc = i_mem_pc;
assign o_mem_MemtoReg = i_mem_MemtoReg;
assign o_mem_RegWrite = i_mem_RegWrite;

endmodule
