`timescale 1ns / 1ps

// A task can have multiple outputs - a function can only return one value.
module testbench;
    reg [7:0] a, b;
    reg [7:0] and_out, or_out, xor_out;

    task logic_operations;
        input [7:0] a;
        input [7:0] b;
        output [7:0] and_result;
        output [7:0] or_result;
        output [7:0] xor_result;
        begin
            and_result = a & b;
            or_result  = a | b;
            xor_result = a ^ b;
        end
    endtask

    initial begin
        a = 8'b1100_1010;
        b = 8'b1010_1100;
        logic_operations(a, b, and_out, or_out, xor_out);
        $display("a=%b", a);
        $display("b=%b", b);
        $display("and=%b", and_out);
        $display("or=%b", or_out);
        $display("xor=%b", xor_out);
        $display();

        a = 8'hF0;
        b = 8'h0F;
        logic_operations(a, b, and_out, or_out, xor_out);
        $display("a=%b", a);
        $display("b=%b", b);
        $display("and=%b", and_out);
        $display("or=%b", or_out);
        $display("xor=%b", xor_out);

        $finish;
    end
endmodule
