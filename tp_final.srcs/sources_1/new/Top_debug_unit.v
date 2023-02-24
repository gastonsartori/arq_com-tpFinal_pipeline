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
    parameter   NB_RX = 8,              // Bits de RX
    parameter   NB_TX = 8,              // Bits de TX
    parameter   NB_RS = 5,
    parameter   NB_REG = 32
    

)(
    input i_top_du_clock,
    input i_top_du_reset,
    input i_top_du_rx,
    input i_top_du_halt,
    input [NB_PC-1:0] i_top_du_pc,
    input [NB_REG-1:0] i_top_du_reg_data,
    input [NB_REG-1:0] i_top_du_read_data, //valor de la memoria leido

    output [NB_REG-1:0] o_top_du_read_addr,
    output [NB_INSTR-1:0] o_top_du_instr_data,
    output [NB_PC-1:0] o_top_du_instr_addr,
    output o_top_du_enable, //señal que permite avanzar un ciclo en el pipeline o no, modo paso a paso
    output o_top_du_instr_done,
    output [NB_RS-1:0] o_top_du_reg_addr,

    output o_top_du_tx
);

wire tick;
wire [NB_RX-1:0] rx_data_to_du;
wire rx_done_to_du;
wire [NB_TX-1:0] data_to_tx;
wire data_done_to_tx;
wire tx_done_to_du;

Receiver Receiver(
    .i_rx(i_top_du_rx), //entrada en serie
    .i_clock(i_top_du_clock),
    .i_reset(i_top_du_reset),
    .i_tick(tick),
    .o_rx_data(rx_data_to_du), //salida en paralelo de 8 bits
    .o_rx_done(rx_done_to_du)
);

Transmitter Transmitter(
    .i_data(data_to_tx),
    .i_done(data_done_to_tx),
    .i_tick(tick),
    .i_clock(i_top_du_clock),
    .i_reset(i_top_du_reset),

    .o_tx(o_top_du_tx),
    .o_tx_done(tx_done_to_du)
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
    .i_debugunit_pc(i_top_du_pc),
    .i_debugunit_tx_done(tx_done_to_du),
    .i_debugunit_reg_data(i_top_du_reg_data),
    .i_debugunit_read_data(i_top_du_read_data), //valor de la memoria leido

    .o_debugunit_read_addr(o_top_du_read_addr),
    .o_debugunit_instr_data(o_top_du_instr_data),
    .o_debugunit_instr_addr(o_top_du_instr_addr),
    .o_debugunit_enable(o_top_du_enable), 
    .o_debugunit_instr_done(o_top_du_instr_done),
    .o_debugunit_tx_data(data_to_tx),
    .o_debugunit_tx_data_done(data_done_to_tx),
    .o_debugunit_reg_addr(o_top_du_reg_addr)
);

endmodule
