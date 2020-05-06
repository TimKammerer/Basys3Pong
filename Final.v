`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2020 07:24:01 PM
// Design Name: 
// Module Name: Final
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

module Final(
    input CLK,
    input BTNU,
    input BTNL,
    input BTND,
    input BTNR,
    input BTNC,
    input [0:0] SW,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output Hsync,
    output Vsync
    );
    `include "collisionDetection.v";
    wire pclk;
    wire gclk;
    clkdiv20_13 pixeldiv(CLK, pclk);
    clkdiv1000000 gamediv(CLK, gclk);
    
    wire [10:0] pixelx;
    wire [10:0] pixely;
    wire screenrst = SW[0];
    wire gamerst = BTNC;
    wire active;
    wire screenend;
    wire animate;
    vga1024x768 display (
        .i_clk(CLK),
        .i_pix_stb(pclk),
        .i_rst(screenrst),
        .o_active(active),
        .o_screenend(screenend),
        .o_animate(animate),
        .o_hs(Hsync), 
        .o_vs(Vsync), 
        .o_x(pixelx), 
        .o_y(pixely)
    );
    Game game(
        .pclk(pclk),
        .gclk(gclk),
        .reset(gamerst),
        .lupButton(BTNL),
        .ldownButton(BTND),
        .rupButton(BTNU),
        .rdownButton(BTNR),
        .pixelx(pixelx),
        .pixely(pixely),
        .vgaR(vgaRed), 
        .vgaG(vgaGreen),
        .vgaB(vgaBlue)
    );
endmodule
