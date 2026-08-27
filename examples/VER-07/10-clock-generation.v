`timescale 1ns / 1ps

module testbench;
    reg clk;

    // The standard free-running clock generator: initialize once, then
    // toggle forever on a fixed half-period.
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns period -> 100MHz

    integer i;
    initial begin
        for (i = 0; i < 6; i = i + 1) begin
            @(posedge clk);
            $display("t=%0t posedge #%0d", $time, i);
        end
        $finish;
    end
endmodule
