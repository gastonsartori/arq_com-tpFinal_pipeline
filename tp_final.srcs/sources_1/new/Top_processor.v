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
    parameter   NB_REG = 32,        // Cantidad de bits de los registros
    parameter   NB_LEDS = 16,        // Cantidad de bits de los registros

    parameter   NB_RS = 5          //Cantidad de bits del campo rs en las instrucciones

)(
    input i_processor_clock,
    input i_processor_reset,
    input i_processor_rx,

    output [NB_LEDS - 1 : 0] o_processor_wb_data,
    output o_processor_tx 
);

wire [NB_INSTR-1:0] du_instr_data_to_pipeline;
wire [NB_PC-1:0] du_instr_addr_to_pipeline;
wire du_instr_done_to_pipeline;
wire du_enable_to_pipeline;
wire halt_to_debugunit;
wire [NB_PC-1:0] pc_to_debugunit;

wire [NB_RS - 1 :0] reg_addr_to_pipeline;
wire [NB_REG - 1 :0] reg_data_to_debugunit;

wire [NB_REG - 1 :0] read_data_to_debugunit;
wire [NB_REG - 1 :0] read_addr_to_pipeline;

wire output_clock;
wire ouput_locked;

clk_wiz_1 clock_wizard
(
    // Clock out ports
    .clk_out1(output_clock),     // output clk_out1
    // Status and control signals
    .reset(i_processor_reset), // input reset
    .locked(ouput_locked),       // output locked
   // Clock in ports
    .clk_in1(i_processor_clock)
);      // input clk_in1

Top_debug_unit Top_debug_unit(
    .i_top_du_clock(output_clock),
    .i_top_du_reset(i_processor_reset),
    .i_top_du_rx(i_processor_rx),
    .i_top_du_halt(halt_to_debugunit),
    .i_top_du_pc(pc_to_debugunit),
    .i_top_du_reg_data(reg_data_to_debugunit),
    .i_top_du_read_data(read_data_to_debugunit), //valor de la memoria leido

    .o_top_du_read_addr(read_addr_to_pipeline),
    .o_top_du_instr_data(du_instr_data_to_pipeline),
    .o_top_du_instr_addr(du_instr_addr_to_pipeline),
    .o_top_du_enable(du_enable_to_pipeline),
    .o_top_du_instr_done(du_instr_done_to_pipeline),
    .o_top_du_tx(o_processor_tx),
    .o_top_du_reg_addr(reg_addr_to_pipeline)
);

Top_pipeline Top_pipeline(
    .i_pipeline_clock(output_clock),
    .i_pipeline_reset(i_processor_reset),
    //.i_pipeline_start(),
    .i_pipeline_instr_done(du_instr_done_to_pipeline),
    .i_pipeline_instr_addr(du_instr_addr_to_pipeline<<2),
    .i_pipeline_instr_data(du_instr_data_to_pipeline),
    .i_pipeline_enable(du_enable_to_pipeline),
    .i_pipeline_reg_addr(reg_addr_to_pipeline),
    .i_pipeline_read_addr(read_addr_to_pipeline), //desde du, para direccion memoria

    .o_pipeline_read_data(read_data_to_debugunit),
    .o_pipeline_reg_data(reg_data_to_debugunit),
    .o_pipeline_WB_data(o_processor_wb_data),
    .o_pipeline_halt(halt_to_debugunit),
    .o_pipeline_pc(pc_to_debugunit)
);

endmodule
