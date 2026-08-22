`timescale 1ns/1ps

module counter (
    input  clk,
    input  reset,
    output reg [7:0] q
);
    always @(posedge clk) begin
        if (reset) q <= 0;
        else q <= q + 1'b1;
    end
endmodule

module testbench;
    reg clk, reset;
    wire [7:0] q;

    counter dut (.clk(clk), .reset(reset), .q(q));

    initial clk = 0;
    always #5 clk = ~clk;

    // Dump every signal in this module (and below) to a VCD file that a
    // waveform viewer (e.g. GTKWave) can open, so you can visually step
    // through signal transitions instead of reading $display text.
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, testbench);
    end

    initial begin
        reset = 1;
        @(posedge clk);
        #1 reset = 0;
        repeat (8) @(posedge clk);
        $finish;
    end
endmodule
