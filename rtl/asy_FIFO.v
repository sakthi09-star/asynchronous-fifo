`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2025 11:41:10 AM
// Design Name: 
// Module Name: asy_FIFO
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

module async_fifo #(parameter DSIZE = 8, ASIZE = 4)(
    input                   wclk, wrst_n,
    input                   rclk, rrst_n,
    input                   winc, rinc,
    input  [DSIZE-1:0]      wdata,
    output [DSIZE-1:0]      rdata,
    output                  wfull, walmost_full,
    output                  rempty, ralmost_empty
);

    wire [ASIZE:0] wptr, rptr;
    wire [ASIZE:0] wgray, rgray;
    wire [ASIZE:0] wq2_rgray, rq2_wgray;
    wire [ASIZE-1:0] waddr = wptr[ASIZE-1:0];
    wire [ASIZE-1:0] raddr = rptr[ASIZE-1:0];

    // Binary to Gray conversions
    assign wgray = (wptr >> 1) ^ wptr;
    assign rgray = (rptr >> 1) ^ rptr;

    // Synchronize pointers
    two_ff_sync #(ASIZE+1) sync_r2w (.clk(wclk), .rst_n(wrst_n), .din(rgray), .q2(wq2_rgray));
    two_ff_sync #(ASIZE+1) sync_w2r (.clk(rclk), .rst_n(rrst_n), .din(wgray), .q2(rq2_wgray));

    // FIFO memory
    reg [DSIZE-1:0] mem [0:(1<<ASIZE)-1];
    always @(posedge wclk) if (winc && !wfull) mem[waddr] <= wdata;
    assign rdata = mem[raddr];

    // Pointers
    reg [ASIZE:0] wptr_bin, rptr_bin;
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) wptr_bin <= 0;
        else if (winc && !wfull) wptr_bin <= wptr_bin + 1;

    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) rptr_bin <= 0;
        else if (rinc && !rempty) rptr_bin <= rptr_bin + 1;

    assign wptr = wptr_bin;
    assign rptr = rptr_bin;

    // Gray to binary conversion for comparison
    function [ASIZE:0] gray_to_bin;
        input [ASIZE:0] g;
        integer i;
        begin
            gray_to_bin[ASIZE] = g[ASIZE];
            for (i = ASIZE-1; i >= 0; i = i - 1)
                gray_to_bin[i] = gray_to_bin[i+1] ^ g[i];
        end
    endfunction

    wire [ASIZE:0] rbin_sync = gray_to_bin(wq2_rgray);
    wire [ASIZE:0] wbin_sync = gray_to_bin(rq2_wgray);

    // Status Flags
    assign wfull         = (wgray == {~wq2_rgray[ASIZE:ASIZE-1], wq2_rgray[ASIZE-2:0]});
    assign walmost_full  = ((wptr_bin + 1) == rbin_sync) || ((wptr_bin + 2) == rbin_sync);
    assign rempty        = (rgray == rq2_wgray);
    assign ralmost_empty = ((rptr_bin + 1) == wbin_sync) || ((rptr_bin + 2) == wbin_sync);

endmodule
