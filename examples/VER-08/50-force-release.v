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

    always @(posedge clk) $display("t=%0t q=%0d", $time, q);

    initial begin
        reset = 1;
        @(posedge clk);
        #1 reset = 0;

        #50;
        // Override the counter's output for debugging/stimulus, ignoring
        // whatever the design would normally drive.
        force dut.q = 8'd1;
        #20;
        release dut.q; // dut.q resumes being driven by the counter's logic

        #30;
        $finish;
    end
endmodule
