`timescale 1ns/1ps

module i2c_master (
    input  logic       clk,           
    input  logic       rst,          
    input  logic [6:0] address,      
    input  logic [7:0] data_in,       
    input  logic       read_write,    
    input  logic       en,            
    output logic [7:0] data_out,     
    inout  wire        SCL,
    inout  wire        SDA
);


    logic tick;
    logic i2c_clk;
    logic i2c_sda;
    logic i2c_clk_en;
    logic wr_en;

    logic [3:0] bit_count;
    logic [7:0] temp_address;
    logic [7:0] temp_data_in;

  
    typedef enum logic [2:0] { IDLE = 3'd0,  START  = 3'd1,  SEND_ADDR  = 3'd2, RECEIVE_ACK = 3'd3, READ_DATA = 3'd4, SEND_DATA = 3'd5, SEND_RECV_ACK = 3'd6, STOP = 3'd7 } i2c_state_t;

    i2c_state_t state;


    clk_divider #(.Max_count(125)) u_clkdiv (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );


    always_ff @(posedge tick or posedge rst) begin
        if (rst)
            i2c_clk <= 1'b0;
        else
            i2c_clk <= ~i2c_clk;
    end


    assign SCL = (i2c_clk_en) ? i2c_clk : 1'b1;

 
    assign SDA = (wr_en) ? i2c_sda : 1'bz;


 
    always_ff @(negedge i2c_clk or posedge rst) begin
        if (rst)
            i2c_clk_en <= 1'b0;
        else if (state == IDLE || state == START || state == STOP)
            i2c_clk_en <= 1'b0;
        else
            i2c_clk_en <= 1'b1;
    end



    always_ff @(posedge i2c_clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            bit_count    <= 4'd0;
            temp_address <= 8'd0;
            temp_data_in <= 8'd0;
            wr_en        <= 1'b1;
        end
        else begin
            case (state)

               
                IDLE: begin
                    if (en) begin
                        state        <= START;
                        temp_address <= {address, read_write};
                        temp_data_in <= data_in;
                    end
                end

                
                START: begin
                    state     <= SEND_ADDR;
                    bit_count <= 4'd7;
                end

                SEND_ADDR: begin
                    if (bit_count == 0)
                        state <= RECEIVE_ACK;
                    else
                        bit_count <= bit_count - 1;
                end

                RECEIVE_ACK: begin
                    bit_count <= 7;

                   
                    if (!SDA)
                        state <= (read_write ? READ_DATA : SEND_DATA);
                    else
                        state <= STOP;  
                end

                READ_DATA: begin
                    data_out[bit_count] <= SDA;

                    if (bit_count == 0) begin
                        state     <= SEND_RECV_ACK;
                        bit_count <= 7;
                    end
                    else
                        bit_count <= bit_count - 1;
                end

                SEND_DATA: begin
                    if (bit_count == 0) begin
                        state     <= SEND_RECV_ACK;
                        bit_count <= 7;
                    end
                    else
                        bit_count <= bit_count - 1;
                end

  
                SEND_RECV_ACK: begin
                    state <= STOP;
                end

                STOP: begin
                    state <= IDLE;
                end

            endcase
        end
    end


    always_ff @(negedge i2c_clk or posedge rst) begin
        if (rst) begin
            wr_en   <= 1'b1;
            i2c_sda <= 1'b1;
        end
        else begin
            case (state)

                IDLE: begin
                    wr_en   <= 1'b1;
                    i2c_sda <= 1'b1;
                end

                START: begin
                    wr_en   <= 1'b1;
                    i2c_sda <= 1'b0;  
                end

                SEND_ADDR: begin
                    wr_en   <= 1'b1;
                    i2c_sda <= temp_address[bit_count];
                end

                RECEIVE_ACK: begin
                    wr_en <= 1'b0;   
                end

                READ_DATA: begin
                    wr_en <= 1'b0;
                end

                SEND_DATA: begin
                    wr_en   <= 1'b1;
                    i2c_sda <= temp_data_in[bit_count];
                end

                SEND_RECV_ACK: begin
                    wr_en   <= read_write ? 1'b1 : 1'b0;
                    i2c_sda <= 1'b0;   
                end

                STOP: begin
                    wr_en   <= 1'b1;
                    i2c_sda <= 1'b1; 
                end

            endcase
        end
    end

endmodule
