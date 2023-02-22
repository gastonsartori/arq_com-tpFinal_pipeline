`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/16/2023 10:42:59 AM
// Design Name: 
// Module Name: Top_debug_unit
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


module Top_debug_unit#(
    parameter   NB_PC = 32,        // Bits de rs
    parameter   NB_INSTR = 32,          // Bits de instruccion
    parameter   NB_RX = 8              // Bits de RX
)(
    input i_top_du_clock,
    input i_top_du_reset,
    input i_top_du_rx,
    input i_top_du_halt,

    output [NB_INSTR-1:0] o_top_du_instr_data,
    output [NB_PC-1:0] o_top_du_instr_addr,
    output o_top_du_enable, //señal que permite avanzar un ciclo en el pipeline o no, modo paso a paso
    output o_top_du_instr_done
);

wire tick;
wire [NB_RX-1:0] rx_data_to_du;
wire rx_done_to_du;

Receiver Receiver(
    .i_rx(i_top_du_rx), //entrada en serie
    .i_clock(i_top_du_clock),
    .i_reset(i_top_du_reset),
    .i_tick(tick),
    .o_rx_data(rx_data_to_du), //salida en paralelo de 8 bits
    .o_rx_done(rx_done_to_du)
);

Baud_rate_generator Baud_rate_generator(
    .i_clock(i_top_du_clock),
    .i_reset(i_top_du_reset),
    .o_tick(tick)
);

Debug_unit Debug_unit(
    .i_debugunit_clock(i_top_du_clock),
    .i_debugunit_reset(i_top_du_reset),
    .i_debugunit_rx_data(rx_data_to_du),
    .i_debugunit_rx_done(rx_done_to_du),
    .i_debugunit_halt(i_top_du_halt),

    .o_debugunit_instr_data(o_top_du_instr_data),
    .o_debugunit_instr_addr(o_top_du_instr_addr),
    .o_debugunit_enable(o_top_du_enable), 
    .o_debugunit_instr_done(o_top_du_instr_done)
);

endmodule
