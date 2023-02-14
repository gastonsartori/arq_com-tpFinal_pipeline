`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2023 10:07:01 AM
// Design Name: 
// Module Name: WB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module WB#(
    parameter   NB_PC = 32,         //Cantidad de bits del PC
    parameter   NB_RD = 5,          //Cantidad de bits del campo rd en las instrucciones
    parameter   NB_REG = 32        // Cantidad de bits de los registros

)(
    input [NB_REG - 1 : 0]      i_wb_dataR,            //Dato leido de memoria
    input [NB_REG - 1 : 0]      i_wb_dataALU,          //Dato de salida de la alu
    input [NB_RD - 1 : 0]       i_wb_write_reg,        //Registro de destino
    input [NB_PC - 1 : 0]       i_wb_pc,
    input [1:0]                 i_wb_MemtoReg,
    input                       i_wb_RegWrite,

    output [NB_REG - 1 : 0]     o_wb_data,              //Dato a escribir
    output [NB_RD - 1 : 0]      o_wb_reg,               //Registro destino
    output                      o_wb_RegWrite           //Señal de control
);

wire [NB_PC - 1 : 0] return_addr;

assign o_wb_reg = i_wb_write_reg;
assign o_wb_RegWrite = i_wb_RegWrite;

Sumador Sumador_EX(
    .i_sum_1(i_wb_pc),
    .i_sum_2(4),
    .o_sum(return_addr)
);     

Mux_4a1 Mux_WB_data(
    .i_mux_control(i_wb_MemtoReg),
    .i_mux_1(i_wb_dataR),
    .i_mux_2(i_wb_dataALU),
    .i_mux_3(return_addr), //o (i_wb_pc)
    .i_mux_4(0),        // No se usa esta entrada
    .o_mux(o_wb_data)
);  

endmodule
