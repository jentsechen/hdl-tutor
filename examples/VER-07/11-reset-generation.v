`timescale 1ns / 1ps

module counter (
    input clk,
    input reset,
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

    counter dut (
        .clk(clk),
        .reset(reset),
        .q(q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // Standard reset-generation pattern: assert reset at the start of
    // simulation, hold it across a couple of clock edges so the DUT
    // definitely samples it, then release it from a known state.
    initial begin
        reset = 1;
        @(posedge clk);
        @(posedge clk);
        #1 reset = 0;
        $display("t=%0t reset released, q=%0d", $time, q);

        repeat (3) @(posedge clk);
        #1 $display("t=%0t q=%0d", $time, q);

        $finish;
    end
endmodule
