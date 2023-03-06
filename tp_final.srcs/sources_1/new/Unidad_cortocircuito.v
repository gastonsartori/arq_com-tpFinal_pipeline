`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2023 11:31:27 AM
// Design Name: 
// Module Name: Unidad_cortocircuito
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


module Unidad_cortocircuito#(
    parameter   NB_RD = 5,         
    parameter   NB_RT = 5,         
    parameter   NB_RS = 5 

)(
    input                   i_cortounit_EX_MEM_RegWrite,     //Señal de control si se escribe o no en registro
    input                   i_cortounit_MEM_WB_RegWrite,     //Señal de control si se escribe o no en registro
    input [NB_RS - 1 : 0]   i_cortounit_ID_EX_rs,            //rs de la instruccion a ejecutar
    input [NB_RT - 1 : 0]   i_cortounit_ID_EX_rt,            //rs de la instruccion a ejecutar
    input [NB_RD - 1 : 0]   i_cortounit_EX_MEM_write_reg,    //registro destino de la instr en MEM
    input [NB_RD - 1 : 0]   i_cortounit_MEM_WB_write_reg,    //registro destino de la instr en WB

    output reg [1 : 0]      o_cortounit_control_corto1,             //Control del mux de corto del operando 1
    output reg [1 : 0]      o_cortounit_control_corto2              //Control del mux de corto del operando 2
);

//Condiciones del cortocircuito
always@(*) begin

    //operando1 (rs)
    //if (i_cortounit_EX_MEM_RegWrite && i_cortounit_EX_MEM_write_reg != 0 && i_cortounit_EX_MEM_write_reg == i_cortounit_ID_EX_rs)
    if (i_cortounit_EX_MEM_RegWrite && i_cortounit_EX_MEM_write_reg == i_cortounit_ID_EX_rs)
        o_cortounit_control_corto1 = 2'b01; 
    //else if (i_cortounit_MEM_WB_RegWrite && i_cortounit_MEM_WB_write_reg != 0 && i_cortounit_MEM_WB_write_reg == i_cortounit_ID_EX_rs)
    else if (i_cortounit_MEM_WB_RegWrite && i_cortounit_MEM_WB_write_reg == i_cortounit_ID_EX_rs)
        o_cortounit_control_corto1 = 2'b10;   
    else
        o_cortounit_control_corto1 = 2'b00;    

    //operando2 (rt)    
    //if (i_cortounit_EX_MEM_RegWrite && i_cortounit_EX_MEM_write_reg != 0 && i_cortounit_EX_MEM_write_reg == i_cortounit_ID_EX_rt)
    if (i_cortounit_EX_MEM_RegWrite && i_cortounit_EX_MEM_write_reg == i_cortounit_ID_EX_rt)
        o_cortounit_control_corto2 = 2'b01; 
    //else if (i_cortounit_MEM_WB_RegWrite && i_cortounit_MEM_WB_write_reg != 0 && i_cortounit_MEM_WB_write_reg == i_cortounit_ID_EX_rt)
    else if (i_cortounit_MEM_WB_RegWrite && i_cortounit_MEM_WB_write_reg == i_cortounit_ID_EX_rt)
        o_cortounit_control_corto2 = 2'b10;   
    else
        o_cortounit_control_corto2 = 2'b00;
end

endmodule
