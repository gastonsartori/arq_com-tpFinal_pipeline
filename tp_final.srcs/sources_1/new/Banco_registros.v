`timescale 1ns / 1ps

module Banco_registros#(

    parameter   NB_DATA     =   32,     //Cantidad de bits de los registros     
    parameter   REG_DEPTH   =   32,      //Cantidad de registros
    parameter   NB_ADDR     = $clog2(REG_DEPTH)     // Log base 2 de la cantidad de registros para asi direccionarlos
)
(

    input                           i_regbank_clock, 
    input                           i_regbank_reset, 
    input                           i_regbank_RegWrite,   //Señal de control que habilita la escritura sobre el banco de registros
    input                           i_regbank_enable,       //Señal de control que habilita la lectura del banco de registros
    input [NB_ADDR - 1 : 0]     i_regbank_rA,                   //Entrada de direccionamiento del primer registro a leer (ID)
    input [NB_ADDR - 1 : 0]     i_regbank_rB,                   //Entrada de direccionamiento del segundo registro a leer (ID)
    input [NB_ADDR - 1 : 0]     i_regbank_rW,               //Entrada de direccionamiento del registro a escribir (WB)
    input [NB_DATA - 1 : 0]     i_regbank_dataW,               //Entrada del dato a escribir (WB) 

    input [NB_ADDR -1 : 0]      i_regbank_reg_addr, //direccionamiento para lectura desde debug unit
            
    output [NB_DATA - 1 : 0]    o_regbank_dataA,
    output [NB_DATA - 1 : 0]    o_regbank_dataB,
    output [NB_DATA - 1 : 0]    o_regbank_reg_data

);

//Banco de registros - REG_DEPTH registros de NB_DATA bits
reg     [NB_DATA - 1 : 0]   registers   [REG_DEPTH - 1 : 0];

reg    [NB_DATA - 1 : 0]    regbank_dataA, regbank_dataA_next;
reg    [NB_DATA - 1 : 0]    regbank_dataB, regbank_dataB_next;

assign o_regbank_dataA = regbank_dataA;
assign o_regbank_dataB = regbank_dataB;
assign o_regbank_reg_data = registers[i_regbank_reg_addr];

// Lectura(actualizacion de la salida) en el negedge para leer los datos ya actualizados
/*
always@(negedge i_regbank_clock)
begin
    if(i_regbank_enable)
    begin
        regbank_dataA <= regbank_dataA_next;
        regbank_dataB <= regbank_dataB_next;
    end
end

always@(*)
begin
    if(i_regbank_reset)
    begin
        reset_all();
    end
    else
    begin
        regbank_dataA_next = regbank_dataA;
        regbank_dataB_next = regbank_dataB;
        //if(i_enable)
        //begin
            if(i_regbank_RegWrite) //Escritura
            begin
                registers[i_regbank_rW] = i_regbank_dataW;
            end
            if(i_regbank_rW == i_regbank_rA) //Si la direccon de ra o rb es igual a la direccion de escritura, se coloca el contenido a la salida para evitar dependencias de WB
            begin
                regbank_dataA_next = i_regbank_dataW;
                regbank_dataB_next = registers[i_regbank_rB];
            end
            else if(i_regbank_rW == i_regbank_rB)
            begin
                regbank_dataA_next = registers[i_regbank_rA];
                regbank_dataB_next = i_regbank_dataW;
            end
            else
            begin
                regbank_dataA_next = registers[i_regbank_rA];
                regbank_dataB_next = registers[i_regbank_rB];
            end
    end
    
end
*/

//PROBAR ESTA IMPLEMENTACION
integer reg_index;
always @(posedge i_regbank_clock)
begin
    if(i_regbank_reset)
    begin
        for (reg_index = 0; reg_index < REG_DEPTH; reg_index = reg_index + 1)
          registers[reg_index] <= {NB_DATA{1'b0}};
        regbank_dataA <=  {NB_DATA{1'b0}};
        regbank_dataB <=  {NB_DATA{1'b0}};
    end
    else
    begin
        if (i_regbank_RegWrite) 
        begin
            registers[i_regbank_rW] <= i_regbank_dataW;
        end
    end
end

always @(negedge i_regbank_clock)
begin
    if(i_regbank_enable)
    begin
        regbank_dataA <= registers[i_regbank_rA];
        regbank_dataB <= registers[i_regbank_rB];
    end
end

/*    
task reset_all;
    begin:resetReg
        integer reg_index;
        for (reg_index = 0; reg_index < REG_DEPTH; reg_index = reg_index + 1)
          registers[reg_index] = {NB_DATA{1'b0}};
        regbank_dataA_next  =  {NB_DATA{1'b0}};
        regbank_dataB_next  =  {NB_DATA{1'b0}};
    end
endtask
*/
    
endmodule
