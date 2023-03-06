`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/16/2023 10:11:30 AM
// Design Name: 
// Module Name: testbench_debug_unit
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


module testbench_debug_unit();

    parameter   NB_PC = 32;        // Bits de rs
    parameter   NB_INSTR = 32;          // Bits de instruccion
    parameter   NB_RX = 8;              // Bits de RX
    parameter INICIO_CARGA_CODE = 8'b00000001;
    parameter CODE_SEND_DATA = 8'b00000100;

reg clock, reset;
reg [NB_RX-1:0] rx_data;
reg rx_done;
reg tx_done;


wire [NB_INSTR-1:0] instr_data;
wire [NB_PC-1:0] instr_addr;
wire enable;
wire instr_done;
wire [NB_RX-1:0] tx_data;
wire tx_data_done;


always begin 
    #10 clock = !clock;
end

initial begin
    clock = 0;
    reset = 1;
    rx_data=0;
    rx_done=0;
    tx_done=0;

    #50
    reset = 0;
    rx_data=INICIO_CARGA_CODE;
    rx_done=1;
    #20
    rx_done=0;
    #20
    rx_data=8'b11111111;
    rx_done=1;
    #20
    rx_done=0;
    #20
    rx_data=8'b00000000;
    rx_done=1;
    #20
    rx_done=0;
    #20
    rx_data=8'b11111111;
    rx_done=1;
    #20
    rx_done=0;
    #20
    rx_data=8'b00000000;
    rx_done=1;
    #20
    rx_done=0;
    #40
    rx_data=INICIO_CARGA_CODE;
    rx_done=1;
    #20
    rx_done=0;
    #20
    rx_data=8'b11110000;
    rx_done=1;
    #20
    rx_done=0;
    #20
    rx_data=8'b00001111;
    rx_done=1;
    #20
    rx_done=0;
    #20
    rx_data=8'b11110000;
    rx_done=1;
    #20
    rx_done=0;
    #20
    rx_data=8'b00001111;
    rx_done=1;
    #20
    rx_done=0;

    #20
    tx_done=1;
    rx_data=CODE_SEND_DATA;
    rx_done=1;
    #20
    tx_done=0;
    rx_done=0;
    #20
    tx_done=0;
    #20
    tx_done=1;
    #20
    tx_done=0;
    #20
    tx_done=1;
    #20
    tx_done=0;
    #20
    tx_done=1;
    #20
    tx_done=0;
    
    #100

    $finish;



end


Debug_unit Debug_unit(
    .i_debugunit_clock(clock),
    .i_debugunit_reset(reset),
    .i_debugunit_rx_data(rx_data),
    .i_debugunit_rx_done(rx_done),
    .i_debugunit_tx_done(tx_done),

    .o_debugunit_instr_data(instr_data),
    .o_debugunit_instr_addr(instr_addr),
    .o_debugunit_enable(enable), 
    .o_debugunit_instr_done(instr_done),
    .o_debugunit_tx_data(tx_data),
    .o_debugunit_tx_data_done(tx_data_done)
);

endmodule
