`timescale 1ns/1ps

module testbench;
    reg clk;
    reg [7:0] a, b;
    wire [7:0] sum = a + b; // $monitor can only take signals, not expressions
    integer edge_count;

    initial clk = 0;
    always #5 clk = ~clk; // would toggle forever on its own
    always @(posedge clk) edge_count = edge_count + 1;

    // $display prints its arguments immediately, once - like printf.
    initial begin
        edge_count = 0;
        a = 1;
        b = 2;
        $display("t=%0t $display: a=%0d b=%0d sum=%0d", $time, a, b, sum);
    end

    // $monitor is set up once, then automatically re-prints whenever any
    // of its listed variables changes value - no need to call it again.
    initial $monitor("t=%0t $monitor: a=%0d b=%0d sum=%0d", $time, a, b, sum);

    initial begin
        #12;
        // $display prints immediately, so it can show a value from before
        // other statements scheduled for this same time step have run.
        // $strobe waits until everything scheduled for this time step has
        // settled, so it always shows the final value.
        $display("t=%0t $display: a=%0d (may be stale)", $time, a);
        $strobe("t=%0t $strobe : a=%0d (always settled)", $time, a);
        a = 5; // scheduled for the same time step as the two prints above

        #10 b = 9;

        // $finish stops the simulator immediately, wherever it's called.
        // Without it, the free-running clock above would toggle forever.
        #10;
        $display("t=%0t stopping after %0d clock edges", $time, edge_count);
        $finish;
    end
endmodule
