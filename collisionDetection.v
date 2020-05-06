`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2020 06:14:53 PM
// Design Name: 
// Module Name: collisionDetection
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


function rectangleCollision;
    input [10:0] startx;
    input [10:0] endx;
    input [10:0] starty;
    input [10:0] endy;
    input [10:0] testx;
    input [10:0] testy;
    rectangleCollision = (testx >= startx) & (testx < endx) & (testy >= starty) & (testy < endy);
endfunction
