`timescale 1ns / 1ps

module clk_divider #(
    parameter Max_count = 125,
    parameter width = 16  
)(
    input  wire clk,
    input  wire rst,
    output wire tick
);

  reg [width-1:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 0;
      else if (counter == Max_count)
            counter <= 0;
        else
            counter <= counter + 1;
    end

  assign tick = (counter == Max_count);

endmodule
