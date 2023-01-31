`timescale 1ns / 1ps

module Unidad_control #(

    parameter   NB_OP    =   6,
    parameter   NB_FUNCTION  =   6,
    parameter   NB_ALUOP     =   4,

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

    //OPcodes de las instrucciones
    parameter   R_TYPE_OPCODE    =   6'b000000,
    parameter   LB_OPCODE        =   6'b100000,
    parameter   LH_OPCODE        =   6'b100001,
    parameter   LW_OPCODE        =   6'b100011,
    parameter   LWU_OPCODE       =   6'b100111,
    parameter   LBU_OPCODE       =   6'b100100,
    parameter   LHU_OPCODE       =   6'b100101,
    parameter   SB_OPCODE        =   6'b101000,
    parameter   SH_OPCODE        =   6'b101001,
    parameter   SW_OPCODE        =   6'b101011,
    parameter   ADDI_OPCODE      =   6'b001000,
    parameter   ANDI_OPCODE      =   6'b001100,   
    parameter   ORI_OPCODE       =   6'b001101,    
    parameter   XORI_OPCODE      =   6'b001110,    
    parameter   LUI_OPCODE       =   6'b001111,   
    parameter   SLTI_OPCODE      =   6'b001010,    
    parameter   BEQ_OPCODE       =   6'b000100,        
    parameter   BNE_OPCODE       =   6'b000101,
    parameter   J_OPCODE         =   6'b000010,  
    parameter   JAL_OPCODE       =   6'b000011,   

    //Campo funct de las isntrucciones tipo R
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
    parameter   JR_FUNC   = 6'b001000
) (
    
    input                   i_controlunit_enable,
    input                   i_controlunit_zero, i_controlunit_branch, // Señales desde EX/MEM, si salida de la alu fie 0 y si era una instruccion de branch
    input [NB_OP-1:0]       i_controlunit_op,
    input [NB_FUNCTION-1:0]  i_controlop_funct,

    //Señales de control para las diferentes etapas
    //IF
    output reg [1:0]            o_controlunit_PcSrc,    //especifica que entrada del mux sera el nuevo PC
    //EX
    output reg [1:0]            o_controlunit_RegDst,   //especifica cual es el indentificador del registro destino (00->rt,01->rd,10->GPR31)
    output reg [1:0]            o_controlunit_ALUSrc,   //ALUSrc[0] especifica cual es el primer operando de la ALU (0->rs, 1->rt)
                                                    //ALUSrc[1]especifica cual es el segundo operando de la ALU (0->rt, 1->campo inmediato (offset))
    output reg [NB_ALUOP-1:0]   o_controlunit_ALUOp,    
    //MEM
    output reg                 o_controlunit_MemRead,  //habilita la lectura de memoria
    output reg                 o_controlunit_MemWrite, //habilita la escritura de memoria
    output reg                 o_controlunit_Branch,   //especifica si la instruccion es un branch o no
    //WB
    output reg                 o_controlunit_RegWrite, //habilita o no la escritura en el banco de registros
    output reg [1:0]            o_controlunit_MemtoReg, //especifica cual es la fuente al escribir en registros (00->ALU,01->memoria,10->ret addr)

    //Señales de Flush para los regsitros de segmentacion en caso de branch
    output  reg             o_controlunit_IF_ID_Flush,
    output  reg             o_controlunit_EX_MEM_Flush  
);

//Señal que indica que se debe ejecutar un branch, salida de la alu en 0 y la instruccion era un branch
wire control_unit_ID_EX_Flush = i_controlunit_zero && i_controlunit_branch;

//Generacion de las señales de control
always@(*)
begin
    //Si se ejecuto un branch, flush sobre las señales de IF/ID, ID,EX y EX/MEM y ejecuta el salto
    if(control_unit_ID_EX_Flush)
    begin
        o_controlunit_IF_ID_Flush = 1'b1;
        o_controlunit_EX_MEM_Flush = 1'b1;

        o_controlunit_PcSrc = 2'b01;           //IF (PC <= PC + offset + 1) (segunda entrada del mux)
        
        o_controlunit_RegDst = 2'b00;
        o_controlunit_ALUSrc = 2'b00; 
        o_controlunit_ALUOp = R_TYPE_ALUOP; 

        o_controlunit_MemRead =  1'b0;
        o_controlunit_MemWrite =  1'b0;
        o_controlunit_Branch =   1'b0;
        
        o_controlunit_RegWrite =  1'b0;
        o_controlunit_MemtoReg =  2'b00;
    end

    else if(i_controlunit_enable)
    begin
        o_controlunit_IF_ID_Flush = 1'b0;
        o_controlunit_EX_MEM_Flush = 1'b0;

        case(i_controlunit_op)
            R_TYPE_OPCODE:
            begin        
                o_controlunit_ALUOp = R_TYPE_ALUOP; 
                
                case(i_controlop_funct)
                    SLL_FUNC, SRL_FUNC, SRA_FUNC:
                    begin
                        o_controlunit_PcSrc = 2'b00;           
                
                        o_controlunit_RegDst = 2'b01;
                        o_controlunit_ALUSrc = 2'b11; 

                        o_controlunit_MemRead =  1'b0;
                        o_controlunit_MemWrite =  1'b0;
                        o_controlunit_Branch =   1'b0;
                        
                        o_controlunit_RegWrite =  1'b1;
                        o_controlunit_MemtoReg =  2'b01; 
                    end
                    SLLV_FUNC, SRLV_FUNC, SRAV_FUNC, ADDU_FUNC, SUBU_FUNC, AND_FUNC, OR_FUNC, XOR_FUNC, NOR_FUNC, SLT_FUNC:
                    begin
                        o_controlunit_PcSrc = 2'b00;           
                
                        o_controlunit_RegDst = 2'b01;
                        o_controlunit_ALUSrc = 2'b00; 

                        o_controlunit_MemRead =  1'b0;
                        o_controlunit_MemWrite =  1'b0;
                        o_controlunit_Branch =   1'b0;
                        
                        o_controlunit_RegWrite =  1'b1;
                        o_controlunit_MemtoReg =  2'b01;                         
                    end
                    JR_FUNC:
                    begin
                        o_controlunit_PcSrc = 2'b11;           
                
                        o_controlunit_RegDst = 2'b00; //no se usa
                        o_controlunit_ALUSrc = 2'b00;  //no se usa

                        o_controlunit_MemRead =  1'b0;
                        o_controlunit_MemWrite =  1'b0;
                        o_controlunit_Branch =   1'b0;
                        
                        o_controlunit_RegWrite =  1'b0;
                        o_controlunit_MemtoReg =  2'b00; //no se usa
                    end
                    JALR_FUNC:
                    begin
                        o_controlunit_PcSrc = 2'b11;           
                
                        o_controlunit_RegDst = 2'b01; 
                        o_controlunit_ALUSrc = 2'b00;  //no se usa

                        o_controlunit_MemRead =  1'b0;
                        o_controlunit_MemWrite =  1'b0;
                        o_controlunit_Branch =   1'b0;
                        
                        o_controlunit_RegWrite =  1'b1;
                        o_controlunit_MemtoReg =  2'b10; 
                    end
                    default:
                    begin
                        o_controlunit_PcSrc = 2'b00;           
                
                        o_controlunit_RegDst = 2'b00; 
                        o_controlunit_ALUSrc = 2'b00;

                        o_controlunit_MemRead =  1'b0;
                        o_controlunit_MemWrite =  1'b0;
                        o_controlunit_Branch =   1'b0;
                        
                        o_controlunit_RegWrite =  1'b0;
                        o_controlunit_MemtoReg =  2'b00;   
                    end
                endcase
            end
            //TIPO I
            LB_OPCODE, LH_OPCODE, LW_OPCODE, LWU_OPCODE,LBU_OPCODE,LHU_OPCODE:
            begin
                o_controlunit_PcSrc = 2'b00;           
                
                o_controlunit_RegDst = 2'b00;
                o_controlunit_ALUSrc = 2'b10; 
                o_controlunit_ALUOp = LOAD_STORE_ADDI_ALUOP; 

                o_controlunit_MemRead =  1'b1;
                o_controlunit_MemWrite =  1'b0;
                o_controlunit_Branch =   1'b0;
                
                o_controlunit_RegWrite =  1'b1;
                o_controlunit_MemtoReg =  2'b00;
            end
            SB_OPCODE, SH_OPCODE, SW_OPCODE:
            begin
                o_controlunit_PcSrc = 2'b00;           
                
                o_controlunit_RegDst = 2'b00; //no se usa
                o_controlunit_ALUSrc = 2'b10; 
                o_controlunit_ALUOp = LOAD_STORE_ADDI_ALUOP; 

                o_controlunit_MemRead =  1'b0;
                o_controlunit_MemWrite =  1'b1;
                o_controlunit_Branch =   1'b0;
                
                o_controlunit_RegWrite =  1'b0;
                o_controlunit_MemtoReg =  2'b00;  //no se usa
            end
            ADDI_OPCODE:
            begin
                o_controlunit_PcSrc = 2'b00;           
                
                o_controlunit_RegDst = 2'b00;  
                o_controlunit_ALUSrc = 2'b10;   
                o_controlunit_ALUOp = LOAD_STORE_ADDI_ALUOP;

                o_controlunit_MemRead =  1'b0;
                o_controlunit_MemWrite =  1'b0;
                o_controlunit_Branch =   1'b0;
                
                o_controlunit_RegWrite =  1'b1;
                o_controlunit_MemtoReg =  2'b01;
            end
            ANDI_OPCODE:
            begin
                o_controlunit_PcSrc = 2'b00;           
                
                o_controlunit_RegDst = 2'b00;  
                o_controlunit_ALUSrc = 2'b10;   
                o_controlunit_ALUOp = ANDI_ALUOP;

                o_controlunit_MemRead =  1'b0;
                o_controlunit_MemWrite =  1'b0;
                o_controlunit_Branch =   1'b0;
                
                o_controlunit_RegWrite =  1'b1;
                o_controlunit_MemtoReg =  2'b01;
            end
            ORI_OPCODE:
            begin
                o_controlunit_PcSrc = 2'b00;           
                
                o_controlunit_RegDst = 2'b00;  
                o_controlunit_ALUSrc = 2'b10;   
                o_controlunit_ALUOp = ORI_ALUOP;

                o_controlunit_MemRead =  1'b0;
                o_controlunit_MemWrite =  1'b0;
                o_controlunit_Branch =   1'b0;
                
                o_controlunit_RegWrite =  1'b1;
                o_controlunit_MemtoReg =  2'b01;
            end
            XORI_OPCODE:
            begin
                o_controlunit_PcSrc = 2'b00;           
                
                o_controlunit_RegDst = 2'b00;  
                o_controlunit_ALUSrc = 2'b10;   
                o_controlunit_ALUOp = XORI_ALUOP;

                o_controlunit_MemRead =  1'b0;
                o_controlunit_MemWrite =  1'b0;
                o_controlunit_Branch =   1'b0;
                
                o_controlunit_RegWrite =  1'b1;
                o_controlunit_MemtoReg =  2'b01;
            end
            LUI_OPCODE:
            begin
                o_controlunit_PcSrc = 2'b00;           
                
                o_controlunit_RegDst = 2'b00;  
                o_controlunit_ALUSrc = 2'b00;   
                o_controlunit_ALUOp = LUI_ALUOP;

                o_controlunit_MemRead =  1'b0;
                o_controlunit_MemWrite =  1'b0;
                o_controlunit_Branch =   1'b0;
                
                o_controlunit_RegWrite =  1'b1;
                o_controlunit_MemtoReg =  2'b01;
            end
            SLTI_OPCODE:
            begin
                o_controlunit_PcSrc = 2'b00;           
                
                o_controlunit_RegDst = 2'b00;  
                o_controlunit_ALUSrc = 2'b10;   
                o_controlunit_ALUOp = SLTI_ALUOP;

                o_controlunit_MemRead =  1'b0;
                o_controlunit_MemWrite =  1'b0;
                o_controlunit_Branch =   1'b0;
                
                o_controlunit_RegWrite =  1'b1;
                o_controlunit_MemtoReg =  2'b01;
            end
            BEQ_OPCODE:
            begin
                o_controlunit_PcSrc = 2'b01;           
                
                o_controlunit_RegDst = 2'b00;   //no se usa
                o_controlunit_ALUSrc = 2'b00;   
                o_controlunit_ALUOp = BEQ_ALUOP; 

                o_controlunit_MemRead =  1'b0;
                o_controlunit_MemWrite =  1'b0;
                o_controlunit_Branch =   1'b1;
                
                o_controlunit_RegWrite =  1'b0;
                o_controlunit_MemtoReg =  2'b00; //no se usa
            end
            BNE_OPCODE:
            begin
                o_controlunit_PcSrc = 2'b01;           
                
                o_controlunit_RegDst = 2'b00;   //no se usa
                o_controlunit_ALUSrc = 2'b00;   
                o_controlunit_ALUOp = BNE_ALUOP; 

                o_controlunit_MemRead =  1'b0;
                o_controlunit_MemWrite =  1'b0;
                o_controlunit_Branch =   1'b1;
                
                o_controlunit_RegWrite =  1'b0;
                o_controlunit_MemtoReg =  2'b00; //no se usa
            end
            J_OPCODE:
            begin
                o_controlunit_PcSrc = 2'b10;           
                
                o_controlunit_RegDst = 2'b00;   //no se usa
                o_controlunit_ALUSrc = 2'b00;   //no se usa
                o_controlunit_ALUOp = R_TYPE_ALUOP;  //no se usa

                o_controlunit_MemRead =  1'b0;
                o_controlunit_MemWrite =  1'b0;
                o_controlunit_Branch =   1'b0;
                
                o_controlunit_RegWrite =  1'b0;
                o_controlunit_MemtoReg =  2'b00; //no se usa
            end
            JAL_OPCODE:
            begin
                o_controlunit_PcSrc = 2'b10;           
                
                o_controlunit_RegDst = 2'b10;   
                o_controlunit_ALUSrc = 2'b00;   //no se usa
                o_controlunit_ALUOp = R_TYPE_ALUOP;  //no se usa

                o_controlunit_MemRead =  1'b0;
                o_controlunit_MemWrite =  1'b0;
                o_controlunit_Branch =   1'b0;
                
                o_controlunit_RegWrite =  1'b1;
                o_controlunit_MemtoReg =  2'b10; 
            end
            default:
            begin
                o_controlunit_PcSrc = 2'b00;           
                
                o_controlunit_RegDst = 2'b00;   
                o_controlunit_ALUSrc = 2'b00;   
                o_controlunit_ALUOp = R_TYPE_ALUOP;

                o_controlunit_MemRead =  1'b0;
                o_controlunit_MemWrite =  1'b0;
                o_controlunit_Branch =   1'b0;
                
                o_controlunit_RegWrite =  1'b0;
                o_controlunit_MemtoReg =  2'b00; 
            end
        endcase
    end
    else
    begin
        o_controlunit_PcSrc = 2'b00;           
        
        o_controlunit_RegDst = 2'b00;   
        o_controlunit_ALUSrc = 2'b00;   
        o_controlunit_ALUOp = R_TYPE_ALUOP;

        o_controlunit_MemRead =  1'b0;
        o_controlunit_MemWrite =  1'b0;
        o_controlunit_Branch =   1'b0;
        
        o_controlunit_RegWrite =  1'b0;
        o_controlunit_MemtoReg =  2'b00; 
    end
end  
endmodule