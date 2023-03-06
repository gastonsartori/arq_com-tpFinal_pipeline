`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2023 11:16:25 AM
// Design Name: 
// Module Name: testbench_processor
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


module testbench_processor();

parameter   NB_PC = 32;        // Bits de rs
parameter   NB_INSTR = 32;          // Bits de instruccion
parameter   NB_RX = 8;              // Bits de RX
parameter   NB_REG = 32;
parameter   NB_MEMORY_DEPTH = 16;                           // Numero de entradas de la memoria


localparam CODE_CARGA_INSTR         = 8'b00000001;
localparam CODE_MODO_CONTINUO       = 8'b00000010;
localparam CODE_MODO_PASO_A_PASO    = 8'b00000100;
localparam CODE_SEND_PC             = 8'b00001000;
localparam CODE_SEND_REGS           = 8'b00010000;
localparam CODE_SEND_MEM           = 8'b00100000;
localparam ESPERA_CODE              = 8'b11110000;
reg clock, reset;
wire rx;

wire [16-1:0] wb_data;
wire tx_data;
//instrucciones a cargar
reg     [NB_INSTR - 1 : 0]  ram  [NB_MEMORY_DEPTH - 1 : 0];


always begin 
    #10 clock = !clock;
end

reg [NB_RX-1:0] data_a_enviar;
reg data_done;

wire [NB_RX-1:0] data_recibida;
wire data_recibida_done;

reg     [$clog2(NB_MEMORY_DEPTH) : 0]  i;
reg     [$clog2(NB_INSTR/NB_RX) : 0]  j;

initial begin
    clock = 0;
    reset = 1;
    data_a_enviar=0;
    data_done=0;
    
    $readmemh("out.mem",ram,0);


    #50
    reset=0;
    #20
    i=0;
    j=0;
    
    //-------------esperar a recibir code de estado espera
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #200
    
    wait(tx_done==1)
    #20;
    data_a_enviar = CODE_CARGA_INSTR;
    data_done = 1;
    #20 
    data_done = 0;
    
    while(i<NB_MEMORY_DEPTH) begin 
        //para cada instruccion de 32 bits
        //while(tx_done==0)
        //envio 4 veces, 8 bits de la instruccion
        j=0;
        while(j<(NB_INSTR/NB_RX)) begin 
            wait(tx_done==1)
            #20
            data_a_enviar = (ram[i] >> (j*NB_RX));
            data_done = 1;
            #20 
            data_done = 0;
            j=j+1;
            //while(tx_done==0)
        end
        i=i+1;
        
    end
    //-------------esperar a recibir code de estado espera
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    //----------- EJECUTAR UN CICLO ------------
    wait(tx_done==1)
    #20;
    data_a_enviar = CODE_MODO_PASO_A_PASO;
    data_done = 1;
    #20 
    data_done = 0;
    //-------------esperar a recibir code de estado espera
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    //----------------PEDIR VALOR DE PC ----------------
    wait(tx_done==1)
    #20;
    data_a_enviar = CODE_SEND_PC;
    data_done = 1;
    #20 
    data_done = 0;
    //-----------RECIBIR PC -------------
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    //----------- EJECUTAR UN CICLO ------------
    wait(tx_done==1)
    #80;
    data_a_enviar = CODE_MODO_PASO_A_PASO;
    data_done = 1;
    #20 
    data_done = 0;
//-------------esperar a recibir code de estado espera
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
//----------------PEDIR VALOR DE PC ----------------
    wait(tx_done==1)
    #20;
    data_a_enviar = CODE_SEND_PC;
    data_done = 1;
    #20 
    data_done = 0;
    //-----------RECIBIR PC -------------
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80

    //----------- EJECUTAR UN CICLO ------------
    wait(tx_done==1)
    #80;
    data_a_enviar = CODE_MODO_PASO_A_PASO;
    data_done = 1;
    #20 
    data_done = 0;
//-------------esperar a recibir code de estado espera
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    //----------------PEDIR VALOR DE PC ----------------
    wait(tx_done==1)
    #20;
    data_a_enviar = CODE_SEND_PC;
    data_done = 1;
    #20 
    data_done = 0;
    
    //-----------RECIBIR PC -------------
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80

    //----------- EJECUTAR UN CICLO ------------
    wait(tx_done==1)
    #80;
    data_a_enviar = CODE_MODO_PASO_A_PASO;
    data_done = 1;
    #20 
    data_done = 0;
//-------------esperar a recibir code de estado espera
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    //----------------PEDIR VALOR DE PC ----------------
    wait(tx_done==1)
    #20;
    data_a_enviar = CODE_SEND_PC;
    data_done = 1;
    #20 
    data_done = 0;
    //-----------RECIBIR PC -------------
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80

    //----------- EJECUTAR UN CICLO ------------
    wait(tx_done==1)
    #80;
    data_a_enviar = CODE_MODO_PASO_A_PASO;
    data_done = 1;
    #20 
    data_done = 0;
//-------------esperar a recibir code de estado espera
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    //----------------PEDIR VALOR DE PC ----------------
    wait(tx_done==1)
    #20;
    data_a_enviar = CODE_SEND_PC;
    data_done = 1;
    #20 
    data_done = 0;
    //-----------RECIBIR PC -------------
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80

    //----------- EJECUTAR UN CICLO ------------
    wait(tx_done==1)
    #80;
    data_a_enviar = CODE_MODO_PASO_A_PASO;
    data_done = 1;
    #20 
    data_done = 0;
//-------------esperar a recibir code de estado espera
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    //----------------PEDIR VALOR DE PC ----------------
    wait(tx_done==1)
    #20;
    data_a_enviar = CODE_SEND_PC;
    data_done = 1;
    #20 
    data_done = 0;
    //-----------RECIBIR PC -------------
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80 

    //----------- EJECUTAR UN CICLO ------------
    wait(tx_done==1)
    #80;
    data_a_enviar = CODE_MODO_PASO_A_PASO;
    data_done = 1;
    #20 
    data_done = 0;
//-------------esperar a recibir code de estado espera
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    //----------------PEDIR VALOR DE PC ----------------
    wait(tx_done==1)
    #20;
    data_a_enviar = CODE_SEND_PC;
    data_done = 1;
    #20 
    data_done = 0;
    //-----------RECIBIR PC -------------
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80 

    //----------- EJECUTAR UN CICLO ------------
    wait(tx_done==1)
    #80;
    data_a_enviar = CODE_MODO_PASO_A_PASO;
    data_done = 1;
    #20 
    data_done = 0;
    
//-------------esperar a recibir code de estado espera
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    //----------------PEDIR VALOR DE PC ----------------
    wait(tx_done==1)
    #20;
    data_a_enviar = CODE_SEND_PC;
    data_done = 1;
    #20 
    data_done = 0;
    //-----------RECIBIR PC -------------
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80
    wait(data_recibida_done==1)
    #80

    //--------PEDIR VALOR DE REGISTROS------------
    wait(tx_done==1)
    #20;
    data_a_enviar = CODE_SEND_MEM;
    data_done = 1;
    #20 
    data_done = 0;
    
    #10000000
    
    $finish;


end

Transmitter Transmitter(
    .i_data(data_a_enviar),
    .i_done(data_done),
    .i_tick(tick),
    .i_clock(clock),
    .i_reset(reset),
    .o_tx(rx),
    .o_tx_done(tx_done)
);

Receiver Receiver(
    .i_rx(tx_data), //entrada en serie
    .i_clock(clock),
    .i_reset(reset),
    .i_tick(tick),
    .o_rx_data(data_recibida), //salida en paralelo de 8 bits
    .o_rx_done(data_recibida_done)
);

Baud_rate_generator Baud_rate_generator(
    .i_clock(clock),
    .i_reset(reset),
    .o_tick(tick)
);

Top_processor Top_processor(
    .i_processor_clock(clock),
    .i_processor_reset(reset),
    .i_processor_rx(rx),

    .o_processor_wb_data(wb_data),
    .o_processor_tx(tx_data)

);



endmodule
