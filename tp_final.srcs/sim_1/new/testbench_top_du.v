`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/16/2023 11:09:44 AM
// Design Name: 
// Module Name: testbench_top_du
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


module testbench_top_du();

    parameter   NB_PC = 32;        // Bits de rs
    parameter   NB_INSTR = 32;          // Bits de instruccion
    parameter   NB_RX = 8;              // Bits de RX
    parameter INICIO_CARGA_CODE = 8'b00000001;

reg clock, reset;
wire rx;

wire [NB_INSTR-1:0] instr_data;
wire [NB_PC-1:0] instr_addr;
wire enable;
wire instr_done;
wire tx_done;

always begin 
    #10 clock = !clock;
end

reg [NB_RX-1:0] data_a_enviar;
reg data_done;


initial begin
    clock = 0;
    reset = 1;
    data_a_enviar=0;
    data_done=0;

    #50
    reset=0;
    #20
    data_a_enviar = INICIO_CARGA_CODE;
    data_done = 1;
    #20 
    data_done = 0;
    while(tx_done==0)
    
    #20
    data_a_enviar = 8'b00000001;
    data_done = 1;
    #20 
    data_done = 0;
    while(tx_done==0)
    #20
    data_a_enviar = 8'b00000010;
    data_done = 1;
        #20 
    data_done = 0;
    while(tx_done==0)
    
    #20
    data_a_enviar = 8'b00000011;
    data_done = 1;
        #20 
    data_done = 0;
        while(tx_done==0)
    
    #20
    data_a_enviar = 8'b00000100;
    data_done = 1;

    #1000000000
    
    $finish;



end

Transmitter Transmitter(
    .i_data(data_a_enviar),
    .i_done(data_done),
    .i_tick(tick),
    .i_clock(clock),
    .i_reset(reset),
    .o_tx(rx),
    .o_tx_done(tx_done)
);

Baud_rate_generator Baud_rate_generator(
    .i_clock(clock),
    .i_reset(reset),
    .o_tick(tick)
);

Top_debug_unit Top_debug_unit(
    .i_top_du_clock(clock),
    .i_top_du_reset(reset),
    .i_top_du_rx(rx),

    .o_top_du_instr_data(instr_data),
    .o_top_du_instr_addr(instr_addr),
    .o_top_du_enable(enable), 
    .o_top_du_instr_done(instr_done)
);

endmodule
