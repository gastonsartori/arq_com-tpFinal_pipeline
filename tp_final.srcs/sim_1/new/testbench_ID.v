`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2023 09:47:23 AM
// Design Name: 
// Module Name: testbench_ID
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

//INSTRUCCIONES GUARDADAS EN mem.out
/*
addi 0,1,5 ; reg[0] = reg[1] + 5 
sw 0,10(0) ; memory[reg[10] + 0] = reg[0] 
addi 0,0,5 ; reg[0] = reg[0] + 5
lw 2,10(0); reg[2] = memory[reg[10]+0]
sub 3,0,2 ; reg[3] = reg[0] - reg[2]
srl 4,3,2 ; reg[4] = reg[3] >> 2
beq 4,3,2 ; if(reg[3]==reg[4])jump pc+2
j 6 ; jump 6
slt 5,3,4 ; reg[5]=(reg[3]<reg[4])
jalr 6,2 ; reg[6] = return address  ; jump reg[2]
srav 7,3,0 ; reg[3] >> reg[0]
xori 8,6,7 ; reg[8] = reg[6] xori reg[7]
*/

`define CLK_PERIOD      10

module testbench_ID();

    parameter   NB_PC = 32;         //Cantidad de bits del PC
    parameter   NB_INSTR = 32;       // Ancho de bits de las instrucciones
    parameter   NB_RD = 5;          //Cantidad de bits del campo rd en las instrucciones
    parameter   NB_RT = 5;          //Cantidad de bits del campo rt en las instrucciones
    parameter   NB_RS = 5;          //Cantidad de bits del campo rs en las instrucciones
    parameter   NB_FUNCTION = 6;    //Cantidad de bits del campo funct en las instrucciones
    parameter   NB_OFFSET = 16;     //Cantidad de bits del campo inmediato en las instrucciones
    parameter   NB_DIR = 26;        //Cantidad de bits del campo direccion (instr_index) en las instrucciones
    parameter   NB_OP = 6;          //Cantidad de bits del campo op en las instrucciones
    parameter   NB_REG = 32;        // Cantidad de bits de los registros
    parameter   NB_ALUOP = 4;   //Cantidad de bits para determinar el tipo de operacion

    parameter INST_MEMORY_DEPTH = 64;

    //Señales de entrada al modulo ID
    reg clk,reset;
    reg write_enable;
    reg [NB_PC - 1 :0] pc;
    reg [NB_INSTR - 1 :0] instruction;
    reg [NB_RD - 1 : 0] write_reg;
    reg [NB_REG - 1 :0] write_data;
    //Señales de control de entrada
    reg RegWrite, Branch, Zero, control_enable;
    reg [1:0] i_PcSrc_MEM;

    //Señales de salida
    wire [NB_PC - 1 :0] o_pc;
    wire [NB_REG - 1 :0] o_dataA,o_dataB;
    wire [NB_REG - 1 :0] o_offset;
    wire [NB_RT - 1 :0] o_rt;
    wire [NB_RD - 1 :0] o_rd;
    wire [NB_RS - 1 :0] o_rs;
    //Señales de control de salida
    wire o_Branch, o_MemRead, o_MemWrite, o_RegWrite;
    wire [NB_ALUOP-1:0] o_ALUop;
    wire [1:0] o_ALUSrc,o_RegDst,o_MemtoReg,o_PcSrc;
    wire o_EX_MEM_Flush,o_IF_ID_Flush;
    wire [1:0] o_PC_mux_selector;

    //Test Variables
    reg [NB_INSTR-1:0] ram [INST_MEMORY_DEPTH-1:0]  ;
    integer i;
    
    always #`CLK_PERIOD clk = !clk;
    
    initial
    begin
        //se carga desde archivo 
        $readmemh("out.mem",ram);
        clk = 1'b0;
        reset =        1'b1;
        write_reg = 1'b00000;
        write_data = 'h10101010;
        pc = 13;
        i = 0;
        control_enable = 1'b1;
        RegWrite = 1'b0;
        Branch = 1'b0;
        Zero = 1'b0;
        write_enable = 1'b0;
        i_PcSrc_MEM = 2'b10;
        @(negedge clk) #1;
        reset = 1'b0;
        write_enable = 1'b1;
        RegWrite = 1'b1;
            while(ram[i] == ram[i])
            begin
                   instruction = ram[i];
                   @(negedge clk)#1;
                   i = i + 1 ;
            end
        @(negedge clk) #1; 
        Branch = 1'b1;
        Zero = 1'b1;
        #40
        $finish;
	end

    ID ID (

        .i_id_clock(clk),
        .i_id_reset(reset),
        .i_id_pc(pc),
        .i_id_instruction(instruction),
        .i_id_write_reg(write_reg),
        .i_id_write_data(write_data),
        .i_id_write_enable(write_enable),

        .i_id_RegWrite(RegWrite),
        .i_id_zero(Zero),
        .i_id_control_enable(control_enable),
        .i_id_branch(Branch),

        .i_id_PcSrc_MEM(i_PcSrc_MEM),
        
        .o_id_dataA(o_dataA),
        .o_id_dataB(o_dataB),
        .o_id_offset_ext(o_offset),
        .o_id_rt(o_rt),
        .o_id_rd(o_rd),
        .o_id_rs(o_rs),
        .o_id_pc(o_pc),
        
        .o_id_RegWrite(o_RegWrite),
        .o_id_Branch(o_Branch),
        .o_id_MemRead(o_MemRead),
        .o_id_MemWrite(o_MemWrite),
        .o_id_RegDst(o_RegDst),
        .o_id_ALUOp(o_ALUop),
        .o_id_ALUSrc(o_ALUSrc),
        .o_id_MemtoReg(o_MemtoReg),
        .o_id_PcSrc(o_PcSrc),

        .o_id_IF_ID_Flush(o_IF_ID_Flush),
        .o_id_EX_MEM_Flush(o_EX_MEM_Flush),
        .o_id_PC_mux_selector(o_PC_mux_selector)
    );

endmodule
