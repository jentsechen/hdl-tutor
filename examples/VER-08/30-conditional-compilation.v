`timescale 1ns / 1ps

`define DEBUG

module counter (
    input clk,
    input reset,
    output reg [7:0] q
);
    always @(posedge clk) begin
        if (reset) q <= 0;
        else q <= q + 1'b1;
    end

`ifdef DEBUG
    // Only compiled in when `DEBUG is defined above.
    always @(posedge clk) $display("t=%0t counter q=%0d", $time, q);
`endif
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

    initial begin
        reset = 1;
        @(posedge clk);
        #1 reset = 0;

        repeat (4) @(posedge clk);

        $finish;
    end
endmodule
