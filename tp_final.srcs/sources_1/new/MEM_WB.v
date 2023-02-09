`timescale 1ns / 1ps

module MEM_WB#(
    parameter   NB_PC = 32,         //Cantidad de bits del PC
    parameter   NB_RD = 5,          //Cantidad de bits del campo rd en las instrucciones
    parameter   NB_REG = 32        // Cantidad de bits de los registros
)(  
    input                       i_mem_wb_clock,
    input                       i_mem_wb_reset,
    input [NB_REG - 1 : 0]      i_mem_wb_dataR,            //Dato leido de memoria
    input [NB_REG - 1 : 0]      i_mem_wb_dataALU,          //Dato de salida de la alu
    input [NB_RD - 1 : 0]       i_mem_wb_write_reg,        //Registro de destino
    input [NB_PC - 1 : 0]       i_mem_wb_pc,
    input [1:0]                 i_mem_wb_MemtoReg,
    input                       i_mem_wb_RegWrite,
    input                       i_mem_wb_enable,

    output reg [NB_REG - 1 : 0]      o_mem_wb_dataR,            //Dato leido de memoria
    output reg [NB_REG - 1 : 0]      o_mem_wb_dataALU,          //Dato de salida de la alu
    output reg [NB_RD - 1 : 0]       o_mem_wb_write_reg,        //Registro de destino
    output reg [NB_PC - 1 : 0]       o_mem_wb_pc,
    output reg [1:0]                 o_mem_wb_MemtoReg,
    output reg                       o_mem_wb_RegWrite
);

always@(posedge i_mem_wb_clock)
begin
    if(i_mem_wb_reset)
    begin
        o_mem_wb_dataR      <=0;
        o_mem_wb_dataALU    <=0;    
        o_mem_wb_write_reg  <=0;
        o_mem_wb_pc         <=0;
        o_mem_wb_MemtoReg   <=0;
        o_mem_wb_RegWrite   <=0;
    end
    else if(i_mem_wb_enable)
    begin
        o_mem_wb_dataR      <= i_mem_wb_dataR;
        o_mem_wb_dataALU    <= i_mem_wb_dataALU;    
        o_mem_wb_write_reg  <= i_mem_wb_write_reg;
        o_mem_wb_pc         <= i_mem_wb_pc;
        o_mem_wb_MemtoReg   <= i_mem_wb_MemtoReg;
        o_mem_wb_RegWrite   <= i_mem_wb_RegWrite;
    end
end

endmodule
