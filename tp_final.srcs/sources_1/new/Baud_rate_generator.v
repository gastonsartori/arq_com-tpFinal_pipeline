`timescale 1ns / 1ps

//suponiendo clock 50mhz y br module 19200 
//contador modulo = 163

module Baud_rate_generator#(
    parameter N_MODULE = 2,
    parameter NB_COUNT = 9
    )(
    input wire i_clock,
    input wire i_reset,
    output wire o_tick
);

reg  [NB_COUNT-1:0]   count;
wire   			          count_flag; 

assign count_flag = count == N_MODULE;

always @(posedge i_clock)
begin
    if (i_reset || count_flag)
    begin
      count <= {NB_COUNT{1'b0}};
    end
    else
      count <= count + 1;
end

assign o_tick = count_flag;

endmodule
