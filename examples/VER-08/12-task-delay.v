`timescale 1ns / 1ps

// Only a task can contain timing controls (#delay); a function cannot.
module example;
    reg reset;

    task pulse_reset;
        begin
            $display("t=%0t pulse_reset: asserting reset", $time);
            reset = 1;
            #12;  // hold reset asserted for 12ns
            reset = 0;
            $display("t=%0t pulse_reset: reset released", $time);
        end
    endtask

    initial begin
        reset = 0;
        pulse_reset;
        $display("t=%0t done", $time);
        $finish;
    end
endmodule
