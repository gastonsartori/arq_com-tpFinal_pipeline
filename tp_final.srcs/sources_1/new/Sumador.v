`timescale 1ns / 1ps
module Sumador#(
        parameter    NB_DATA = 32
    )
    (
        input   wire    [NB_DATA - 1 : 0]    i_sum_1,
        input   wire    [NB_DATA - 1 : 0]    i_sum_2,

        output   wire    [NB_DATA - 1 : 0]    o_sum
    );
    
    assign o_sum = i_sum_1 + i_sum_2;
    
endmodule
