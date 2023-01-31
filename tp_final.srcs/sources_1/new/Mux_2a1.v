`timescale 1ns / 1ps

module Mux_2a1#(
    
    parameter   NB_DATA = 32
)
(
    input   wire                            i_mux_control,
    input   wire    [NB_DATA - 1 : 0]       i_mux_1,
    input   wire    [NB_DATA - 1 : 0]       i_mux_2,

    output  wire    [NB_DATA - 1 : 0]       o_mux

);

//Registros
reg [NB_DATA - 1 : 0] reg_mux;

always @ (*) begin
    case (i_mux_control)
        1'b0 : reg_mux <= i_mux_1;
        1'b1 : reg_mux <= i_mux_2;   
    endcase
end

assign o_mux = reg_mux;

endmodule
