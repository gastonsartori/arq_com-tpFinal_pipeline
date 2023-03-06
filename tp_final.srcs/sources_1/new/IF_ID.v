`timescale 1ns / 1ps

module IF_ID#(
       parameter   NB_PC = 32,         //Cantidad de bits del PC
       parameter   NB_INSTR = 32       // Ancho de bits de las instrucciones
)(
       input                       i_if_id_clock,                
       input                       i_if_id_reset,
       input                       i_if_id_write_enable,         //Señal desde la Stall Unit para actuualizar o no los registros
       input                       i_if_id_flush,                //Señal para descartar los registros (en caso de un branch)
       input  [NB_PC-1:0]          i_if_id_pc,
       input  [NB_INSTR-1:0]       i_if_id_instruction,

       output reg [NB_PC-1:0]          o_if_id_pc,
       output reg [NB_INSTR-1:0]       o_if_id_instruction                               
);

always@(posedge i_if_id_clock) 
begin
       if(i_if_id_reset || i_if_id_flush)
       begin
              o_if_id_pc <= 0;
              o_if_id_instruction <= 'haaaaaaaa; // Instruccion no definida, no ejecuta nada
       end
       else if(i_if_id_write_enable) // Si la Stall Unit habilita la escritura
       begin 
              o_if_id_pc <= i_if_id_pc;
              o_if_id_instruction <= i_if_id_instruction;
       end
end
    
endmodule
