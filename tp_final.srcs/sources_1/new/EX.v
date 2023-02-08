`timescale 1ns / 1ps

module EX#(

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
    parameter   NB_ALUCODE  = 4
)(
    input                           i_ex_clock,
    input                           i_ex_reset,
    input [NB_PC - 1 : 0]           i_ex_pc,                // PC
    input [NB_REG - 1 : 0]          i_ex_offset,            // Offset con signo extendido
    input [NB_REG - 1 : 0]          i_ex_dataA,             // Dato A (direccionado por rs)
    input [NB_REG - 1 : 0]          i_ex_dataB,             // Dato B (direccionado por rt)
    input [NB_RD - 1 : 0]           i_ex_rd,                // rd de la instruccion
    input [NB_RT - 1 : 0]           i_ex_rt,                // rt de la instruccion
    input [NB_REG - 1 : 0]          i_ex_data_MEM,          // Dato anticipado desde la salida de EX/MEM
    input [NB_REG - 1 : 0]          i_ex_data_WB,           // Dato anticipado desde la salida de MEM/WB

    input [1:0]                     i_ex_control_corto1,    // Señal de control del mux de contocircuito para el operando 1
    input [1:0]                     i_ex_control_corto2,    // Señal de control del mux de contocircuito para el operando 2
    
    input [1:0]                     i_ex_RegDst,            // Señal de control del mux que especifica el registro de destino
    input [NB_ALUOP - 1:0]          i_ex_ALUOp,             // Señal de control especificando el aluop code
    input [1:0]                     i_ex_ALUSrc,            // Señal de control para especficar los operandos a utilizar
    input                           i_ex_MemRead,           // Señal de control habilita la lectura de memoria
    input                           i_ex_MemWrite,          // Señal de control habilita la escritura de memoria
    input                           i_ex_Branch,            // Señal de control especifica si la instruccion es un brainput
    input                           i_ex_RegWrite,          // Señal de control habilita o no la escritura en el banco de registros
    input [1:0]                     i_ex_MemtoReg,          // Señal de control especifica cual es la fuente al escribir en registros (00->ALU,01->memoria,10->ret addr)
    input [1:0]                     i_ex_BHW,              //Señal de control que indica el tamaño del direccioonamiento (00->byte, 01->halfword, 10->word) 
    input                           i_ex_ExtSign,          //Señal de control que indica si extender el signo del dato leido o no

    output [NB_PC - 1 : 0]          o_ex_pc,                //PC (sin offset sumado, para poder guardar la direccion de retorno si es necesario)
    output [NB_PC - 1 : 0]          o_ex_pc_offset,         // Salida del sumador PC+offset
    output [NB_REG - 1 : 0]         o_ex_alu_result,        // Resultado de la ALU
    output                          o_ex_alu_zero,          // Señal de cero de la ALU
    output [NB_REG - 1 : 0]         o_ex_dataB,             // Dato B (direccionado por rt) en la salida, para guardar en memoria
    output [NB_RD - 1 : 0]          o_ex_write_reg,         // Salida del mux controlado por RegDst, registro de destino
    output                          o_ex_MemRead,           
    output                          o_ex_MemWrite,          
    output                          o_ex_Branch,            
    output                          o_ex_RegWrite,     
    output [1:0]                    o_ex_MemtoReg,
    output [1:0]                    o_ex_BHW,              //Señal de control que indica el tamaño del direccioonamiento (00->byte, 01->halfword, 10->word) 
    output                          o_ex_ExtSign          //Señal de control que indica si extender el signo del dato leido o no         
);

wire [NB_REG - 1 : 0]   dataA_anticipado;
wire [NB_REG - 1 : 0]   dataB_anticipado;
wire [NB_REG - 1 : 0]   primer_operando_ALU;
wire [NB_REG - 1 : 0]   segundo_operando_ALU;
wire [NB_ALUCODE - 1 : 0]   ALUControl_code;

Sumador Sumador_EX(
    .i_sum_1(i_ex_pc),
    .i_sum_2(i_ex_offset<<2),
    .o_sum(o_ex_pc_offset)
);     

Mux_4a1 Mux_Corto_DataA(
    .i_mux_control(i_ex_control_corto1),
    .i_mux_1(i_ex_dataA),
    .i_mux_2(i_ex_data_MEM),
    .i_mux_3(i_ex_data_WB),
    .i_mux_4(0),        // No se usa esta entrada
    .o_mux(dataA_anticipado)
);

Mux_4a1 Mux_Corto_DataB(
    .i_mux_control(i_ex_control_corto2),
    .i_mux_1(i_ex_dataB),
    .i_mux_2(i_ex_data_MEM),
    .i_mux_3(i_ex_data_WB),
    .i_mux_4(0),        // No se usa esta entrada
    .o_mux(dataB_anticipado)
);  

//Determina cual sera el primer operando a ingresar a la alu, si dataA(rs) o dataB(rt)
Mux_2a1 Mux_Primer_Op(
    .i_mux_control(i_ex_ALUSrc[0]),
    .i_mux_1(dataA_anticipado),
    .i_mux_2(dataB_anticipado),
    .o_mux(primer_operando_ALU)
);

//Determina cual sera el segundo operando a ingresar a la alu, si dataB(rt) o offset
Mux_2a1 Mux1_Primer_Op(
    .i_mux_control(i_ex_ALUSrc[1]),
    .i_mux_1(dataB_anticipado),
    .i_mux_2(i_ex_offset),
    .o_mux(segundo_operando_ALU)
);

//Determina cual es el registro de destino (rd,rt,31)
Mux_4a1 Mux_Reg_dst(
    .i_mux_control(i_ex_RegDst),
    .i_mux_1(i_ex_rt),
    .i_mux_2(i_ex_rd),
    .i_mux_3(5'b11111), //registro 31
    .i_mux_4(0),        // No se usa esta entrada
    .o_mux(o_ex_write_reg)
);  

Unidad_control_ALU  Control_ALU(
    .i_alucontrol_funct(i_ex_offset[NB_FUNCTION-1:0]), 
    .i_alucontrol_ALUOp(i_ex_ALUOp),       
    .o_alucontrol_ALUCode(ALUControl_code)
);

ALU ALU(
    .i_alu_operando1(primer_operando_ALU),
    .i_alu_operando2(segundo_operando_ALU),
    .i_alu_code(ALUControl_code),
    .o_alu_zero(o_ex_alu_zero),
    .o_alu_result(o_ex_alu_result)
);

assign o_ex_pc = i_ex_pc;
assign o_ex_dataB = i_ex_dataB;
assign o_ex_MemRead = i_ex_MemRead;
assign o_ex_MemWrite = i_ex_MemWrite;
assign o_ex_Branch = i_ex_Branch;
assign o_ex_RegWrite = i_ex_RegWrite;
assign o_ex_MemtoReg = i_ex_MemtoReg;
assign o_ex_BHW = i_ex_BHW;
assign o_ex_ExtSign = i_ex_ExtSign;

endmodule
