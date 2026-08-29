`timescale 1ns / 1ps

// Only a task can contain event control (@...), e.g. waiting on a clock
// edge; a function cannot.
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

module example;
    reg clk, reset;
    wire [7:0] q;

    counter dut (
        .clk(clk),
        .reset(reset),
        .q(q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task wait_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) @(posedge clk);
        end
    endtask

    initial begin
        reset = 1;
        @(posedge clk);
        #1 reset = 0;

        wait_cycles(4);
        #1;  // let the 4th edge's nonblocking update to q settle before reading it
        $display("t=%0t after waiting 4 clock edges, q=%0d", $time, q);

        $finish;
    end
endmodule
