`timescale 1ns / 1ps

`include "i2c_master.v"
`include "i2c_slave.v"
`include "fpga_translator.v"
`include "clk_divider.v"


module i2c_top(
    input  wire clk,         
    input  wire rst,          
    input  wire [6:0] address, 
    input  wire [7:0] data_in, 
    input  wire read_write,    
    input  wire en,            

    output wire [7:0] data_out, 

    inout wire SDA, 
    inout wire SCL,

    inout wire SDA_out_1, 
    inout wire SCL_out_1,
    inout wire SDA_out_2, 
    inout wire SCL_out_2
);

    
    wire [7:0] master_data_out;
    assign data_out = master_data_out;

    i2c_master master_inst( .clk(clk),  .rst(rst), .address(address),  .data_in(data_in),  .read_write (read_write),  .en (en),  .data_out (master_data_out),  .SCL (SCL),  .SDA (SDA)  );

   
 	 fpga_translator trans_inst( .SDA (SDA), .SCL  (SCL), .SDA_out_1 (SDA_out_1), .SCL_out_1(SCL_out_1), .SDA_out_2 (SDA_out_2), .SCL_out_2 (SCL_out_2) );

    
    i2c_slave slave1_inst( .SCL (SCL_out_1), .SDA (SDA_out_1) );

  
 	i2c_slave slave2_inst( .SCL (SCL_out_2), .SDA (SDA_out_2) );

endmodule


