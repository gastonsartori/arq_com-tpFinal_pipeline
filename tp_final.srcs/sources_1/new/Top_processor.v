`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2023 11:06:59 AM
// Design Name: 
// Module Name: Top_processor
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


module Top_processor#(
    parameter   NB_PC = 32,        // Bits de rs
    parameter   NB_INSTR = 32,          // Bits de instruccion
    parameter   NB_REG = 32        // Cantidad de bits de los registros

)(
    input i_processor_clock,
    input i_processor_reset,
    input i_processor_rx,

    output [NB_REG - 1 : 0] o_procesor_wb_data
);

wire [NB_INSTR-1:0] du_instr_data_to_pipeline;
wire [NB_PC-1:0] du_instr_addr_to_pipeline;
wire du_instr_done_to_pipeline;
wire du_enable_to_pipeline;
wire halt_to_debugunit;

Top_debug_unit Top_debug_unit(
    .i_top_du_clock(i_processor_clock),
    .i_top_du_reset(i_processor_reset),
    .i_top_du_rx(i_processor_rx),
    .i_top_du_halt(halt_to_debugunit),

    .o_top_du_instr_data(du_instr_data_to_pipeline),
    .o_top_du_instr_addr(du_instr_addr_to_pipeline),
    .o_top_du_enable(du_enable_to_pipeline),
    .o_top_du_instr_done(du_instr_done_to_pipeline)
);

Top_pipeline Top_pipeline(
    .i_pipeline_clock(i_processor_clock),
    .i_pipeline_reset(i_processor_reset),
    //.i_pipeline_start(),
    .i_pipeline_instr_done(du_instr_done_to_pipeline),
    .i_pipeline_instr_addr(du_instr_addr_to_pipeline<<2),
    .i_pipeline_instr_data(du_instr_data_to_pipeline),
    .i_pipeline_enable(du_enable_to_pipeline),
    .o_pipeline_WB_data(o_procesor_wb_data),
    .o_pipeline_halt(halt_to_debugunit)
);

endmodule
