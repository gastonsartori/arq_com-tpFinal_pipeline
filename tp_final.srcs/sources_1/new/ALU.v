`timescale 1ns / 1ps

module ALU#(
    parameter   NB_DATA = 32,
    parameter   NB_ALUCODE = 4,

    parameter   SLL_ALUCODE     =   4'b0000,
    parameter   SRL_ALUCODE     =   4'b0001,
    parameter   SRA_ALUCODE     =   4'b0010,
    parameter   ADD_ALUCODE     =   4'b0011,
    parameter   SUB_ALUCODE     =   4'b0100,
    parameter   AND_ALUCODE     =   4'b0101,
    parameter   OR_ALUCODE      =   4'b0110,
    parameter   XOR_ALUCODE     =   4'b0111,
    parameter   NOR_ALUCODE     =   4'b1000,
    parameter   SLT_ALUCODE     =   4'b1001,
    parameter   SLLV_ALUCODE    =   4'b1010,
    parameter   SRLV_ALUCODE    =   4'b1011,
    parameter   SRAV_ALUCODE    =   4'b1100,
    parameter   LUI_ALUCODE     =   4'b1101,
    parameter   BNE_ALUCODE     =   4'b1110

)(
    input [NB_DATA-1:0] i_alu_operando1,    
    input [NB_DATA-1:0] i_alu_operando2,
    input [NB_ALUCODE-1:0] i_alu_code,

    output o_alu_zero,
    output  reg [NB_DATA-1:0] o_alu_result
);

wire signed [NB_DATA-1:0] i_alu_operando1_signed;
wire signed [NB_DATA-1:0] i_alu_operando2_signed;

assign i_alu_operando1_signed = i_alu_operando1;
assign i_alu_operando2_signed = i_alu_operando2;

always@(*) begin
    case(i_alu_code)
        SLL_ALUCODE     : o_alu_result = i_alu_operando1 << i_alu_operando2[10:6];      //  SLL Shift left logical (rt<<offset[10:6](sa))
        SRL_ALUCODE     : o_alu_result = i_alu_operando1 >> i_alu_operando2[10:6];      // SRL Shift right logical (rt>>offset[10:6](sa))
        SRA_ALUCODE     : o_alu_result = i_alu_operando1_signed >>> i_alu_operando2[10:6];     // SRA  Shift right arithmetic (rt>>>offset[10:6](sa))
        ADD_ALUCODE     : o_alu_result = i_alu_operando1 + i_alu_operando2;       // ADD Sum (rs+rt)
        SUB_ALUCODE     : o_alu_result = i_alu_operando1 - i_alu_operando2;       // SUB Substract (rs-rt)
        AND_ALUCODE     : o_alu_result = i_alu_operando1 & i_alu_operando2;       // AND Logical and (rs&rt)
        OR_ALUCODE      : o_alu_result = i_alu_operando1 | i_alu_operando2;       // OR Logical or (rs|rt)
        XOR_ALUCODE     : o_alu_result = i_alu_operando1 ^ i_alu_operando2;       // XOR Logical xor (rs^rt)
        NOR_ALUCODE     : o_alu_result = ~(i_alu_operando1 | i_alu_operando2);    // NOR Logical nor ~(rs|rt)
        SLT_ALUCODE     : o_alu_result = i_alu_operando1 < i_alu_operando2;       // SLT Compare (rs<rt)
        SLLV_ALUCODE    : o_alu_result = i_alu_operando2 << i_alu_operando1[4:0];      // SLLV (rt<<rs[4:0])
        SRLV_ALUCODE    : o_alu_result = i_alu_operando2 >> i_alu_operando1[4:0];      // SRLV (rt>>rs[4:0])
        SRAV_ALUCODE    : o_alu_result = i_alu_operando2_signed >>> i_alu_operando1[4:0];     // SRAV (rt>>>rs[4:0])
        LUI_ALUCODE     : o_alu_result = i_alu_operando2 << 16;                         // LUI (rt<<16)
        BNE_ALUCODE     : o_alu_result = (i_alu_operando1 == i_alu_operando2);        // NEQ         
        default         : o_alu_result = {NB_DATA{1'b0}}; 
    endcase
end

assign o_alu_zero = (o_alu_result == 0);

endmodule
