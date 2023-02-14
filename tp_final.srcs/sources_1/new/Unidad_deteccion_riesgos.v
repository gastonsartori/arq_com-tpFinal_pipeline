`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2023 12:06:22 PM
// Design Name: 
// Module Name: Unidad_deteccion_riesgos
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


module Unidad_deteccion_riesgos#(      
    parameter   NB_RT = 5,         
    parameter   NB_RS = 5 
)(
    input               i_riesgounit_ID_EX_MemRead,
    input [NB_RT-1:0]   i_riesgounit_ID_EX_rt,
    input [NB_RS-1:0]   i_riesgounit_IF_ID_rs,
    input [NB_RT-1:0]   i_riesgounit_IF_ID_rt,

    output reg o_riesgounit_PCWrite,
    output reg o_riesgounit_IF_IDWrite,
    output reg o_riesgounit_Control_enable
);

always@(*) begin

    if(i_riesgounit_ID_EX_MemRead && ((i_riesgounit_ID_EX_rt == i_riesgounit_IF_ID_rs) || (i_riesgounit_ID_EX_rt == i_riesgounit_IF_ID_rt)))
    begin
        o_riesgounit_PCWrite = 0;
        o_riesgounit_IF_IDWrite = 0;
        o_riesgounit_Control_enable = 0;
    end
    else
    begin
        o_riesgounit_PCWrite = 1;
        o_riesgounit_IF_IDWrite = 1;
        o_riesgounit_Control_enable = 1;
    end

end

endmodule
