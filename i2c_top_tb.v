`timescale 1ns / 1ps

module i2c_top_tb;


    reg   clk;
    reg   rst;
    reg  [6:0] address;
    reg  [7:0] data_in;
    reg  read_write;
    reg   en;
    
    wire [7:0] data_out;
    wire   SDA;
    wire  SCL;
    wire  SDA_out_1;
    wire  SCL_out_1;
    wire  SDA_out_2;
    wire  SCL_out_2;


    i2c_top uut ( .clk  (clk), .rst (rst), .address (address),  .data_in(data_in), .read_write (read_write), .en (en), .data_out (data_out),  .SDA (SDA),  .SCL (SCL), .SDA_out_1 (SDA_out_1),  .SCL_out_1 (SCL_out_1),  .SDA_out_2  (SDA_out_2), .SCL_out_2 (SCL_out_2)  );


    initial begin
        clk = 0;
        forever #5 clk = ~clk;  
    end


    always @(posedge uut.master_inst.state)
    $display("STATE=%0d SDA=%b SCL=%b DATA_OUT=%h", uut.master_inst.state, SDA, SCL, data_out);

    
    initial begin
        rst = 1;
        en  = 0;
        address    = 7'd48;  
        data_in    = 8'h0C;  
        read_write = 1;     
        #50;
        rst = 0;
    end

   
  
    initial begin
       
        $dumpfile("i2c_top_tb.vcd");
        $dumpvars(0, i2c_top_tb);

       
        #100;

        
        en = 1;
        #54000;    

       
        read_write = 0;
        #545000;

       
        $finish;
    end
endmodule