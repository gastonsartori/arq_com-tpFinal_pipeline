`timescale 1ns / 1ps

module ID_EX#(

    parameter   NB_PC = 32,         //Cantidad de bits del PC
    parameter   NB_INSTR = 32,       // Ancho de bits de las instrucciones

    parameter   NB_RD = 5,          //Cantidad de bits del campo rd en las instrucciones
    parameter   NB_RT = 5,          //Cantidad de bits del campo rt en las instrucciones
    parameter   NB_RS = 5,          //Cantidad de bits del campo rs en las instrucciones
    parameter   NB_FUNCTION = 6,    //Cantidad de bits del campo funct en las instrucciones
    parameter   NB_OFFSET = 16,     //Cantidad de bits del campo inmediato en las instrucciones
    parameter   NB_DIR = 26,        //Cantidad de bits del campo direccion (instr_index) en las instrucciones
    parameter   NB_OP = 6,          //Cantidad de bits del campo op en las instrucciones

    parameter   NB_REG = 32,        // Cantidad de bits de los registros

    parameter   NB_ALUOP = 4   //Cantidad de bits para determinar el tipo de operacion 
)(
    input                   i_id_ex_clock,
    input                   i_id_ex_reset,
    input                   i_id_ex_write_enable,

    input [NB_PC - 1 :0]    i_id_ex_pc,
    input [NB_REG - 1 :0]   i_id_ex_dataA, i_id_ex_dataB,
    input [NB_REG - 1 :0]   i_id_ex_offset_ext,
    input [NB_RT - 1 :0]    i_id_ex_rt,
    input [NB_RD - 1 :0]    i_id_ex_rd,
    input [NB_RD - 1 :0]    i_id_ex_rs,
    input [1:0]             i_id_ex_PcSrc,    
    input [1:0]             i_id_ex_RegDst,   
    input [1:0]             i_id_ex_ALUSrc,   
    input [NB_ALUOP-1:0]    i_id_ex_ALUOp,    
    input                   i_id_ex_MemRead,  
    input                   i_id_ex_MemWrite, 
    input                   i_id_ex_Branch,   
    input                   i_id_ex_RegWrite, 
    input [1:0]             i_id_ex_MemtoReg,
    input [1:0]             i_id_ex_BHW,              //Señal de control que indica el tamaño del direccioonamiento (00->byte, 01->halfword, 10->word) 
    input                   i_id_ex_ExtSign,          //Señal de control que indica si extender el signo del dato leido o no
    input [NB_PC-1:0]       i_id_ex_jump_addr,

    output reg [NB_PC - 1 :0]    o_id_ex_pc,
    output reg [NB_REG - 1 :0]   o_id_ex_dataA, o_id_ex_dataB,
    output reg [NB_REG - 1 :0]   o_id_ex_offset_ext,
    output reg [NB_RT - 1 :0]    o_id_ex_rt,
    output reg [NB_RD - 1 :0]    o_id_ex_rd,
    output reg [NB_RD - 1 :0]    o_id_ex_rs,
    output reg [1:0]             o_id_ex_PcSrc,    
    output reg [1:0]             o_id_ex_RegDst,   
    output reg [1:0]             o_id_ex_ALUSrc,   
    output reg [NB_ALUOP-1:0]    o_id_ex_ALUOp,    
    output reg                   o_id_ex_MemRead,  
    output reg                   o_id_ex_MemWrite, 
    output reg                   o_id_ex_Branch,   
    output reg                   o_id_ex_RegWrite, 
    output reg [1:0]             o_id_ex_MemtoReg, 
    output reg [1:0]             o_id_ex_BHW,              //Señal de control que indica el tamaño del direccioonamiento (00->byte, 01->halfword, 10->word) 
    output reg                   o_id_ex_ExtSign,          //Señal de control que indica si extender el signo del dato leido o no
    output reg [NB_PC-1:0]       o_id_ex_jump_addr

);

always@(posedge i_id_ex_clock) 
begin
       if(i_id_ex_reset)
       begin
            o_id_ex_pc <= 0;
            o_id_ex_dataA <=0;
            o_id_ex_dataB <=0;
            o_id_ex_offset_ext <=0;
            o_id_ex_rt <=0;
            o_id_ex_rd <=0;
            o_id_ex_rs <=0;
            o_id_ex_PcSrc <=0;
            o_id_ex_RegDst <=0;
            o_id_ex_ALUSrc <=0;
            o_id_ex_ALUOp <=0;
            o_id_ex_MemRead <=0;
            o_id_ex_MemWrite <=0;
            o_id_ex_Branch <=0;
            o_id_ex_RegWrite <=0;
            o_id_ex_MemtoReg <=0;
            o_id_ex_BHW <= 0;
            o_id_ex_ExtSign <= 0;
            o_id_ex_jump_addr <= 0;
       end
       else if(i_id_ex_write_enable) // Si la Stall Unit habilita la escritura
       begin 
            o_id_ex_pc <= i_id_ex_pc;
            o_id_ex_dataA <= i_id_ex_dataA;
            o_id_ex_dataB <= i_id_ex_dataB;
            o_id_ex_offset_ext <= i_id_ex_offset_ext;
            o_id_ex_rt <= i_id_ex_rt;
            o_id_ex_rd <= i_id_ex_rd;
            o_id_ex_rs <= i_id_ex_rs;
            o_id_ex_PcSrc <= i_id_ex_PcSrc;
            o_id_ex_RegDst <= i_id_ex_RegDst;
            o_id_ex_ALUSrc <= i_id_ex_ALUSrc;
            o_id_ex_ALUOp <= i_id_ex_ALUOp;
            o_id_ex_MemRead <= i_id_ex_MemRead;
            o_id_ex_MemWrite <= i_id_ex_MemWrite;
            o_id_ex_Branch <= i_id_ex_Branch;
            o_id_ex_RegWrite <= i_id_ex_RegWrite;
            o_id_ex_MemtoReg <= i_id_ex_MemtoReg;
            o_id_ex_BHW <= i_id_ex_BHW;
            o_id_ex_ExtSign <= i_id_ex_ExtSign;
            o_id_ex_jump_addr <= i_id_ex_jump_addr;
       end
end


endmodule
