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
        parameter   NB_REG = 32,          // Bits de instruccion
        parameter   NB_RX = 8,              // Bits de RX
        parameter   NB_RS = 5,
        parameter   NB_TX = 8,              // Bits de TX
        parameter   NB_STATE = 8,        // Bits de estado
        parameter   MEM_DEPTH = 256
)(
        input i_debugunit_clock,
        input i_debugunit_reset,
        input [NB_RX-1:0]i_debugunit_rx_data,
        input i_debugunit_rx_done,
        input i_debugunit_halt, //se activa cuando se haya leido un halt
        input i_debugunit_tx_done, //señal desde tx, cuando pueda enviar un dato

        input [NB_PC-1:0] i_debugunit_pc, //valor del program counter 

        input [NB_REG-1:0] i_debugunit_reg_data, //valor del registro direccionado para lectura por du
        input [NB_REG-1:0] i_debugunit_read_data, //valor de la memoria leido

        output reg [NB_REG-1:0] o_debugunit_read_addr, //direcciona la memoria 
        output reg [NB_INSTR-1:0] o_debugunit_instr_data,
        output reg [NB_PC-1:0] o_debugunit_instr_addr,
        output reg  o_debugunit_enable, //señal que permite avanzar un ciclo en el pipeline o no, modo paso a paso
        output reg  o_debugunit_instr_done,

        output reg [NB_TX-1:0]  o_debugunit_tx_data,
        output reg              o_debugunit_tx_data_done,

        output reg [NB_RS-1:0] o_debugunit_reg_addr //direccion del registro para lectura

);

localparam ESPERA               = 8'b00000001;           // Espera una instruccion
localparam CARGANDO             = 8'b00000010;         // Cargando una instruccion
localparam LISTO                = 8'b00000100;            // Instrucción cargada
localparam MODO_CONTINUO        = 8'b00001000;
localparam MODO_PASO_A_PASO     = 8'b00010000;
localparam SEND_DATA            = 8'b00100000;
localparam SEND_REGS            = 8'b01000000;
localparam SEND_MEM            = 8'b10000000;

localparam CODE_CARGA_INSTR         = 8'b00000001;
localparam CODE_MODO_CONTINUO       = 8'b00000010;
localparam CODE_MODO_PASO_A_PASO    = 8'b00000100;
localparam CODE_SEND_PC             = 8'b00001000;
localparam CODE_SEND_REGS           = 8'b00010000;
localparam CODE_SEND_MEM           = 8'b00100000;


reg [NB_INSTR-1:0] instr_buffer, instr_buffer_next;
reg [$clog2 (NB_INSTR/NB_RX) : 0] contador_palabras, contador_palabras_next;
reg [NB_PC-1:0] contador_instr, contador_instr_next;
reg [NB_STATE-1:0] state, state_next;
reg rx_done_flag,rx_done_flag_next;

reg [NB_INSTR-1:0] send_data_buffer, send_data_buffer_next;

reg tx_data_done;

reg [NB_RS : 0] contador_registros, contador_registros_next; //6 bits para poder contar hasta 32
reg sending_regs_flag,sending_regs_flag_next;

reg [NB_REG-1 : 0] contador_memoria, contador_memoria_next; 
reg sending_mem_flag,sending_mem_flag_next;

always@(posedge i_debugunit_clock)
begin
    if(i_debugunit_reset)
    begin
        state <= ESPERA;
        instr_buffer <= 0;
        contador_palabras <= 0;
        contador_instr <= 0;
        rx_done_flag <= 0;
        send_data_buffer <= 0;
        contador_registros <= 0;
        sending_regs_flag <= 0;
        contador_memoria <= 0;
        sending_mem_flag <= 0;

    end
    else
    begin
        state <= state_next;
        instr_buffer <= instr_buffer_next;
        contador_palabras <= contador_palabras_next;
        contador_instr <= contador_instr_next;
        rx_done_flag <= rx_done_flag_next;
        send_data_buffer <= send_data_buffer_next;
        contador_registros <= contador_registros_next;
        sending_regs_flag <= sending_regs_flag_next;
        contador_memoria <= contador_memoria_next;
        sending_mem_flag <= sending_mem_flag_next;
    end
end

always@(*) begin
    //state_next = state;
    instr_buffer_next = instr_buffer;
    contador_palabras_next = contador_palabras;
    contador_instr_next = contador_instr;
    rx_done_flag_next =  rx_done_flag; //flag para no guardar varias veces el mismo dato en caso de que el done dure mas de un ciclo
    send_data_buffer_next = send_data_buffer;
    sending_regs_flag_next = sending_regs_flag;
    contador_registros_next = contador_registros;
    contador_memoria_next = contador_memoria;
    sending_mem_flag_next = sending_mem_flag;

    case(state)
        ESPERA: begin
            tx_data_done = 0;
            contador_palabras_next = 0;
            if(i_debugunit_rx_done) begin
                rx_done_flag_next = 1;
                if(rx_done_flag==0) //solo si el done esta en 1 pero en el ciclo anterior estuvo bajo
                begin
                    if(i_debugunit_rx_data == CODE_CARGA_INSTR) begin
                        state_next = CARGANDO;
                    end
                    if(i_debugunit_rx_data == CODE_MODO_CONTINUO) begin
                        state_next = MODO_CONTINUO;
                    end
                    if(i_debugunit_rx_data == CODE_MODO_PASO_A_PASO) begin
                        state_next = MODO_PASO_A_PASO;
                    end
                    if(i_debugunit_rx_data == CODE_SEND_PC)begin
                        send_data_buffer_next = i_debugunit_pc;
                        state_next = SEND_DATA;
                    end
                    if(i_debugunit_rx_data == CODE_SEND_REGS)begin
                        state_next = SEND_REGS;
                    end
                    if(i_debugunit_rx_data == CODE_SEND_MEM)begin
                        state_next = SEND_MEM;
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
            //rx_done_flag_next = 0;
        end
        
        MODO_CONTINUO: begin
            if(i_debugunit_halt)
                state_next = ESPERA;
            else
                state_next = MODO_CONTINUO;
        end
         
        MODO_PASO_A_PASO: begin
            state_next = ESPERA;
        end

        SEND_REGS: begin
            contador_palabras_next = 0;
            if(contador_registros == 32)
            begin
                sending_regs_flag_next = 0;
                state_next = ESPERA;
            end
            else
            begin
                send_data_buffer_next = i_debugunit_reg_data;
                contador_registros_next = contador_registros + 1;
                sending_regs_flag_next = 1;
                state_next = SEND_DATA;
            end
        end

        SEND_MEM: begin
            contador_palabras_next = 0;
            if(contador_memoria == MEM_DEPTH)
            begin
                sending_mem_flag_next = 0;
                state_next = ESPERA;
            end
            else
            begin
                send_data_buffer_next = i_debugunit_read_data;
                contador_memoria_next = contador_memoria + 4;
                sending_mem_flag_next = 1;
                state_next = SEND_DATA;
            end
        end

        SEND_DATA: begin  //ENVIA LAS 4 PALABRAS DEL CONTENIDO DEL send_data_buffer
            rx_done_flag_next = 0;
            if(i_debugunit_tx_done) begin

                if(contador_palabras == (NB_INSTR/NB_RX)) begin
                    contador_palabras_next = 0;
                    if(sending_regs_flag)
                        state_next = SEND_REGS;
                    else if(sending_mem_flag)
                        state_next = SEND_MEM;
                    else
                        state_next = ESPERA;
                end
                else begin
                    tx_data_done = 1;
                    send_data_buffer_next = send_data_buffer>>8;
                    contador_palabras_next = contador_palabras + 1;
                    state_next = SEND_DATA;
                end
            end
            else begin
                tx_data_done = 0;
            end
        end
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
            o_debugunit_tx_data=0;
            o_debugunit_tx_data_done=0;
            o_debugunit_reg_addr = contador_registros[NB_RS-1:0];
            o_debugunit_read_addr = contador_memoria;
        end
        CARGANDO: begin
            o_debugunit_instr_data = 0;
            o_debugunit_instr_addr = 0;
            o_debugunit_enable = 0;
            o_debugunit_instr_done = 0;
            o_debugunit_tx_data=0;
            o_debugunit_tx_data_done=0;
            o_debugunit_reg_addr = 0;
            o_debugunit_read_addr = 0;

        end
        LISTO: begin
            o_debugunit_instr_data = instr_buffer;
            o_debugunit_instr_addr = contador_instr;
            o_debugunit_enable = 0;
            o_debugunit_instr_done = 1;
            o_debugunit_tx_data=0;
            o_debugunit_tx_data_done=0;
            o_debugunit_reg_addr = 0;
            o_debugunit_read_addr = 0;

        end
        
        MODO_CONTINUO: begin
            o_debugunit_instr_data = 0;
            o_debugunit_instr_addr = 0;
            o_debugunit_enable = 1;
            o_debugunit_instr_done = 0;
            o_debugunit_tx_data=0;
            o_debugunit_tx_data_done=0;
            o_debugunit_reg_addr = 0;
            o_debugunit_read_addr = 0;

        end
        
        MODO_PASO_A_PASO: begin
            o_debugunit_instr_data = 0;
            o_debugunit_instr_addr = 0;
            o_debugunit_enable = 1;
            o_debugunit_instr_done = 0;
            o_debugunit_tx_data=0;
            o_debugunit_tx_data_done=0;
            o_debugunit_reg_addr = 0;
            o_debugunit_read_addr = 0;

        end
        
        SEND_DATA: begin
            o_debugunit_instr_data = 0;
            o_debugunit_instr_addr = 0;
            o_debugunit_enable = 0;
            o_debugunit_instr_done = 0;
            o_debugunit_tx_data=send_data_buffer[NB_TX-1:0];
            o_debugunit_tx_data_done=tx_data_done;
            o_debugunit_reg_addr = contador_registros[NB_RS-1:0];
            o_debugunit_read_addr = contador_memoria;

        end

        SEND_REGS: begin
            o_debugunit_instr_data = 0;
            o_debugunit_instr_addr = 0;
            o_debugunit_enable = 0;
            o_debugunit_instr_done = 0;
            o_debugunit_tx_data=send_data_buffer[NB_TX-1:0];
            o_debugunit_tx_data_done=tx_data_done;
            o_debugunit_reg_addr = contador_registros[NB_RS-1:0];
            o_debugunit_read_addr = 0;

        end
        SEND_MEM: begin
            o_debugunit_instr_data = 0;
            o_debugunit_instr_addr = 0;
            o_debugunit_enable = 0;
            o_debugunit_instr_done = 0;
            o_debugunit_tx_data=send_data_buffer[NB_TX-1:0];
            o_debugunit_tx_data_done=tx_data_done;
            o_debugunit_reg_addr = 0;
            o_debugunit_read_addr = contador_memoria;

        end

        default: begin
            o_debugunit_instr_data = 0;
            o_debugunit_instr_addr = 0;
            o_debugunit_enable = 0;
            o_debugunit_instr_done = 0;
            o_debugunit_tx_data=0;
            o_debugunit_tx_data_done=0;
            o_debugunit_reg_addr = 0;
            o_debugunit_read_addr = 0;

        end
   endcase
end





endmodule
