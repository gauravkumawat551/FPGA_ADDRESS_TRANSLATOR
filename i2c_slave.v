`timescale 1ns / 1ps
module i2c_slave #(parameter address = 7'd48)(
    inout SCL,
    inout SDA
);

    logic i2c_sda;
    logic [2:0] state = 0;
    logic [7:0] temp_address;
    logic [7:0] mem;
    logic [3:0] bit_count;
    logic [7:0] send_data = 8'd12;

    logic wr_en = 0;
    logic start = 0;
    logic stop = 0;

 
    assign SDA = (wr_en) ? i2c_sda : 1'bz;

   
    typedef enum logic [2:0] {STATE_IDLE = 3'd0, STATE_READ_ADDR  = 3'd1, STATE_SEND_ACK = 3'd2, STATE_READ_DATA = 3'd3, STATE_WRITE_DATA = 3'd4, STATE_SEND_RECV_ACK = 3'd5 } i2c_state_t;

  
    always @(negedge SDA) begin
        if (!start && SCL == 1) begin
            start <= 1;
            stop <= 0;
            state <= STATE_READ_ADDR;
            bit_count <= 7;
            wr_en <= 0;
        end
    end

    
    always @(posedge SCL) begin
        if (!stop)
            stop <= 1;
    end

    always @(posedge SDA) begin
        if (stop == 1 && SCL == 1) begin
            start <= 0;
            stop <= 0;
            state <= STATE_IDLE;
            wr_en <= 0;
        end
    end


    always @(posedge SCL) begin
        if (start) begin

            case (state)

               
                STATE_IDLE: begin
                    state <= STATE_IDLE;
                end

                STATE_READ_ADDR: begin
                    temp_address[bit_count] <= SDA;

                    if (bit_count == 0) begin
                        
                        if (temp_address[7:1] == address)
                            state <= STATE_SEND_ACK;
                        else
                            state <= STATE_IDLE;

                        bit_count <= 7;
                    end
                    else begin
                        bit_count <= bit_count - 1;
                    end
                end

            
                STATE_SEND_ACK: begin
                    if (temp_address[0] == 1'b1)
                        state <= STATE_READ_DATA;   
                    else
                        state <= STATE_WRITE_DATA;  
                end

              
                STATE_READ_DATA: begin
                    if (bit_count == 0) begin
                        state <= STATE_SEND_RECV_ACK;
                        bit_count <= 7;
                    end
                    else begin
                        bit_count <= bit_count - 1;
                    end
                end

               
                STATE_WRITE_DATA: begin
                    mem[bit_count] <= SDA;

                    if (bit_count == 0) begin
                        state <= STATE_SEND_RECV_ACK;
                        bit_count <= 7;
                    end
                    else begin
                        bit_count <= bit_count - 1;
                    end
                end

                STATE_SEND_RECV_ACK: begin
                    state <= STATE_READ_ADDR;
                end

            endcase
        end
    end


   
    // OUTPUT LOGIC 
   
    always @(negedge SCL) begin
        if (start) begin

            case (state)

                STATE_IDLE: begin
                    wr_en <= 0;
                end

                STATE_READ_ADDR: begin
                    wr_en <= 0;
                end

                STATE_SEND_ACK: begin
                    wr_en <= 1;
                    i2c_sda <= 0;
                end

              
                STATE_READ_DATA: begin
                    wr_en <= 1;
                    i2c_sda <= send_data[bit_count];
                end

 
                STATE_WRITE_DATA: begin
                    wr_en <= 0;
                end

                STATE_SEND_RECV_ACK: begin
                    wr_en <= (temp_address[0]) ? 0 : 1;  
                    i2c_sda <= 0;
                end

            endcase
        end
    end

endmodule

