`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2023 03:41:15 PM
// Design Name: 
// Module Name: testbench_top_pipeline
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


module testbench_top_pipeline();

parameter   NB_REG = 32;        // Cantidad de bits de los registros

//Inputs
reg clock, reset,start;
//Output
wire [NB_REG-1 : 0] wb_data;

always
begin
    #10
    clock = !clock;
end

initial
begin
clock=0;
reset=1;
start=0;

#20

reset=0;
start=1;

#10000
$finish; 

end



Top_pipeline Top_pipeline(
    .i_pipeline_clock(clock), 
    .i_pipeline_reset(reset),
    .i_pipeline_start(start), 
    
    .o_pipeline_WB_data(wb_data)
);
endmodule
