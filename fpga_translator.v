`timescale 1ns / 1ps
module fpga_translator(
    inout SDA,
    inout SCL,
    inout SDA_out_1,
    inout SCL_out_1,
    inout SDA_out_2,
    inout SCL_out_2
);

    parameter [8:0] mask = 9'b000000010;

   
    typedef enum logic [2:0] {
        ST_ADDR, ST_ADDR_ACK, ST_M2S, ST_WAIT_ACK, ST_S2M_ACK         
    } fsm_t;

    fsm_t state;

   
    reg [7:0] temp_address;
    reg [3:0] bit_count;
    reg [3:0] mask_counter;

    reg start = 0;
    reg stop  = 0;
    reg select_slave;
    reg slave_en = 0;
    reg drive_master = 1;

    
    assign SCL_out_1 = SCL;
    assign SCL_out_2 = SCL;

   
    assign SDA = drive_master ? 1'bz :
                 (slave_en ? (select_slave ? SDA_out_1 : SDA_out_2) : 1'bz);

    assign SDA_out_1 = drive_master ? SDA : 1'bz;

    assign SDA_out_2 = drive_master ?
                       (state == ST_ADDR ? SDA ^ mask[mask_counter] : SDA)
                       : 1'bz;

    // START Condition 
  
    always @(negedge SDA) begin
        if (!start && SCL) begin
            start <= 1;
            state <= ST_ADDR;
            drive_master <= 1;
            bit_count <= 7;
            mask_counter <= 8;
        end
    end

  
  
    //  STOP Condition 
  
    always @(posedge SCL) begin
        if (!stop) stop <= 1;
    end

    always @(posedge SDA) begin
        if (stop && SCL) begin
            stop <= 0;
            start <= 0;
            drive_master <= 1;
        end
    end

    // FSM: SAMPLE on posedge SCL 
  
    always @(posedge SCL) begin
        if (start) begin
            case(state)

                ST_ADDR: begin
                    temp_address[bit_count] <= SDA;

                    if (bit_count == 0) begin
                        slave_en <= 1;

                        select_slave <= (temp_address[7:1] == 7'd49) ? 0 : 1;

                        bit_count <= 7;
                        mask_counter <= 7;
                        state <= ST_ADDR_ACK;
                    end else begin
                        bit_count <= bit_count - 1;
                    end
                end

                ST_WAIT_ACK: begin
                    if (bit_count == 0) begin
                        bit_count <= 7;
                        state <= ST_S2M_ACK;
                    end else begin
                        bit_count <= bit_count - 1;
                    end
                end

            endcase
        end
    end

    //  FSM OUTPUT on negedge SCL
  
    always @(negedge SCL) begin
        if (start) begin
            case(state)

                ST_ADDR: begin
                    mask_counter <= mask_counter - 1;
                end

                ST_ADDR_ACK: begin
                    drive_master <= 0;
                    state <= ST_M2S;
                end

                ST_M2S: begin
                    drive_master <= temp_address[0] ? 0 : 1;
                    state <= ST_WAIT_ACK;
                end

                ST_S2M_ACK: begin
                    drive_master <= temp_address[0] ? 1 : 0;
                end

            endcase
        end
    end

endmodule
