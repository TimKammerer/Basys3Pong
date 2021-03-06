`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2020 11:53:05 PM
// Design Name: 
// Module Name: vga800x600
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


module vga800x600(
    input i_clk,           // base clock
    input i_pix_stb,       // pixel clock strobe
    input i_rst,           // reset: restarts frame
    output o_hs,           // horizontal sync
    output o_vs,           // vertical sync
    output o_active,       // high during active pixel drawing, low during blanking interval
    output o_screenend,    // high for one tick at the end of screen
    output o_animate,      // high for one tick at end of active drawing
    output [10:0] o_x,      // current pixel x position
    output [9:0] o_y       // current pixel y position
    );

    // VGA timings https://timetoexplore.net/blog/video-timings-vga-720p-1080p
    localparam HS_STA = 40;              // horizontal sync start
    localparam HS_END = 40 + 128;         // horizontal sync end
    localparam HA_STA = 40 + 128 + 88;    // horizontal active pixel start
//    localparam HS_STA = 800 + 40;              // horizontal sync start
//    localparam HS_END = 800 + 40 + 128;         // horizontal sync end
//    localparam HA_END = 800;    // horizontal active pixel end
    localparam VS_STA = 600 + 1;        // vertical sync start
    localparam VS_END = 600 + 1 + 4;    // vertical sync end
    localparam VA_END = 600;             // vertical active pixel end
    localparam LINE   = 1056;             // complete line (pixels)
    localparam SCREEN = 628;             // complete screen (lines)
    
    reg [10:0] h_count;  // line position
    reg [9:0] v_count;  // screen position

    // generate sync signals (active low for 640x480)
    assign o_hs = ((h_count >= HS_STA) & (h_count < HS_END));
    assign o_vs = ((v_count >= VS_STA) & (v_count < VS_END));

    // keep x and y bound within the active pixels
    assign o_x = (h_count < HA_STA) ? 0 : (h_count - HA_STA);
    //assign o_x = (h_count >= HA_END) ? (HA_END - 1) : (h_count);
    assign o_y = (v_count >= VA_END) ? (VA_END - 1) : (v_count);

    // active: high during active pixel drawing, low during the blanking period
    assign o_active = ~((h_count < HA_STA) | (v_count > VA_END - 1)); 
    //assign o_active = ~((h_count > HA_END - 1) | (v_count > VA_END - 1));

    // screenend: high for one tick at the end of the screen
    assign o_screenend = ((v_count == SCREEN - 1) & (h_count == LINE));

    // animate: high for one tick at the end of the final active pixel line
    assign o_animate = ((v_count == VA_END - 1) & (h_count == LINE));

    always @ (posedge i_clk)
    begin
        if (i_rst)  // reset to start of frame
        begin
            h_count <= 0;
            v_count <= 0;
        end
        if (i_pix_stb)  // once per pixel
        begin
            if (h_count == LINE)  // end of line
            begin
                h_count <= 0;
                v_count <= v_count + 1;
            end
            else 
                h_count <= h_count + 1;

            if (v_count == SCREEN)  // end of screen
                v_count <= 0;
        end
    end
endmodule