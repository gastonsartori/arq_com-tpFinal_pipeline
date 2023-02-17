`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2023 04:51:53 PM
// Design Name: 
// Module Name: Debug_unit
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


module Debug_unit#(
        parameter   NB_PC = 32,        // Bits de rs
        parameter   NB_INSTR = 32,          // Bits de instruccion
        parameter   NB_RX = 8,              // Bits de RX
        parameter   NB_STATE = 5        // Bits de estado
)(
        input i_debugunit_clock,
        input i_debugunit_reset,
        input [NB_RX-1:0]i_debugunit_rx_data,
        input i_debugunit_rx_done,

        output reg [NB_INSTR-1:0] o_debugunit_instr_data,
        output reg [NB_PC-1:0] o_debugunit_instr_addr,
        output reg  o_debugunit_enable, //señal que permite avanzar un ciclo en el pipeline o no, modo paso a paso
        output reg  o_debugunit_instr_done
);

localparam ESPERA       = 5'b00001;           // Espera una instruccion
localparam CARGANDO     = 5'b00010;         // Cargando una instruccion
localparam LISTO        = 5'b00100;            // Instrucción cargada
localparam MODO_CONTINUO = 5'b01000;
localparam MODO_PASO_A_PASO= 5'b10000;

localparam INICIO_CARGA_CODE = 8'b00000001;

reg [NB_INSTR-1:0] instr_buffer, instr_buffer_next;
reg [$clog2 (NB_INSTR/NB_RX) : 0] contador_palabras, contador_palabras_next;
reg [NB_PC-1:0] contador_instr, contador_instr_next;
reg [NB_STATE-1:0] state, state_next;
reg rx_done_flag,rx_done_flag_next;

always@(posedge i_debugunit_clock)
begin
    if(i_debugunit_reset)
    begin
        state <= ESPERA;
        instr_buffer <=0;
        contador_palabras <=0;
        contador_instr <= 0;
        rx_done_flag <= 0;

    end
    else
    begin
        state <= state_next;
        instr_buffer <= instr_buffer_next;
        contador_palabras <= contador_palabras_next;
        contador_instr <= contador_instr_next;
        rx_done_flag <= rx_done_flag_next;

    end
end

always@(*) begin
    state_next = state;
    instr_buffer_next = instr_buffer;
    contador_palabras_next = contador_palabras;
    contador_instr_next = contador_instr;
    rx_done_flag_next =  rx_done_flag; //flag para no guardar varias veces el mismo dato en caso de que el done dure mas de un ciclo
    
    case(state)
        ESPERA: begin
            if(i_debugunit_rx_done) begin
                rx_done_flag_next = 1;
                if(rx_done_flag==0) //solo si el done esta en 1 pero en el ciclo anterior estuvo bajo
                begin
                    if(i_debugunit_rx_data == INICIO_CARGA_CODE) begin
                        state_next = CARGANDO;
                    end
                end
            end
            else
                rx_done_flag_next = 0;
        end
        CARGANDO: begin
            if(i_debugunit_rx_done) begin
                rx_done_flag_next = 1;
                if(rx_done_flag==0) //solo si el done esta en 1 pero en el ciclo anterior estuvo bajo
                begin
                    instr_buffer_next = {i_debugunit_rx_data, instr_buffer[NB_INSTR-1:NB_RX]};
                    
                    if(contador_palabras == (NB_INSTR/NB_RX)-1) begin
                        contador_palabras_next = 0;
                        state_next = LISTO;
                    end
                    else begin
                        contador_palabras_next = contador_palabras + 1;
                        state_next = CARGANDO;
                    end
                end
            end
            else
                rx_done_flag_next = 0;

        end
        LISTO: begin
            state_next=ESPERA;
            contador_instr_next = contador_instr+1;
            instr_buffer_next = 0;

        end
        /*
        MODO_CONTINUO: begin

        end
        MODO_PASO_A_PASO: begin
            
        end
        */
        default: begin
            state_next=ESPERA;
            instr_buffer_next = {i_debugunit_rx_data, instr_buffer[NB_INSTR-1:NB_RX]};
            contador_palabras_next = 0;
            contador_instr_next = 0;

        end
   endcase
end

always@(*) begin

    case(state)
        ESPERA: begin
            o_debugunit_instr_data = 0;
            o_debugunit_instr_addr = 0;
            o_debugunit_enable = 0;
            o_debugunit_instr_done = 0;
        end
        CARGANDO: begin
            o_debugunit_instr_data = 0;
            o_debugunit_instr_addr = 0;
            o_debugunit_enable = 0;
            o_debugunit_instr_done = 0;
        end
        LISTO: begin
            o_debugunit_instr_data = instr_buffer;
            o_debugunit_instr_addr = contador_instr;
            o_debugunit_enable = 0;
            o_debugunit_instr_done = 1;
        end
        /*
        MODO_CONTINUO: begin

        end
        MODO_PASO_A_PASO: begin
            
        end
        */
        default: begin
            o_debugunit_instr_data = 0;
            o_debugunit_instr_addr = 0;
            o_debugunit_enable = 0;
            o_debugunit_instr_done = 0;
        end
   endcase
end





endmodule
