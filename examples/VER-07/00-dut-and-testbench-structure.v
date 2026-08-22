`timescale 1ns / 1ps

// The "DUT" (Design Under Test) - the module being verified.
module adder (
    input  [3:0] a,
    input  [3:0] b,
    output [4:0] sum
);
    assign sum = a + b;
endmodule

// Canonical testbench structure:
//   1. declare regs/wires to drive and observe the DUT
//   2. instantiate the DUT
//   3. an `initial` block that applies stimulus and checks results
//   4. end with $finish
module testbench;
    reg [3:0] a, b;
    wire [4:0] sum;

    adder dut (
        .a  (a),
        .b  (b),
        .sum(sum)
    );

    initial begin
        a = 4'd3;
        b = 4'd4;
        #1 $display("a=%0d b=%0d sum=%0d", a, b, sum);

        a = 4'd9;
        b = 4'd7;
        #1 $display("a=%0d b=%0d sum=%0d", a, b, sum);

        $finish;
    end
endmodule
