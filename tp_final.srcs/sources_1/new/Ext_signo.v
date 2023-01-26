`timescale 1ns / 1ps

module Ext_signo#(

        parameter   NB_DATA_IN   =   16,
        parameter   NB_DATA_OUT  =   32,
        parameter   NB_ADD = (NB_DATA_OUT-NB_DATA_IN)
    )(
        input [NB_DATA_IN-1:0] i_signext,
        output [NB_DATA_OUT-1:0] o_signext
    );

    assign o_signext = (i_signext[15] == 1) ? {{NB_ADD{1'b1}}, i_signext} : {{NB_ADD{1'b0}}, i_signext};
    //assign  o_signext    =   i_signext;

endmodule
