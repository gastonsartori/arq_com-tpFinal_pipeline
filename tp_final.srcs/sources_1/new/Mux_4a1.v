`timescale 1ns / 1ps

module Mux_4a1#(
        
        parameter   NB_DATA = 32,
        parameter   NB_CONTROL = 2   
    )
    (
        input   wire    [NB_CONTROL - 1 : 0]  i_mux_control,
        input   wire    [NB_DATA - 1 : 0]    i_mux_1,
        input   wire    [NB_DATA - 1 : 0]    i_mux_2,
        input   wire    [NB_DATA - 1 : 0]    i_mux_3,
        input   wire    [NB_DATA - 1 : 0]    i_mux_4,
        output  wire    [NB_DATA - 1 : 0]    o_mux
    
    );
    
    //Registros
    reg [NB_DATA - 1 : 0] reg_mux;
    
    always @ (*) begin
        case (i_mux_control)
            2'b00 : reg_mux <= i_mux_1;
            2'b01 : reg_mux <= i_mux_2;
            2'b10 : reg_mux <= i_mux_3;
            2'b11 : reg_mux <= i_mux_4;    
        endcase
    end
    
    assign o_mux = reg_mux;

endmodule
