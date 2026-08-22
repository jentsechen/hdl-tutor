`timescale 1ns / 1ps

module adder (
    input  [3:0] a,
    input  [3:0] b,
    output [4:0] sum
);
    assign sum = a + b;
endmodule

module testbench;
    reg [3:0] a, b;
    wire [4:0] sum;
    integer i;

    // A small stimulus table: apply each row's (a, b) to the DUT in turn,
    // instead of writing out every test case by hand.
    reg [3:0] a_vectors[0:3];
    reg [3:0] b_vectors[0:3];

    adder dut (
        .a  (a),
        .b  (b),
        .sum(sum)
    );

    initial begin
        a_vectors[0] = 4'd1;
        b_vectors[0] = 4'd2;
        a_vectors[1] = 4'd15;
        b_vectors[1] = 4'd1;
        a_vectors[2] = 4'd7;
        b_vectors[2] = 4'd8;
        a_vectors[3] = 4'd0;
        b_vectors[3] = 4'd0;

        for (i = 0; i < 4; i = i + 1) begin
            a = a_vectors[i];
            b = b_vectors[i];
            #1 $display("a=%0d b=%0d -> sum=%0d", a, b, sum);
        end

        $finish;
    end
endmodule
