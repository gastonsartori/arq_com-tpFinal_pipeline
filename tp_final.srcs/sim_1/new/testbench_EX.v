`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2023 04:04:44 PM
// Design Name: 
// Module Name: testbench_EX
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
`define INST_FUNCTION i_offset[6 - 1 : 0]
`define RTYPE_ALUCODE   'b0000//for RTYPE instructions ,map to ARITH operation ,specified in function segment of instruction
`define ORI_ALUCODE     'b0011//for ORI instruction ,map to OR operation
`define ADD_FUNCTIONCODE   'b100001
`define CLK_PERIOD      10
module testbench_EX();
    
    //Test Parameters
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
    parameter   NB_ALUCODE  = 4;
    
    //Inputs
    reg clk,reset,enable;
    reg [NB_PC - 1 :0] i_pc;
    reg [NB_REG - 1 :0] i_offset;
    reg [NB_REG - 1 :0] i_dataA,i_dataB;
    reg [NB_RD - 1 : 0] i_rd;
    reg [NB_RT - 1 : 0] i_rt;
    reg [NB_REG - 1 :0] i_data_MEM;
    reg [NB_REG - 1 :0] i_data_WB;
    reg [1:0] i_control_corto1,i_control_corto2;
    
    //Control signal inputs
    reg [1:0] RegDst;
    reg [1:0] AluSrc;
    reg [NB_ALUOP - 1 : 0] Aluop;
    
    //Outputs
    wire [NB_PC - 1 :0] o_pc, o_offset;
    wire [NB_REG - 1 :0] o_dataB;
    wire [NB_RD - 1 :0] o_write_reg;
    wire [NB_REG - 1 :0] o_alu_result;
    //control signal outputs
    wire Branch,MemRead,MemWrite,Zero,RegWrite;
    wire [1:0] MemtoReg;
    wire [1:0] BHW;
    wire ExtSign;
    
    always #`CLK_PERIOD clk = !clk;
	
	initial begin
        
        clk =          1'b0;
        reset =        1'b1;
        enable =       1'b0;
        @(negedge clk) #1;   
        reset =        1'b0;
        enable =       1'b1;
        @(negedge clk) #1;  
        i_pc = 15;
        i_dataA = 1;
        i_dataB = 2;
        i_data_MEM = 5;
        i_data_WB = 0;
        i_control_corto1 = 'b00;
        i_control_corto2 = 'b00;
        i_offset = 0;
        i_rd = 5;
        i_rt = 6;                 // 1 ADD 2 = 3
        
        //control signals
        RegDst = 0;//write addr <- rt
        Aluop = `RTYPE_ALUCODE;//Rtype instruction ,add alu operation
        `INST_FUNCTION = `ADD_FUNCTIONCODE;
        AluSrc[0] = 1'b0;//operand 1 <- dataA
        AluSrc[1] = 1'b0;//operand 2 <- dataB
        @(negedge clk) #1;
    
        @(negedge clk) #1;      // 1 ORI 8 = 9 
        RegDst = 0;//write addr <- rt
        Aluop = `ORI_ALUCODE;//Itype instruction ,ori alu operation
        i_offset = 8;
        AluSrc[0] = 1'b0;//operand 1 <- dataA (1)
        AluSrc[1] = 1'b1;//operand 2 <- offset (8) 
        @(negedge clk) #1;   // 1 ORI 10 = 11
        i_offset = 10;
        @(negedge clk) #1; // 
        `INST_FUNCTION = `ADD_FUNCTIONCODE;
        AluSrc[0] = 1'b0;//operand 1 <- dataA (1)
        AluSrc[1] = 1'b0;//operand 2 <- dataB 
        i_control_corto1 = 'b01; //operand 1 <-EX/MEM Alu_result (b)
        i_control_corto2 = 'b10; //operand 2 <-MEM/WB Alu_result (5)
        @(negedge clk) #1; // 
        i_offset = 10;
        Aluop = 4'b0011;
        AluSrc[0] = 1'b1;//operand 1 <- dataB (1)
        AluSrc[1] = 1'b1;//operand 2 <- offset
        i_control_corto1 = 'b10; //operand 1 <-MEM/WB Alu_result (5)
        i_control_corto2 = 'b01; //operand 2 
        @(negedge clk) #1; // SLL
        i_offset = 100;
        `INST_FUNCTION = 6'b000000;
        Aluop = `RTYPE_ALUCODE;
        AluSrc[0] = 1'b1;//operand 1 <- dataA (1)
        AluSrc[1] = 1'b1;//operand 2 <- offset
        i_control_corto1 = 'b10; //operand 1 <-MEM/WB Alu_result (5)
        i_control_corto2 = 'b01; //operand 2 <-EX/MEM Alu_result (b)
        @(negedge clk) #1;
        reset = 1;          //reset module
        @(negedge clk) #1;
        reset = 0;
        $finish;
	end
	
	EX EX(
        
        .i_ex_clock(clk),
        .i_ex_reset(reset),
        .i_ex_pc(i_pc),
        .i_ex_offset(i_offset),
        .i_ex_dataA(i_dataA),
        .i_ex_dataB(i_dataB),
        .i_ex_rt(i_rt),
        .i_ex_rd(i_rd),
        .i_ex_control_corto1(i_control_corto1),
        .i_ex_control_corto2(i_control_corto2),
        .i_ex_data_MEM(i_data_MEM),
        .i_ex_data_WB(i_data_WB),
        
        //control signals in
        .i_ex_RegDst(RegDst),
        .i_ex_ALUOp(Aluop),
        .i_ex_ALUSrc(AluSrc),
        .i_ex_MemRead('b0),//control signals not used in this stage
        .i_ex_MemWrite('b0),
        .i_ex_Branch('b0),
        .i_ex_MemtoReg('b0),
        
        //Outputs
        .o_ex_pc(o_pc),
        .o_ex_pc_offset(o_offset),
        .o_ex_write_reg(o_write_reg),
        .o_ex_dataB(o_dataB),
        .o_ex_alu_result(o_alu_result),
        
        //Control signals out
        .o_ex_Branch(Branch),
        .o_ex_MemRead(MemRead),
        .o_ex_MemWrite(MemWrite),
        .o_ex_alu_zero(Zero),
        .o_ex_MemtoReg(MemtoReg),
        .o_ex_RegWrite(RegWrite),
        .o_ex_BHW(BHW),
        .o_ex_ExtSign(ExtSign)

    );
    
endmodule

