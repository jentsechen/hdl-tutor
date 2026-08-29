`timescale 1ns / 1ps

// Demonstrates Verilog `function`:
//   - must have at least one input, and returns exactly one value
//   - the function's own name acts as the implicit return variable
//   - executes in zero simulation time, and cannot contain #delay or
//     @(...) event-control statements (only a task can - see ../01-task)
module testbench;

    // Multi-input function with an explicit return width.
    function [7:0] multiply;
        input [3:0] a;
        input [3:0] b;
        begin
            multiply = a * b;
        end
    endfunction

    reg [3:0] x, y;
    reg  [7:0] product_proc;
    wire [7:0] product_comb;

    // A function call is just an expression, so it can drive combinational
    // logic directly:
    assign product_comb = multiply(x, y);

    initial begin
        // The same function called from procedural code, assigned like any
        // other expression. Called with argument names (x, y) different
        // from the function's own input names (a, b) - no conflict, since a
        // function's inputs are local to it.
        x = 4'd3;
        y = 4'd5;
        product_proc = multiply(x, y);
        #1;
        $display("multiply(%0d, %0d) = %0d (procedural)  %0d (assign)", x, y, product_proc,
                 product_comb);

        x = 4'd7;
        y = 4'd9;
        product_proc = multiply(x, y);
        #1;
        $display("multiply(%0d, %0d) = %0d (procedural)  %0d (assign)", x, y, product_proc,
                 product_comb);

        // A function executes in zero simulation time: calling it twice in
        // a row never advances $time.
        $display("t=%0t before two back-to-back calls", $time);
        product_proc = multiply(4'd2, 4'd2);
        product_proc = multiply(4'd3, 4'd3);
        $display("t=%0t after two back-to-back calls (unchanged)", $time);

        // NOTE: a function cannot contain delays or event controls - this
        // would fail to compile inside `multiply`:
        //   function [7:0] bad;
        //       input [3:0] a;
        //       begin
        //           #5;              // illegal: no #delay in a function
        //           @(posedge clk);  // illegal: no event control either
        //           bad = a;
        //       end
        //   endfunction

        $finish;
    end
endmodule
