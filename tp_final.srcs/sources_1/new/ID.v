`timescale 1ns / 1ps

module ID#(
    parameter   NB_PC = 32,         //Cantidad de bits del PC
    parameter   NB_INSTR = 32,       // Ancho de bits de las instrucciones
    

    parameter   NB_RD = 5,          //Cantidad de bits del campo rd en las instrucciones
    parameter   NB_RT = 5,          //Cantidad de bits del campo rt en las instrucciones
    parameter   NB_RS = 5,          //Cantidad de bits del campo rs en las instrucciones
    parameter   NB_FUNCTION = 6,    //Cantidad de bits del campo funct en las instrucciones
    parameter   NB_OFFSET = 16,     //Cantidad de bits del campo inmediato en las instrucciones
    parameter   NB_DIR = 26,        //Cantidad de bits del campo direccion (instr_index) en las instrucciones
    parameter   NB_OP = 6,          //Cantidad de bits del campo op en las instrucciones

    parameter   NB_REG = 32,        // Cantidad de bits de los registros

    parameter   NB_ALUOP = 4,   //Cantidad de bits para determinar el tipo de operacion 
    
    //Bits de inicio de los campos dentro de la instruccion
    parameter   B_START_RS = 21,
    parameter   B_START_RT = 16,
    parameter   B_START_RD = 11,
    parameter   B_START_OFFSET = 0,
    parameter   B_START_FUNCTION = 0,
    parameter   B_START_OP = 26
        
)(
    input [NB_PC-1:0]       i_id_pc,            //PC desde IF/ID
    input [NB_INSTR-1:0]    i_id_instruction,   //instruccion a decodificar
    input                   i_id_clock,
    input                   i_id_reset,
    input [NB_RD-1:0]       i_id_write_reg,             //Registro en donde se hara la escritura (WB)
    input [NB_REG-1:0]      i_id_write_data,            //Dato a escribir (WB)
    input                   i_id_RegWrite,              //Señal de control desde MEM/WB, habilita o no la escritura
    input                   i_id_branch,                //Señal de control desde EX/MEM, si es una instruccion de branch, va a la unidad de control
    input                   i_id_zero,                  //Señal desde EX/MEM, si la salida de la ALU fue cero, va a la unidad de control
    input                   i_id_control_enable,        //Señal desde StallUnit, para no modificar las señales de control, va a la unidad de control
    input                   i_id_write_enable,          //Señal desde StallUnit, para no actualizar la salida del banco de registros

    output [NB_PC - 1 :0]       o_id_pc,                    //PC a ID/EX   
    output [NB_REG - 1 :0]      o_id_dataA, o_id_dataB,     //Datos leidos desde el banco de registros
    output [NB_REG - 1 :0]      o_id_offset_ext,            //Offset con el signo extendido
    output [NB_RT - 1 :0]       o_id_rt,                    //campo rt
    output [NB_RD - 1 :0]       o_id_rd,                    //campo rd
    output [NB_RS - 1 :0]       o_id_rs,                    //campo rs

    //Señales de control para las diferentes etapas
    //IF
    output [1:0]            o_id_PcSrc,    //especifica que entrada del mux sera el nuevo PC
    //EX
    output [1:0]            o_id_RegDst,   //especifica cual es el indentificador del registro destino (0->rt,1->rd)
    output [1:0]            o_id_ALUSrc,   //ALUSrc[0] especifica cual es el primer operando de la ALU (0->rs, 1->rt)
                                                    //ALUSrc[1]especifica cual es el segundo operando de la ALU (0->rt, 1->campo inmediato (offset))
    output [NB_ALUOP-1:0]     o_id_ALUOp,    
    //MEM
    output                  o_id_MemRead,  //habilita la lectura de memoria
    output                  o_id_MemWrite, //habilita la escritura de memoria
    output                  o_id_Branch,   //especifica si la instruccion es un branch o no
    output [1:0]            o_id_BHW,              //Señal de control que indica el tamaño del direccioonamiento (00->byte, 01->halfword, 10->word) 
    output                  o_id_ExtSign,          //Señal de control que indica si extender el signo del dato leido o no
    //WB
    output                  o_id_RegWrite, //habilita o no la escritura en el banco de registros
    output [1:0]            o_id_MemtoReg, //especifica cual es la fuente al escribir en registros (0->ALU,1->memoria)


    //Señales de Flush para los regsitros de segmentacion en caso de branch
    output             o_id_IF_ID_Flush,
    output             o_id_EX_MEM_Flush  
);

wire [NB_RT - 1 :0] rt;
wire [NB_RD - 1 :0] rd;
wire [NB_RS - 1 :0] rs;

assign rt = i_id_instruction[B_START_RT+NB_RT-1 : B_START_RT];
assign rs = i_id_instruction[B_START_RS+NB_RS-1 : B_START_RS];
assign rd = i_id_instruction[B_START_RD+NB_RD-1 : B_START_RD];

assign o_id_pc = i_id_pc;
assign o_id_rt = rt;
assign o_id_rs = rs;
assign o_id_rd = rd;


Banco_registros Registers
(
    .i_regbank_clock(i_id_clock), 
    .i_regbank_reset(i_id_reset), 
    .i_regbank_RegWrite(i_id_RegWrite), 
    .i_regbank_enable(i_id_write_enable),
    .i_regbank_rA(rs), //campo RS de la instruccion [25:21]
    .i_regbank_rB(rt), //campo RT de la instruccion [20:16]
    .i_regbank_rW(i_id_write_reg),
    .i_regbank_dataW(i_id_write_data),
         
    .o_regbank_dataA(o_id_dataA), 
    .o_regbank_dataB(o_id_dataB) 
);


Ext_signo Ext_signo
(
    .i_signext(i_id_instruction[B_START_OFFSET + NB_OFFSET - 1 : B_START_OFFSET]),
    .o_signext(o_id_offset_ext)   
);

Unidad_control Control
(
    .i_controlunit_enable(i_id_control_enable),
    .i_controlunit_zero(i_id_zero), 
    .i_controlunit_branch(i_id_branch),
    .i_controlunit_op(i_id_instruction[B_START_OP+NB_OP-1 : B_START_OP]),
    .i_controlop_funct(i_id_instruction[B_START_FUNCTION+NB_FUNCTION-1 : B_START_FUNCTION]),

    .o_controlunit_PcSrc(o_id_PcSrc),
    .o_controlunit_RegDst(o_id_RegDst),
    .o_controlunit_ALUSrc(o_id_ALUSrc),
    .o_controlunit_ALUOp(o_id_ALUOp),
    .o_controlunit_MemRead(o_id_MemRead), 
    .o_controlunit_MemWrite(o_id_MemWrite),
    .o_controlunit_Branch(o_id_Branch),
    .o_controlunit_RegWrite(o_id_RegWrite),
    .o_controlunit_MemtoReg(o_id_MemtoReg),
    .o_controlunit_IF_ID_Flush(o_id_IF_ID_Flush),
    .o_controlunit_EX_MEM_Flush(o_id_EX_MEM_Flush) 
);

endmodule
