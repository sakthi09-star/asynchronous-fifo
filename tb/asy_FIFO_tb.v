`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2025 11:44:35 AM
// Design Name: 
// Module Name: asy_FIFO_tb
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
module tb_async_fifo;

    parameter DSIZE = 8;
    parameter ASIZE = 4;
    parameter DEPTH = (1 << ASIZE);
    reg wclk, rclk;
    reg wrst_n, rrst_n;
    reg winc, rinc;
    reg [DSIZE-1:0] wdata;
    wire [DSIZE-1:0] rdata;
    wire wfull, walmost_full;
    wire rempty, ralmost_empty;

    // Instantiate FIFO
    async_fifo #(DSIZE, ASIZE) fifo_inst (
        .wclk(wclk), .wrst_n(wrst_n),
        .rclk(rclk), .rrst_n(rrst_n),
        .winc(winc), .rinc(rinc),
        .wdata(wdata), .rdata(rdata),
        .wfull(wfull), .walmost_full(walmost_full),
        .rempty(rempty), .ralmost_empty(ralmost_empty)
    );

    // Clock generation
    initial begin
        wclk = 0; rclk = 0;
        forever begin
            #5 wclk = ~wclk;       // 100 MHz write clock
        end
    end

    initial begin
        forever begin
            #7 rclk = ~rclk;       // ~71 MHz read clock (asynchronous)
        end
    end

    // Stimulus
    initial begin
        // Initialize
        wrst_n = 0; rrst_n = 0;
        winc = 0; rinc = 0;
        wdata = 0;

        #20;
        wrst_n = 1; rrst_n = 1;

        // Write 18 elements
        repeat (18) begin
            @(posedge wclk);
            if (!wfull) begin
                wdata = $random;
                winc = 1;
            end else begin
                winc = 0;
            end
        end
        winc = 0;

        // Read 10 elements
        repeat (10) begin
            @(posedge rclk);
            if (!rempty) begin
                rinc = 1;
            end else begin
                rinc = 0;
            end
        end
        rinc = 0;

        // Simultaneous read/write with wraparound
        repeat (20) begin
            @(posedge wclk);
            if (!wfull) begin
                wdata = ("2, 21, 31, 11, 9, 5, 33, 45, 16, 15, 21, 31, 27, 7, 8, 15");
                winc = 1;
            end else begin
                winc = 0;
            end
            @(posedge rclk);
            if (!rempty) begin
                rinc = 1;
            end else begin
                rinc = 0;
            end
        end

        // Finish test
        #100;
        $finish;
    end

    // Monitoring
    initial begin
        $monitor("Time=%0t | wdata=%h winc=%b wfull=%b walmost_full=%b | rdata=%h rinc=%b rempty=%b ralmost_empty=%b",
                 $time, wdata, winc, wfull, walmost_full, rdata, rinc, rempty, ralmost_empty);
    end

endmodule

