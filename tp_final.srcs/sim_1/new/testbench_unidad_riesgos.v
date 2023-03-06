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


module testbench_unidad_riesgos();
    parameter   NB_RT = 5;         
    parameter   NB_RS = 5;
    // Inputs
    reg ID_EX_MemRead;
    reg [NB_RS - 1 :0] IF_ID_rs;
    reg [NB_RT - 1 :0] IF_ID_rt;
    reg [NB_RT - 1 :0] ID_EX_rt;//
    
    // Outputs
    wire pc_Write;
    wire control_enable;
    wire IF_ID_write;

	initial	
	begin
        ID_EX_MemRead = 1;

        #10
        IF_ID_rs = 10;
        IF_ID_rt = 20;
        ID_EX_rt = 10;
        #10
        ID_EX_rt = 20;
        #10 
        ID_EX_rt = 5;
        #10  
        ID_EX_MemRead = 0;
        #10  
        
         $finish;
	end
	
	Unidad_deteccion_riesgos Unidad_deteccion_riesgos(
        //inputs
        .i_riesgounit_ID_EX_MemRead (ID_EX_MemRead),
        .i_riesgounit_IF_ID_rs (IF_ID_rs),
        .i_riesgounit_IF_ID_rt (IF_ID_rt),
        .i_riesgounit_ID_EX_rt(ID_EX_rt),
        
        //outputs
        .o_riesgounit_PCWrite(pc_Write),
        .o_riesgounit_Control_enable(control_enable),
        .o_riesgounit_IF_IDWrite(IF_ID_write) 
    );
endmodule
