`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2023 09:50:50 AM
// Design Name: 
// Module Name: Top_pipeline
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


module Top_pipeline#(
    parameter   NB_PC = 32,         //Cantidad de bits del PC
    parameter   NB_INSTR = 32,       // Ancho de bits de las instrucciones

    parameter   NB_RD = 5,          //Cantidad de bits del campo rd en las instrucciones
    parameter   NB_RT = 5,          //Cantidad de bits del campo rt en las instrucciones
    parameter   NB_RS = 5,          //Cantidad de bits del campo rs en las instrucciones
    parameter   NB_FUNCTION = 6,    //Cantidad de bits del campo funct en las instrucciones
    parameter   NB_OFFSET = 16,     //Cantidad de bits del campo inmediato en las instrucciones
    parameter   NB_DIR = 26,        //Cantidad de bits del campo direccion (instr_index) en las instrucciones
    parameter   NB_OP = 6,          //Cantidad de bits del campo op en las instrucciones
    parameter   NB_INSTR_INDEX = 26, 
    parameter   NB_REG = 32,        // Cantidad de bits de los registros

    parameter   NB_ALUOP = 4,   //Cantidad de bits para determinar el tipo de operacion 
    parameter   NB_ALUCODE  = 4,
    parameter   B_START_RS = 21,
    parameter   B_START_RT = 16,
    parameter   B_START_RD = 11,
    parameter   B_START_OFFSET = 0,
    parameter   B_START_FUNCTION = 0,
    parameter   B_START_OP = 26,
 
    parameter   REG_DEPTH   =   32,      //Cantidad de registros
    parameter   NB_ADDR     = $clog2(REG_DEPTH)     // Log base 2 de la cantidad de registros para asi direccionarlos
)(
    input       i_pipeline_clock,
    input       i_pipeline_reset,
    //input       i_pipeline_start, //controla los enable del PC, reg de IF/ID y unidad de control. Si no esta en 1 no arranca el pipeline
    input       i_pipeline_instr_done, //escritura de instrucciones desde DU
    input       [NB_PC-1:0] i_pipeline_instr_addr,
    input       [NB_INSTR-1:0 ]i_pipeline_instr_data,
    input       i_pipeline_enable, //desde la debug unit, esta señal habilita o no avanzar un ciclo
    input       [NB_RS -1 : 0] i_pipeline_reg_addr, //desde du, para direccionar registros
    input       [NB_REG - 1 :0] i_pipeline_read_addr, //desde du, para direccion memoria

    output      [NB_REG - 1 :0] o_pipeline_read_data,   //data de memoria direccionara por du

    output      [NB_REG - 1 :0] o_pipeline_reg_data,

    output [NB_REG - 1 : 0]     o_pipeline_WB_data, //lo que se escribe en los registros
    output                      o_pipeline_halt, //señal hacia la debug unit, cuando se leyo un halt
    output  [NB_PC-1:0]         o_pipeline_pc  //valor del pc, hacia la debug unit

);

    // IF to IF/ID
    wire [NB_PC-1 : 0]      IF_pc_to_IF_ID;
    wire [NB_INSTR-1: 0]    IF_instr_to_IF_ID;

    //IF/ID to ID
    wire [NB_PC-1 : 0]      IF_ID_pc_to_ID;
    wire [NB_INSTR-1 : 0]   IF_ID_instr_to_ID;

    //ID to IF
    wire ID_excute_branch_to_IF;

    //ID/EX to IF
    wire [NB_PC-1:0] ID_EX_dataAPC_to_IF;
    wire [1:0] ID_EX_PcSrc_to_IF;
    wire [NB_PC-1:0] ID_EX_jump_addr_to_IF;

    //riesgounit to IF
    wire     riesgounit_PCWrite_to_IF;

    //riegounit to IF/ID
    wire riesgounit_write_to_IF_ID;

    //riesgounit to ID
    wire riesgounit_control_enable_to_ID;

    //WB to ID
    wire [NB_REG-1:0]   WB_data;
    wire [NB_RD-1:0]    WB_write_reg_to_ID;
    wire                WB_RegWrite_to_ID;

    //unidad de corto to EX
    wire [1 : 0]        UCorto_control1_to_EX;
    wire [1 : 0]        UCorto_control2_to_EX;

    //ID to ID/EX
    wire [NB_PC-1:0]    ID_pc_to_ID_EX;
    wire [NB_REG-1:0]   ID_dataA_to_ID_EX;
    wire [NB_REG-1:0]   ID_dataB_to_ID_EX;
    wire [NB_REG-1:0]   ID_offset_ext_to_ID_EX;
    wire [NB_RT-1:0]    ID_rt_to_ID_EX;
    wire [NB_RD-1:0]    ID_rd_to_ID_EX;
    wire [NB_RS-1:0]    ID_rs_to_ID_EX;
    wire                ID_RegWrite_to_ID_EX;
    wire                ID_Branch_to_ID_EX;
    wire [1:0]          ID_BHW_to_ID_EX;
    wire                ID_ExtSign_to_ID_EX;
    wire                ID_MemRead_to_ID_EX;
    wire                ID_MemWrite_to_ID_EX;
    wire [1:0]          ID_RegDst_to_ID_EX;
    wire [NB_ALUOP-1:0] ID_ALUOp_to_ID_EX;
    wire [1:0]          ID_ALUSrc_to_ID_EX;
    wire [1:0]          ID_MemtoReg_to_ID_EX;
    wire [1:0]          ID_PcSrc_to_ID_EX;
    wire                ID_IF_ID_Flush;
    wire                ID_EX_MEM_Flush_to_ID_EX;
    wire [NB_PC-1:0]    ID_jump_addr_to_ID_EX;

    //ID/EX to EX
    wire [NB_PC-1:0]    ID_EX_pc_to_EX;
    wire [NB_REG-1:0]   ID_EX_dataA_to_EX;
    wire [NB_REG-1:0]   ID_EX_dataB_to_EX;
    wire [NB_REG-1:0]   ID_EX_offset_ext_to_EX;
    wire [NB_RT-1:0]    ID_EX_rt_to_EX;
    wire [NB_RD-1:0]    ID_EX_rd_to_EX;
    wire [NB_RS-1:0]    ID_EX_rs_to_EX;
    wire                ID_EX_RegWrite_to_EX;
    wire                ID_EX_Branch_to_EX;
    wire [1:0]          ID_EX_BHW_to_EX;
    wire                ID_EX_ExtSign_to_EX;
    wire                ID_EX_MemRead_to_EX;
    wire                ID_EX_MemWrite_to_EX;
    wire [1:0]          ID_EX_RegDst_to_EX;
    wire [NB_ALUOP-1:0] ID_EX_ALUOp_to_EX;
    wire [1:0]          ID_EX_ALUSrc_to_EX;
    wire [1:0]          ID_EX_MemtoReg_to_EX;

    //EX to EX/MEM
    wire [NB_PC-1:0]    EX_pc_to_EX_MEM;
    wire [NB_REG-1:0]   EX_alu_result_to_EX;
    wire [NB_REG-1:0]   EX_dataB_to_EX_MEM;
    wire [NB_REG-1:0]   EX_offset_ext_to_EX_MEM;
    wire [NB_RD-1:0]    EX_write_reg_to_EX_MEM;
    wire                EX_alu_zero_to_EX_MEM;

    wire                EX_RegWrite_to_EX_MEM;
    wire                EX_Branch_to_EX_MEM;
    wire [1:0]          EX_BHW_to_EX_MEM;
    wire                EX_ExtSign_to_EX_MEM;
    wire                EX_MemRead_to_EX_MEM;
    wire                EX_MemWrite_to_EX_MEM;
    wire [1:0]          EX_MemtoReg_to_EX_MEM;

    //EX/MEM to IF
    wire [NB_PC-1:0]    EX_MEM_PC_offset_to_IF;
    
    //EX/MEM to ID
    wire                EX_MEM_alu_zero_to_ID;
    wire                EX_MEM_Branch_to_ID;

    //EX/MEM to MEM
    wire [NB_PC-1:0]    EX_MEM_pc_to_MEM;
    wire [NB_REG-1:0]   EX_MEM_alu_result_to_MEM;
    wire [NB_REG-1:0]   EX_MEM_dataB_to_MEM;
    wire [NB_RD-1:0]    EX_MEM_write_reg_to_MEM;
    wire                EX_MEM_RegWrite_to_MEM;
    wire [1:0]          EX_MEM_BHW_to_MEM;
    wire                EX_MEM_ExtSign_to_MEM;
    wire                EX_MEM_MemRead_to_MEM;
    wire                EX_MEM_MemWrite_to_MEM;
    wire [1:0]          EX_MEM_MemtoReg_to_MEM;

    //MEM to MEM/WB
    wire [NB_PC-1:0]    MEM_pc_to_MEM_WB;
    wire [NB_REG-1:0]   MEM_dataR_MEM_WB;
    wire [NB_REG-1:0]   MEM_dataALU_to_MEM_WB;
    wire [NB_RD-1:0]    MEM_write_reg_to_MEM_WB;
    wire                MEM_RegWrite_to_MEM_WB;
    wire [1:0]          MEM_MemtoReg_to_MEM_WB;

    //MEM/WB to WB
    wire [NB_PC-1:0]    MEM_WB_pc_to_WB;
    wire [NB_REG-1:0]   MEM_WB_dataR_WB;
    wire [NB_REG-1:0]   MEM_WB_dataALU_to_WB;
    wire [NB_RD-1:0]    MEM_WB_write_reg_to_WB;
    wire                MEM_WB_RegWrite_to_WB;
    wire [1:0]          MEM_WB_MemtoReg_to_WB;

    assign o_pipeline_WB_data = WB_data;

    Unidad_deteccion_riesgos Unidad_deteccion_riesgos(
        .i_riesgounit_ID_EX_MemRead(ID_EX_MemRead_to_EX),
        .i_riesgounit_ID_EX_rt(ID_EX_rt_to_EX),
        .i_riesgounit_IF_ID_rs(IF_ID_instr_to_ID[B_START_RS+NB_RS-1:B_START_RS]),
        .i_riesgounit_IF_ID_rt(IF_ID_instr_to_ID[B_START_RT+NB_RT-1:B_START_RT]),   
        .o_riesgounit_PCWrite(riesgounit_PCWrite_to_IF),
        .o_riesgounit_IF_IDWrite(riesgounit_write_to_IF_ID),
        .o_riesgounit_Control_enable(riesgounit_control_enable_to_ID) 
    );     

    IF IF(
        .i_if_clock(i_pipeline_clock),
        .i_if_reset(i_pipeline_reset),
        .i_if_pc_offset(EX_MEM_PC_offset_to_IF), //PC PC+OFFSET
        .i_if_pc_register(ID_dataA_to_ID_EX),   //PC contenido en dataA(rs) instrucciones JR y JALR 
        .i_if_pc_jump(ID_jump_addr_to_ID_EX),   //PC PC||inst_index||00
        .i_if_PCWrite(riesgounit_PCWrite_to_IF & i_pipeline_enable),
        .i_if_mux_selector(ID_PcSrc_to_ID_EX),
        .i_if_execute_branch(ID_excute_branch_to_IF),
        .i_if_instr_done(i_pipeline_instr_done),             // Enable para escritura debug
        .i_if_mem_enable(i_pipeline_enable),                                  // Memoria enable
        .i_if_instr_addr(i_pipeline_instr_addr),        // Direccion de escritura de instruccion
        .i_if_instr_data(i_pipeline_instr_data),        // Instruccion a escribir en memoria de instrucciones

        
        .o_if_pc_sum(IF_pc_to_IF_ID),
        .o_if_instruction(IF_instr_to_IF_ID),
        .o_if_halt(o_pipeline_halt),
        .o_if_pc(o_pipeline_pc)
    ); 

    IF_ID IF_ID(
        .i_if_id_clock(i_pipeline_clock),
        .i_if_id_reset(i_pipeline_reset),
        .i_if_id_write_enable(riesgounit_write_to_IF_ID & i_pipeline_enable),
        .i_if_id_flush(ID_IF_ID_Flush),
        .i_if_id_pc(IF_pc_to_IF_ID),
        .i_if_id_instruction(IF_instr_to_IF_ID),
        .o_if_id_pc(IF_ID_pc_to_ID),
        .o_if_id_instruction(IF_ID_instr_to_ID)
    );

    ID ID (
        .i_id_clock(i_pipeline_clock),
        .i_id_reset(i_pipeline_reset),
        .i_id_write_enable(i_pipeline_enable), //desde la uart para habiltiar la escritura

        .i_id_pc(IF_ID_pc_to_ID),
        .i_id_instruction(IF_ID_instr_to_ID),

        .i_id_write_reg(WB_write_reg_to_ID),
        .i_id_write_data(WB_data),
        .i_id_RegWrite(WB_RegWrite_to_ID),

        .i_id_zero(EX_MEM_alu_zero_to_ID),
        .i_id_control_enable(riesgounit_control_enable_to_ID),
        .i_id_branch(EX_MEM_Branch_to_ID),
        .i_id_reg_addr(i_pipeline_reg_addr),
        
        .o_id_reg_data(o_pipeline_reg_data),
        .o_id_dataA(ID_dataA_to_ID_EX),
        .o_id_dataB(ID_dataB_to_ID_EX),
        .o_id_offset_ext(ID_offset_ext_to_ID_EX),
        .o_id_rt(ID_rt_to_ID_EX),
        .o_id_rd(ID_rd_to_ID_EX),
        .o_id_rs(ID_rs_to_ID_EX),
        .o_id_pc(ID_pc_to_ID_EX),

        .o_id_RegWrite(ID_RegWrite_to_ID_EX),
        .o_id_Branch(ID_Branch_to_ID_EX),
        .o_id_BHW(ID_BHW_to_ID_EX),
        .o_id_ExtSign(ID_ExtSign_to_ID_EX),
        .o_id_MemRead(ID_MemRead_to_ID_EX),
        .o_id_MemWrite(ID_MemWrite_to_ID_EX),
        .o_id_RegDst(ID_RegDst_to_ID_EX),
        .o_id_ALUOp(ID_ALUOp_to_ID_EX),
        .o_id_ALUSrc(ID_ALUSrc_to_ID_EX),
        .o_id_MemtoReg(ID_MemtoReg_to_ID_EX),
        .o_id_PcSrc(ID_PcSrc_to_ID_EX),
        .o_id_jump_addr(ID_jump_addr_to_ID_EX),

        .o_id_IF_ID_Flush(ID_IF_ID_Flush),
        .o_id_EX_MEM_Flush(ID_EX_MEM_Flush),
        .o_id_excute_branch(ID_excute_branch_to_IF)
    );

    ID_EX ID_EX(
        .i_id_ex_clock(i_pipeline_clock),
        .i_id_ex_reset(i_pipeline_reset),
        .i_id_ex_write_enable(i_pipeline_enable),
        .i_id_ex_pc(ID_pc_to_ID_EX),
        .i_id_ex_dataA(ID_dataA_to_ID_EX),
        .i_id_ex_dataB(ID_dataB_to_ID_EX),
        .i_id_ex_offset_ext(ID_offset_ext_to_ID_EX),
        .i_id_ex_rt(ID_rt_to_ID_EX),
        .i_id_ex_rd(ID_rd_to_ID_EX),
        .i_id_ex_rs(ID_rs_to_ID_EX),
        .i_id_ex_RegDst(ID_RegDst_to_ID_EX),
        .i_id_ex_ALUSrc(ID_ALUSrc_to_ID_EX),
        .i_id_ex_ALUOp(ID_ALUOp_to_ID_EX),
        .i_id_ex_MemRead(ID_MemRead_to_ID_EX),
        .i_id_ex_MemWrite(ID_MemWrite_to_ID_EX),
        .i_id_ex_Branch(ID_Branch_to_ID_EX),
        .i_id_ex_RegWrite(ID_RegWrite_to_ID_EX),
        .i_id_ex_MemtoReg(ID_MemtoReg_to_ID_EX),
        .i_id_ex_BHW(ID_BHW_to_ID_EX),
        .i_id_ex_ExtSign(ID_ExtSign_to_ID_EX),
        .i_id_ex_PcSrc(ID_PcSrc_to_ID_EX),
        .i_id_ex_jump_addr(ID_jump_addr_to_ID_EX),

        .o_id_ex_pc(ID_EX_pc_to_EX),
        .o_id_ex_dataA(ID_EX_dataA_to_EX),
        .o_id_ex_dataB(ID_EX_dataB_to_EX),
        .o_id_ex_offset_ext(ID_EX_offset_ext_to_EX),
        .o_id_ex_rt(ID_EX_rt_to_EX),
        .o_id_ex_rd(ID_EX_rd_to_EX),
        .o_id_ex_rs(ID_EX_rs_to_EX),
        .o_id_ex_RegDst(ID_EX_RegDst_to_EX),
        .o_id_ex_ALUSrc(ID_EX_ALUSrc_to_EX),
        .o_id_ex_ALUOp(ID_EX_ALUOp_to_EX),
        .o_id_ex_MemRead(ID_EX_MemRead_to_EX),
        .o_id_ex_MemWrite(ID_EX_MemWrite_to_EX),
        .o_id_ex_Branch(ID_EX_Branch_to_EX),
        .o_id_ex_RegWrite(ID_EX_RegWrite_to_EX),
        .o_id_ex_MemtoReg(ID_EX_MemtoReg_to_EX),
        .o_id_ex_BHW(ID_EX_BHW_to_EX),
        .o_id_ex_ExtSign(ID_EX_ExtSign_to_EX),
        .o_id_ex_PcSrc(ID_EX_PcSrc_to_IF),
        .o_id_ex_jump_addr(ID_EX_jump_addr_to_IF)
    );

    EX EX(
        .i_ex_clock(i_pipeline_clock),
        .i_ex_reset(i_pipeline_reset),
        .i_ex_pc(ID_EX_pc_to_EX),
        .i_ex_offset(ID_EX_offset_ext_to_EX),
        .i_ex_dataA(ID_EX_dataA_to_EX),
        .i_ex_dataB(ID_EX_dataB_to_EX),
        .i_ex_rt(ID_EX_rt_to_EX),
        .i_ex_rd(ID_EX_rd_to_EX),
        .i_ex_control_corto1(UCorto_control1_to_EX),
        .i_ex_control_corto2(UCorto_control2_to_EX),
        .i_ex_data_MEM(EX_MEM_alu_result_to_MEM),
        .i_ex_data_WB(WB_data),
        
        .i_ex_RegDst(ID_EX_RegDst_to_EX),
        .i_ex_ALUOp(ID_EX_ALUOp_to_EX),
        .i_ex_ALUSrc(ID_EX_ALUSrc_to_EX),
        .i_ex_MemRead(ID_EX_MemRead_to_EX),//control signals not used in this stage
        .i_ex_MemWrite(ID_EX_MemWrite_to_EX),
        .i_ex_Branch(ID_EX_Branch_to_EX),
        .i_ex_MemtoReg(ID_EX_MemtoReg_to_EX),
        .i_ex_RegWrite(ID_EX_RegWrite_to_EX),
        .i_ex_BHW(ID_EX_BHW_to_EX),
        .i_ex_ExtSign(ID_EX_ExtSign_to_EX),
        
        .o_ex_pc(EX_pc_to_EX_MEM),
        .o_ex_pc_offset(EX_offset_ext_to_EX_MEM),
        .o_ex_write_reg(EX_write_reg_to_EX_MEM),
        .o_ex_dataB(EX_dataB_to_EX_MEM),
        .o_ex_alu_result(EX_alu_result_to_EX),
        
        .o_ex_Branch(EX_Branch_to_EX_MEM),
        .o_ex_MemRead(EX_MemRead_to_EX_MEM),
        .o_ex_MemWrite(EX_MemWrite_to_EX_MEM),
        .o_ex_alu_zero(EX_alu_zero_to_EX_MEM),
        .o_ex_MemtoReg(EX_MemtoReg_to_EX_MEM),
        .o_ex_RegWrite(EX_RegWrite_to_EX_MEM),
        .o_ex_BHW(EX_BHW_to_EX_MEM),
        .o_ex_ExtSign(EX_ExtSign_to_EX_MEM)
    );

    EX_MEM EX_MEM(
        .i_ex_mem_clock(i_pipeline_clock),      
        .i_ex_mem_reset(i_pipeline_reset),
        .i_ex_mem_pc(EX_pc_to_EX_MEM),
        .i_ex_mem_pc_offset(EX_offset_ext_to_EX_MEM),
        .i_ex_mem_alu_result(EX_alu_result_to_EX),
        .i_ex_mem_alu_zero(EX_alu_zero_to_EX_MEM),
        .i_ex_mem_dataB(EX_dataB_to_EX_MEM),
        .i_ex_mem_write_reg(EX_write_reg_to_EX_MEM),
        .i_ex_mem_MemRead(EX_MemRead_to_EX_MEM),
        .i_ex_mem_MemWrite(EX_MemWrite_to_EX_MEM),
        .i_ex_mem_Branch(EX_Branch_to_EX_MEM),
        .i_ex_mem_RegWrite(EX_RegWrite_to_EX_MEM),
        .i_ex_mem_MemtoReg(EX_MemtoReg_to_EX_MEM),
        .i_ex_mem_BHW(EX_BHW_to_EX_MEM),
        .i_ex_mem_ExtSign(EX_ExtSign_to_EX_MEM),
        .i_ex_mem_flush(ID_EX_MEM_Flush),
        .i_ex_mem_enable(i_pipeline_enable),
        .o_ex_mem_pc(EX_MEM_pc_to_MEM),
        .o_ex_mem_pc_offset(EX_MEM_PC_offset_to_IF),
        .o_ex_mem_alu_result(EX_MEM_alu_result_to_MEM),
        .o_ex_mem_alu_zero(EX_MEM_alu_zero_to_ID),
        .o_ex_mem_dataB(EX_MEM_dataB_to_MEM),
        .o_ex_mem_write_reg(EX_MEM_write_reg_to_MEM),
        .o_ex_mem_MemRead(EX_MEM_MemRead_to_MEM),
        .o_ex_mem_MemWrite(EX_MEM_MemWrite_to_MEM),
        .o_ex_mem_Branch(EX_MEM_Branch_to_ID),
        .o_ex_mem_RegWrite(EX_MEM_RegWrite_to_MEM),
        .o_ex_mem_MemtoReg(EX_MEM_MemtoReg_to_MEM),
        .o_ex_mem_BHW(EX_MEM_BHW_to_MEM),
        .o_ex_mem_ExtSign(EX_MEM_ExtSign_to_MEM)
            
    );

    MEM MEM(
        .i_mem_clock(i_pipeline_clock),
        .i_mem_reset(i_pipeline_reset),
        .i_mem_enable(i_pipeline_enable),
        .i_mem_pc(EX_MEM_pc_to_MEM),
        .i_mem_dataW(EX_MEM_dataB_to_MEM),
        .i_mem_dataALU(EX_MEM_alu_result_to_MEM),
        .i_mem_write_reg(EX_MEM_write_reg_to_MEM),
        .i_mem_MemWrite(EX_MEM_MemWrite_to_MEM),
        .i_mem_MemRead(EX_MEM_MemRead_to_MEM),
        .i_mem_RegWrite(EX_MEM_RegWrite_to_MEM),
        .i_mem_MemtoReg(EX_MEM_MemtoReg_to_MEM),
        .i_mem_BHW(EX_MEM_BHW_to_MEM),
        .i_mem_ExtSign(EX_MEM_ExtSign_to_MEM),
        .i_mem_read_addr(i_pipeline_read_addr),
        .o_mem_read_data(o_pipeline_read_data),
        .o_mem_dataR(MEM_dataR_MEM_WB),
        .o_mem_dataALU(MEM_dataALU_to_MEM_WB),
        .o_mem_write_reg(MEM_write_reg_to_MEM_WB),
        .o_mem_MemtoReg(MEM_MemtoReg_to_MEM_WB),
        .o_mem_RegWrite(MEM_RegWrite_to_MEM_WB),
        .o_mem_pc(MEM_pc_to_MEM_WB)
        
    );

    MEM_WB MEM_WB(
        .i_mem_wb_clock(i_pipeline_clock),
        .i_mem_wb_reset(i_pipeline_reset),
        .i_mem_wb_dataR(MEM_dataR_MEM_WB),
        .i_mem_wb_dataALU(MEM_dataALU_to_MEM_WB),
        .i_mem_wb_write_reg(MEM_write_reg_to_MEM_WB),
        .i_mem_wb_pc(MEM_pc_to_MEM_WB),
        .i_mem_wb_MemtoReg(MEM_MemtoReg_to_MEM_WB),
        .i_mem_wb_RegWrite(MEM_RegWrite_to_MEM_WB),
        .i_mem_wb_enable(i_pipeline_enable),
        
        .o_mem_wb_dataR(MEM_WB_dataR_WB),
        .o_mem_wb_dataALU(MEM_WB_dataALU_to_WB),
        .o_mem_wb_write_reg(MEM_WB_write_reg_to_WB),
        .o_mem_wb_pc(MEM_WB_pc_to_WB),
        .o_mem_wb_MemtoReg(MEM_WB_MemtoReg_to_WB),
        .o_mem_wb_RegWrite(MEM_WB_RegWrite_to_WB)
    );

    WB WB(
        .i_wb_dataR(MEM_WB_dataR_WB),            
        .i_wb_dataALU(MEM_WB_dataALU_to_WB),          
        .i_wb_write_reg(MEM_WB_write_reg_to_WB),        
        .i_wb_pc(MEM_WB_pc_to_WB),
        .i_wb_MemtoReg(MEM_WB_MemtoReg_to_WB),
        .i_wb_RegWrite(MEM_WB_RegWrite_to_WB),
        .o_wb_data(WB_data),              
        .o_wb_reg(WB_write_reg_to_ID),              
        .o_wb_RegWrite(WB_RegWrite_to_ID) 
    );

    Unidad_cortocircuito Unidad_cortocircuito(
        .i_cortounit_EX_MEM_RegWrite(EX_MEM_RegWrite_to_MEM),
        .i_cortounit_MEM_WB_RegWrite(MEM_WB_RegWrite_to_WB),
        .i_cortounit_ID_EX_rs(ID_EX_rs_to_EX),
        .i_cortounit_ID_EX_rt(ID_EX_rt_to_EX),
        .i_cortounit_EX_MEM_write_reg(EX_MEM_write_reg_to_MEM),
        .i_cortounit_MEM_WB_write_reg(MEM_WB_write_reg_to_WB),
        .o_cortounit_control_corto1(UCorto_control1_to_EX),
        .o_cortounit_control_corto2(UCorto_control2_to_EX)
    );

endmodule
