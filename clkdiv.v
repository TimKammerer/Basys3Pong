`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2020 11:48:41 PM
// Design Name: 
// Module Name: clkdiv
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

module clkdiv1000000(input inclk, output reg outclk);
    reg [18:0] count = 0;
    always @(posedge inclk) begin
        count = count + 1;
        if(count == 19'd500000) begin
            count = 0;
            outclk = ~outclk;
        end
    end
endmodule

// Divides the input clock by 20/13
module clkdiv20_13(input inclk, output outclk);
  reg [4:0] count0 = 0;
  reg [1:0] count1 = 0;
  reg [1:0] count2 = 0;
  
  assign outclk = (count1 == 0) | (count2 == 0);
  always @(posedge inclk) begin
    count0 = count0+1;
    count1 = count1+1;
    if(count0 == 20) begin
      count0 = 0;
      count1 = 0;
    end else
    if(count1 == 3)
      count1 = 0;
  end
  always @(negedge inclk) begin
    if(count0 == 19)
        count2 = 0;
    count2 = count2+1;
    if(count2 == 3)
      count2 = 0;
  end
endmodule