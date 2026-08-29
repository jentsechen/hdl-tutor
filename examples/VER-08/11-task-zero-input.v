`timescale 1ns/1ps

// Unlike a function, which needs at least one input, a task can take none
// at all.
module testbench;
    integer call_count;

    task report_call;
        begin
            call_count = call_count + 1;
            $display("report_call invoked (call #%0d)", call_count);
        end
    endtask

    initial begin
        call_count = 0;
        report_call;
        report_call;
        report_call;
        $finish;
    end
endmodule
