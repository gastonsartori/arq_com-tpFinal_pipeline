`timescale 1ns / 1ps

module Unidad_control_ALU#(

    parameter   NB_FUNCTION  =   6,
    parameter   NB_ALUOP     =   4,
    parameter   NB_ALUCODE  = 4,

    //ALUOp para los diferentes tipos de instrucciones
    parameter   R_TYPE_ALUOP          =   4'b0000,
    parameter   LOAD_STORE_ADDI_ALUOP =   4'b0001,
    parameter   ANDI_ALUOP            =   4'b0010,
    parameter   ORI_ALUOP             =   4'b0011,
    parameter   XORI_ALUOP            =   4'b0100,
    parameter   LUI_ALUOP             =   4'b0101,
    parameter   SLTI_ALUOP            =   4'b0110,
    parameter   BEQ_ALUOP             =   4'b0111,
    parameter   BNE_ALUOP             =   4'b1000,

    //Campo Func de las tipo R
    parameter   SLL_FUNC =  6'b000000,
    parameter   SRL_FUNC =  6'b000010,
    parameter   SRA_FUNC =  6'b000011,
    parameter   ADDU_FUNC =  6'b100001,
    parameter   SUBU_FUNC =  6'b100011,
    parameter   AND_FUNC =  6'b100100,
    parameter   OR_FUNC  =  6'b100101,
    parameter   XOR_FUNC =  6'b100110,
    parameter   NOR_FUNC =  6'b100111,
    parameter   SLT_FUNC =  6'b101010,
    parameter   SLLV_FUNC = 6'b000100,
    parameter   SRLV_FUNC = 6'b000110,
    parameter   SRAV_FUNC = 6'b000111,
    parameter   JALR_FUNC = 6'b001001,
    parameter   JR_FUNC   = 6'b001000,

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
    parameter   BNE_ALUCODE     =   4'b1110,
    
)(

    input [NB_FUNCTION - 1 : 0]   i_alucontrol_funct,         // Codigo de instruccion para las Instrucciones tipo R 
    input [NB_ALUOP - 1 : 0]      i_alucontrol_ALUOp,         // Tipo de instruccion       
    
    output reg  [NB_ALUCODE - 1 : 0] o_alucontrol_ALUCode        // Señal que va a la ALU con el codigo de operacion
);

always@(*) begin
    case(i_alucontrol_ALUOp)
        R_TYPE_ALUOP:                                                   // INSTRUCCIONES RTYPE 
            case(i_alucontrol_funct)
                SLL_FUNC    : o_alucontrol_ALUCode = SLL_ALUCODE;  //  SLL Shift left logical (r1<<r2)  
                SRL_FUNC    : o_alucontrol_ALUCode = SRL_ALUCODE;  // SRL Shift right logical (r1>>r2)  
                SRA_FUNC    : o_alucontrol_ALUCode = SRA_ALUCODE;  // SRA  Shift right arithmetic (r1>>>r2)
                ADDU_FUNC   : o_alucontrol_ALUCode = ADD_ALUCODE;  // ADD Sum (r1+r2)
                SUBU_FUNC   : o_alucontrol_ALUCode = SUB_ALUCODE;  // SUB Substract (r1-r2)
                AND_FUNC    : o_alucontrol_ALUCode = AND_ALUCODE;  // AND Logical and (r1&r2)
                OR_FUNC     : o_alucontrol_ALUCode = OR_ALUCODE;  // OR Logical or (r1|r2)
                XOR_FUNC    : o_alucontrol_ALUCode = XOR_ALUCODE;  // XOR Logical xor (r1^r2)
                NOR_FUNC    : o_alucontrol_ALUCode = NOR_ALUCODE;  // NOR Logical nor ~(r1|r2)
                SLT_FUNC    : o_alucontrol_ALUCode = SLT_ALUCODE;  // SLT Compare (r1<r2)
                SLLV_FUNC   : o_alucontrol_ALUCode = SLLV_ALUCODE;  // SLLV
                SRLV_FUNC   : o_alucontrol_ALUCode = SRLV_ALUCODE;  // SRLV
                SRAV_FUNC   : o_alucontrol_ALUCode = SRAV_ALUCODE;  // SRAV
                default     : o_alucontrol_ALUCode = 4'b1111;  //NO OPERATION EN ALU                    
            endcase                
        LOAD_STORE_ADDI_ALUOP   : o_alucontrol_ALUCode = ADD_ALUCODE;  // INSTRUCCION ITYPE - ADDI -> ADD de ALU
        ANDI_ALUOP              : o_alucontrol_ALUCode = AND_ALUCODE;  // INSTRUCCION ITYPE - ANDI -> AND de ALU
        ORI_ALUOP               : o_alucontrol_ALUCode = OR_ALUCODE;  // INSTRUCCION ITYPE - ORI -> OR de ALU
        XORI_ALUOP              : o_alucontrol_ALUCode = XOR_ALUCODE;  // INSTRUCCION ITYPE - XORI -> XOR de ALU
        LUI_ALUOP               : o_alucontrol_ALUCode = LUI_ALUCODE;  // INSTRUCCION ITYPE - LUI -> SLL16 de ALU
        SLTI_ALUOP              : o_alucontrol_ALUCode = SLT_ALUCODE;  // INSTRUCCION ITYPE - SLTI -> SLT de ALU
        BEQ_ALUOP               : o_alucontrol_ALUCode = SUB_ALUCODE;  // INSTRUCCION ITYPE - BEQ -> SUB de ALU
        BNE_ALUOP               : o_alucontrol_ALUCode = BNE_ALUCODE;  // INSTRUCCION ITYPE - BNE -> NEQ de ALU
        default                 : o_alucontrol_ALUCode = 4'b1111; //NO OPERATION EN ALU
    endcase
end


endmodule
