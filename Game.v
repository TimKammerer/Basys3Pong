`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2020 06:38:57 PM
// Design Name: 
// Module Name: Game
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
`define SCREEN_HEIGHT 768
`define SCREEN_WIDTH 1024
`define HALF_HEIGHT 384
`define HALF_WIDTH 512
`define SCREEN_MIDDLE_X 1024
`define SCREEN_MIDDLE_Y 1024
`define SCREEN_TOP 640//`SCREEN_MIDDLE_Y - `HALF_HEIGHT
`define SCREEN_BOTTOM 1408//`SCREEN_MIDDLE_Y + `HALF_HEIGHT
`define SCREEN_LEFT 512//`SCREEN_MIDDLE_X - `HALF_WIDTH
`define SCREEN_RIGHT 1536//`SCREEN_MIDDLE_X + `HALF_WIDTH
`define GOAL_WIDTH 50
`define LEFT_PADDLE_POSITION 562//`SCREEN_LEFT + `GOAL_WIDTH
`define RIGHT_PADDLE_POSITION 1486//`SCREEN_RIGHT - `GOAL_WIDTH
`define HALF_PADDLE_WIDTH 10
`define HALF_PADDLE_HEIGHT 100
`define PADDLE_SPEED 50

module Game(
    input pclk,
    input gclk,
    input reset,
    input lupButton,
    input ldownButton,
    input rupButton,
    input rdownButton,
    input [10:0] pixelx,
    input [10:0] pixely,
    output reg[3:0] vgaR,
    output reg[3:0] vgaG,
    output reg[3:0] vgaB
    );
    `include "collisionDetection.v";
    reg gameEnd;
    wire restart = reset | gameEnd;
    wire [10:0] bTop;
    wire [10:0] bBottom;
    wire [10:0] bLeft;
    wire [10:0] bRight;
    reg [6:0] vSpeed = 7'h5F;
    reg [6:0] hSpeed = 7'h5F;
    Ball ball(gclk, restart, vSpeed, hSpeed, bTop, bBottom, bLeft, bRight);
    wire ballCollision = rectangleCollision(bLeft, bRight, bTop, bBottom, pixelx + `SCREEN_LEFT, pixely + `SCREEN_TOP);
    
    wire [10:0] lpTop;
    wire [10:0] lpBottom;
    wire [10:0] lpLeft;
    wire [10:0] lpRight;
    Paddle leftPaddle(gclk, restart, lupButton, ldownButton, `LEFT_PADDLE_POSITION, lpTop, lpBottom, lpLeft, lpRight);
    wire paddle1Collision = rectangleCollision(lpLeft, lpRight, lpTop, lpBottom, pixelx + `SCREEN_LEFT, pixely + `SCREEN_TOP);
    
    wire [10:0] rpTop;
    wire [10:0] rpBottom;
    wire [10:0] rpLeft;
    wire [10:0] rpRight;
    Paddle rightPaddle(gclk, restart, rupButton, rdownButton, `RIGHT_PADDLE_POSITION, rpTop, rpBottom, rpLeft, rpRight);
    wire paddlerCollision = rectangleCollision(rpLeft, rpRight, rpTop, rpBottom, pixelx + `SCREEN_LEFT, pixely + `SCREEN_TOP);
    
    always @(posedge gclk) begin
        if(reset) begin
            vSpeed = 7'h5F;
            hSpeed = 7'h5F;
        end else if(gameEnd) begin
            vSpeed = 7'h5F;
            hSpeed[6] = ~hSpeed[6];
            gameEnd = 0;
        end else begin
            if(bTop < `SCREEN_TOP)
                vSpeed[6] = 0;
            else if(bBottom > `SCREEN_BOTTOM)
                vSpeed[6] = 1;
            if(bLeft < `SCREEN_LEFT | bRight > `SCREEN_RIGHT)
                gameEnd = 1;
            if((bLeft > `LEFT_PADDLE_POSITION & bLeft <= `LEFT_PADDLE_POSITION+`HALF_PADDLE_WIDTH) & (bTop < lpBottom & bBottom > lpTop))
                hSpeed[6] = 0;
            else if((bRight < `RIGHT_PADDLE_POSITION & bRight >= `RIGHT_PADDLE_POSITION-`HALF_PADDLE_WIDTH) & (bTop < rpBottom & bBottom > rpTop))
                hSpeed[6] = 1;
        end
    end
    always @(posedge pclk) begin
        vgaR = {4{ballCollision|paddle1Collision}};
        vgaG = {4{ballCollision}};
        vgaB = {4{ballCollision|paddlerCollision}};
    end
endmodule

module Ball #( parameter resetY = 16*`SCREEN_MIDDLE_Y, parameter resetX = 16*`SCREEN_MIDDLE_X, parameter radius = 10)
            (
            input clk,
            input reset,
            input [6:0] ySpeed,
            input [6:0] xSpeed,
            output [10:0] top,
            output [10:0] bottom,
            output [10:0] left,
            output [10:0] right);
  reg [14:0] xPos = resetX;
  reg [14:0] yPos = resetY;
  assign left = xPos[14:4] - radius;
  assign right = xPos[14:4] + radius;
  assign top = yPos[14:4] - radius;
  assign bottom = yPos[14:4] + radius;
  always @( posedge clk ) begin
      if(reset) begin
          xPos = resetX;
          yPos = resetY;
      end else begin
          if(xSpeed[6])
              xPos = xPos - xSpeed[5:0];
          else
              xPos = xPos + xSpeed[5:0];
          if(ySpeed[6])
              yPos = yPos - ySpeed[5:0];
          else
              yPos = yPos + ySpeed[5:0];
      end
  end

endmodule

module Paddle #( parameter resetY = 16*`SCREEN_MIDDLE_Y)
            (
            input clk,
            input reset,
            input upButton,
            input downButton,
            input [10:0] xPos,
            output [10:0] top,
            output [10:0] bottom,
            output [10:0] left,
            output [10:0] right);
    reg [14:0] yPos = resetY;
    assign left = xPos - `HALF_PADDLE_WIDTH;
    assign right = xPos + `HALF_PADDLE_WIDTH;
    assign top = yPos[14:4] - `HALF_PADDLE_HEIGHT;
    assign bottom = yPos[14:4] + `HALF_PADDLE_HEIGHT;
    always @(posedge clk) begin
        if(reset)
            yPos = resetY;
        else begin
            if(upButton & top > `SCREEN_TOP)
                    yPos = yPos - `PADDLE_SPEED;
            else if(downButton & bottom < `SCREEN_BOTTOM)
                yPos = yPos + `PADDLE_SPEED;
        end
    end
endmodule