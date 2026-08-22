`timescale 1ns / 1ps

// Every `initial` block starts running at time 0. Statements *within* one
// block execute in order, but separate initial blocks run concurrently and
// interleave with each other based on their own delays.
module testbench;
    initial begin
        $display("t=%0t block A: step 1", $time);
        #10;
        $display("t=%0t block A: step 2", $time);
    end

    initial begin
        $display("t=%0t block B: step 1", $time);
        #5;
        $display("t=%0t block B: step 2", $time);
    end

    initial begin
        #15;
        $display("t=%0t block C: waits, then finishes", $time);
        $finish;
    end
endmodule
