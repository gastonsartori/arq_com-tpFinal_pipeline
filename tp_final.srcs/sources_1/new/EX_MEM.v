`timescale 1ns / 1ps

module EX_MEM#(
    parameter   NB_PC = 32,         //Cantidad de bits del PC
    parameter   NB_INSTR = 32,       // Ancho de bits de las instrucciones

    parameter   NB_RD = 5,          //Cantidad de bits del campo rd en las instrucciones
    parameter   NB_RT = 5,          //Cantidad de bits del campo rt en las instrucciones
    parameter   NB_RS = 5,          //Cantidad de bits del campo rs en las instrucciones
    parameter   NB_FUNCTION = 6,    //Cantidad de bits del campo funct en las instrucciones
    parameter   NB_OFFSET = 16,     //Cantidad de bits del campo inmediato en las instrucciones
    parameter   NB_DIR = 26,        //Cantidad de bits del campo direccion (instr_index) en las instrucciones
    parameter   NB_OP = 6,          //Cantidad de bits del campo op en las instrucciones

    parameter   NB_REG = 32        // Cantidad de bits de los registros
)(
    input                          i_ex_mem_clock,
    input                          i_ex_mem_reset, 
    input [NB_PC - 1 : 0]          i_ex_mem_pc,                //PC (sin offset sumado, para poder guardar la direccion de retorno si es necesario)
    input [NB_PC - 1 : 0]          i_ex_mem_pc_offset,         // Salida del sumador PC+offset
    input [NB_REG - 1 : 0]         i_ex_mem_alu_result,        // Resultado de la ALU
    input                          i_ex_mem_alu_zero,          // Señal de cero de la ALU
    input [NB_REG - 1 : 0]         i_ex_mem_dataB,             // Dato B (direccionado por rt) en la salida, para guardar en memoria
    input [NB_RD - 1 : 0]          i_ex_mem_write_reg,         // Salida del mux controlado por RegDst, registro de destino
    input                          i_ex_mem_MemRead,           
    input                          i_ex_mem_MemWrite,          
    input                          i_ex_mem_Branch,            
    input                          i_ex_mem_RegWrite,     
    input [1:0]                    i_ex_mem_MemtoReg,
    input [1:0]                    i_ex_mem_BHW,              //Señal de control que indica el tamaño del direccioonamiento (00->byte, 01->halfword, 10->word) 
    input                          i_ex_mem_ExtSign,          //Señal de control que indica si extender el signo del dato leido o no
    input                          i_ex_mem_flush,
    input                          i_ex_mem_enable,

    output reg [NB_PC - 1 : 0]          o_ex_mem_pc,            
    output reg [NB_PC - 1 : 0]          o_ex_mem_pc_offset,       
    output reg [NB_REG - 1 : 0]         o_ex_mem_alu_result,        
    output reg                          o_ex_mem_alu_zero,         
    output reg [NB_REG - 1 : 0]         o_ex_mem_dataB,            
    output reg [NB_RD - 1 : 0]          o_ex_mem_write_reg,        
    output reg                          o_ex_mem_MemRead,           
    output reg                          o_ex_mem_MemWrite,          
    output reg                          o_ex_mem_Branch,            
    output reg                          o_ex_mem_RegWrite,     
    output reg [1:0]                    o_ex_mem_MemtoReg,
    output reg [1:0]                    o_ex_mem_BHW,              //Señal de control que indica el tamaño del direccioonamiento (00->byte, 01->halfword, 10->word) 
    output reg                          o_ex_mem_ExtSign          //Señal de control que indica si extender el signo del dato leido o no
);

 always@(posedge i_ex_mem_clock) begin
    if(i_ex_mem_reset || i_ex_mem_flush) begin
        o_ex_mem_pc             <= 0;
        o_ex_mem_pc_offset      <= 0;
        o_ex_mem_alu_result     <= 0;
        o_ex_mem_alu_zero       <= 0;
        o_ex_mem_dataB          <= 0;
        o_ex_mem_write_reg      <= 0;
        o_ex_mem_MemRead        <= 0;
        o_ex_mem_MemWrite       <= 0;
        o_ex_mem_Branch         <= 0;
        o_ex_mem_RegWrite       <= 0;
        o_ex_mem_MemtoReg       <= 0;
        o_ex_mem_BHW            <= 0;
        o_ex_mem_ExtSign        <= 0;
    end
    else
    begin
        if(i_ex_mem_enable)
        begin
            o_ex_mem_pc             <= i_ex_mem_pc;
            o_ex_mem_pc_offset      <= i_ex_mem_pc_offset;
            o_ex_mem_alu_result     <= i_ex_mem_alu_result;
            o_ex_mem_alu_zero       <= i_ex_mem_alu_zero;
            o_ex_mem_dataB          <= i_ex_mem_dataB;
            o_ex_mem_write_reg      <= i_ex_mem_write_reg;
            o_ex_mem_MemRead        <= i_ex_mem_MemRead;
            o_ex_mem_MemWrite       <= i_ex_mem_MemWrite;
            o_ex_mem_Branch         <= i_ex_mem_Branch;
            o_ex_mem_RegWrite       <= i_ex_mem_RegWrite;
            o_ex_mem_MemtoReg       <= i_ex_mem_MemtoReg;
            o_ex_mem_BHW            <= i_ex_mem_BHW;
            o_ex_mem_ExtSign        <= i_ex_mem_ExtSign;
        end
    end
 end


endmodule
