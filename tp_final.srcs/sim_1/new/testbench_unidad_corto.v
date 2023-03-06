`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2023 05:40:06 PM
// Design Name: 
// Module Name: testbench_unidad_riesgos
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


module testbench_unidad_corto();
    parameter   NB_RD = 5;         
    parameter   NB_RT = 5;         
    parameter   NB_RS = 5;

    reg [NB_RT - 1 :0] ID_EX_rt;
    reg [NB_RS - 1 :0] ID_EX_rs;
    reg [NB_RD - 1 :0] MEM_WB_rd;
    reg [NB_RD - 1 :0] EX_MEM_rd;
    reg MEM_WB_RegWrite, EX_MEM_RegWrite;

    wire [1:0] corto1;
    wire [1:0] corto2;
    
    initial
    begin                   //No data hazard
        ID_EX_rt = 10;
        ID_EX_rs = 20;
        MEM_WB_rd = 30;
        EX_MEM_rd = 40;
        MEM_WB_RegWrite = 0;
        EX_MEM_RegWrite = 1;
        
        #10       //1a. EX/MEM.RegisterRd = ID/EX.RegisterRs
        ID_EX_rt = 10;  
        ID_EX_rs = 20;
        MEM_WB_rd = 30;
        EX_MEM_rd = 20;
        
        #10        //1b. EX/MEM.RegisterRd = ID/EX.RegisterRt
        ID_EX_rt = 10;
        ID_EX_rs = 20;
        MEM_WB_rd = 30;
        EX_MEM_rd = 10;
        
        #10        //2a. MEM/WB.RegisterRd = ID/EX.RegisterRs
        ID_EX_rt = 10;
        ID_EX_rs = 20;
        MEM_WB_rd = 20;
        EX_MEM_rd = 40;
        MEM_WB_RegWrite = 1;
        EX_MEM_RegWrite = 0;
        
        #10        //2b. MEM/WB.RegisterRd = ID/EX.RegisterRt
        ID_EX_rt = 10;
        ID_EX_rs = 20;
        MEM_WB_rd = 10;
        EX_MEM_rd = 40;
        
        #10
        $finish;
    end

Unidad_cortocircuito Unidad_cortocircuito (
    .i_cortounit_EX_MEM_RegWrite(EX_MEM_RegWrite),
    .i_cortounit_MEM_WB_RegWrite(MEM_WB_RegWrite),
    .i_cortounit_ID_EX_rs(ID_EX_rs),
    .i_cortounit_ID_EX_rt(ID_EX_rt),
    .i_cortounit_EX_MEM_write_reg(EX_MEM_rd),
    .i_cortounit_MEM_WB_write_reg(MEM_WB_rd),
    
    //outputs
    .o_cortounit_control_corto1(corto1),
    .o_cortounit_control_corto2(corto2)
);
endmodule
