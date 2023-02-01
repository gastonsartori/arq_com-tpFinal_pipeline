`timescale 1ns / 1ps

module Memoria_datos#(
    parameter   NB_DATA = 8,        // Cantidad de bits de los datos
    parameter   MEM_DEPTH = 32,
    parameter   NB_ADDR = $clog2(MEM_DEPTH),

    parameter   BHW_BYTE  = 2'b00,
    parameter   BHW_HALF  = 2'b01,
    parameter   BHW_WORD  = 2'b10
)(

    input                           i_datamem_clock, 
    input                           i_datamem_reset,
    input                           i_datamem_enable, 
    input                           i_datamem_MemWrite, 
    input                           i_datamem_MemRead,
    input [1:0]                     i_datamem_BHW,      //Señal de control que indica el tamaño del direccioonamiento (00->byte, 01->halfword, 10->word) 
    input                           i_datamem_ExtSign,   //Señal de control que indica si extender el signo del dato leido o no
    input [NB_ADDR-1 : 0]           i_datamem_addr, 
    input [NB_DATA - 1 : 0]         i_datamem_dataW,
    output reg [NB_DATA - 1 : 0]    o_datamem_dataR 
);

reg [NB_DATA-1:0] mem_data [MEM_DEPTH-1:0]; //datos en registros de 8

always 	@(posedge i_datamem_clock)		   //Memory write
begin
    if(i_datamem_reset)
    begin
        reset_all();
    end
    else if(i_datamem_enable)
    begin
        if (i_datamem_MemWrite) 
        begin
            case (i_datamem_BHW)    //Segun el tamaño del direccionamiento
                BHW_BYTE: begin             //En caso de ser de a byte
                    mem_data[i_datamem_addr] = i_datamem_dataW[7:0];
                end
                BHW_HALF: begin     //Determinar en que mitad del reg de 32 escribir.
                    mem_data[i_datamem_addr] = i_datamem_dataW[7:0];
                    mem_data[i_datamem_addr+1] = i_datamem_dataW[15:7];
                end
                BHW_WORD: begin
                    mem_data[i_datamem_addr] = i_datamem_dataW[7:0];
                    mem_data[i_datamem_addr+1] = i_datamem_dataW[15:7];
                    mem_data[i_datamem_addr+2] = i_datamem_dataW[23:16];
                    mem_data[i_datamem_addr+3] = i_datamem_dataW[31:24];
                end
            endcase
        end
        if(i_datamem_MemRead)
        begin
            case(i_datamem_BHW)
                BHW_BYTE: begin
                    if(i_datamem_ExtSign) //segun la flag, extender o no el signo
                        o_datamem_dataR <= {{24{i_datamem_dataW[i_datamem_addr][NB_DATA-1]}},i_datamem_dataW[i_datamem_addr]};
                    else
                        o_datamem_dataR <= {24'b0,i_datamem_dataW[i_datamem_addr]};
                end
                BHW_HALF: begin
                    if(i_datamem_ExtSign)
                        o_datamem_dataR <= {{16{i_datamem_dataW[i_datamem_addr+1][NB_DATA-1]}},i_datamem_dataW[i_datamem_addr+1],i_datamem_dataW[i_datamem_addr]};
                    else
                        o_datamem_dataR <= {16'b0,i_datamem_dataW[i_datamem_addr+1],i_datamem_dataW[i_datamem_addr]};
                end
                BHW_WORD: begin
                    o_datamem_dataR <= {i_datamem_dataW[i_datamem_addr+3],i_datamem_dataW[i_datamem_addr+2],i_datamem_dataW[i_datamem_addr+1],i_datamem_dataW[i_datamem_addr]};
                end
            endcase
        end
    end
end

task reset_all;
    begin:reset
      integer reg_index;
        for (reg_index = 0; reg_index < MEM_DEPTH; reg_index = reg_index + 1)
          mem_data[reg_index] = {NB_DATA{1'b0}};
        o_datamem_dataR  <=  {NB_DATA{1'b0}};
    end
endtask

endmodule
