`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2023 05:24:44 PM
// Design Name: 
// Module Name: testbench_MEM
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
`define CLK_PERIOD      10
`define DATA_MEMORY_DEPTH 256

module testbench_MEM();
//Parameters
    parameter DATA_MEMORY_ADDR_WIDTH = 32;
    parameter REGISTERS_WIDTH = 32;
    parameter REGISTERS_DEPTH = 32;
    parameter REGISTERS_ADDR_WIDTH = $clog2(REGISTERS_DEPTH);

    parameter   NB_PC = 32;         //Cantidad de bits del PC
    parameter   NB_RD = 5;          //Cantidad de bits del campo rd en las instrucciones
    parameter   NB_REG = 32;        // Cantidad de bits de los registros
    
    //inputs
    reg clk,reset, enable;
    
    reg [NB_REG -1 : 0] Write_Data;
    reg [NB_REG -1 :0] Write_addr_in;
    
    //Control signal inputs
    reg MemWrite,MemRead,RegWrite_in;
    reg [1:0] MemtoReg_in;
    reg [1:0] BHW;
    reg ExtSign;
    
    //outputs
    wire [NB_REG -1 : 0] Read_data,Alu_result;
    wire [NB_RD -1 :0] Write_addr;
    
    //control signals out
    wire[1:0] MemtoReg;
    wire RegWrite;
    
    //Testbench variables
    integer i;
    reg [DATA_MEMORY_ADDR_WIDTH - 1 : 0] Addr;

    always #`CLK_PERIOD clk = !clk;
	
	initial
	begin
        clk = 0;
        reset = 1'b1;
        
        enable = 1'b0 ;
        @(negedge clk) #1;
        reset = 1'b0;
        enable = 1'b1 ;
        
        MemWrite = 1'b1;
        MemRead = 1'b1;
        RegWrite_in = 1'b1;
        MemtoReg_in = 1'b1;

        Write_addr_in = 0;
        Write_Data = 8'h000000b0;
        BHW = 2'b10;
        ExtSign = 0;
        @(negedge clk) #1;
        //escritura
        i = 1'b0 ;
        while(i<`DATA_MEMORY_DEPTH/4)
        begin
            Write_addr_in = i*4;   
            @(posedge clk) #1;//Write data_memory[i] = i + 1
            @(negedge clk) #1;//Read data_memory[i]
            i = i + 1;
        end
        @(negedge clk) #1;
        //lectura
        i = 1'b0 ;
        BHW = 2'b01;
        ExtSign = 1;
        MemWrite = 1'b0;
        while(i<`DATA_MEMORY_DEPTH/2)
        begin
            Write_addr_in = i*2;   
            @(posedge clk) #1;//Write data_memory[i] = i + 1
            @(negedge clk) #1;//Read data_memory[i]
            i = i + 1;
        end
        
        
        @(negedge clk) #1;
        $finish;
	end
	
	MEM mem (
        //inputs
        .i_mem_clock(clk),
        .i_mem_reset(reset),
        .i_mem_dataW(Write_Data),
        .i_mem_dataALU(Write_addr_in),
        
        //control signals in
        .i_mem_MemWrite(MemWrite),
        .i_mem_MemRead(MemRead),
        .i_mem_RegWrite(RegWrite_in),
        .i_mem_MemtoReg(MemtoReg_in),
        .i_mem_BHW(BHW),
        .i_mem_ExtSign(ExtSign),
        
        //outputs
        .o_mem_dataR(Read_data),
        .o_mem_dataALU(Alu_result),
        .o_mem_write_reg(Write_addr),
        
        //control signals out
        .o_mem_MemtoReg(MemtoReg),
        .o_mem_RegWrite(RegWrite)
    );
endmodule
