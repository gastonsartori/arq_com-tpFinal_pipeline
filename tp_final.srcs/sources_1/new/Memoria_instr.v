`timescale 1ns / 1ps

// En esta memoria, primero se va a escribir en el negedge clock y luego leer o resetear

module Mem_instruction#(
        
        parameter   NB_INSTR = 32,                                  // Ancho de instruccion
        parameter   NB_MEMORY_DEPTH = 14,                           // Numero de entradas de la memoria
        parameter   NB_DIRECTION = $clog2(NB_MEMORY_DEPTH),     // Log base 2 de la cantidad de entradas a memoria para asi direccionar
        parameter   INIT_FILE = "out.mem"                    
        
    )
    (
        input   wire                            i_instmem_clock,
        input   wire                            i_instmem_reset,
        input   wire                            i_instmem_write_e,
        input   wire                            i_instmem_read_e,
        input   wire                            i_instmem_enable,
        input   wire [NB_DIRECTION - 1 : 0]     i_instmem_write_addr,     // Bus de direcciones para la escritura
        input   wire [NB_INSTR - 1 : 0]         i_instmem_write_data,     // Input para la escritura
        input   wire [NB_DIRECTION - 1 : 0]     i_instmem_pc,             // Bus de direccionamiento que se lee desde PC
        output  wire  [NB_INSTR - 1 : 0]        o_instmem                 // Instruccion leida
    );
    
    reg [NB_INSTR-1 : 0] mem_instructions [NB_MEMORY_DEPTH - 1 : 0];     //Memoria
    
    //Inicilizar memoria de instrucciones desde archivo para pruebas, o inicializarla con ceros
    generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, mem_instructions, 0, NB_MEMORY_DEPTH-1);
    end else begin: init_bram_to_zero
      integer index;
      initial
        for (index = 0; index < NB_MEMORY_DEPTH; index = index + 1)
          mem_instructions[index] = {NB_INSTR{1'b0}};
    end
    endgenerate

    assign o_instmem = mem_instructions[i_instmem_pc>>2]; 
endmodule
