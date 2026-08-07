`timescale 1ns/1ps

module testbench;
    reg clk;
    reg reset;
    wire [3:1] ena;
    wire [15:0] q;

    integer errors;
    integer i;

    top_module dut(.clk(clk), .reset(reset), .ena(ena), .q(q));

    initial clk = 0;
    always #5 clk = ~clk;

    function [15:0] bcd_of;
        input integer val; // 0..9999
        reg [3:0] d0, d1, d2, d3;
        begin
            d0 = val % 10;
            d1 = (val / 10) % 10;
            d2 = (val / 100) % 10;
            d3 = (val / 1000) % 10;
            bcd_of = {d3, d2, d1, d0};
        end
    endfunction

    task check_state;
        input integer expected_val;
        reg [15:0] expected_q;
        reg [3:1] expected_ena;
        begin
            expected_q = bcd_of(expected_val);
            expected_ena[1] = (expected_q[3:0] == 4'd9);
            expected_ena[2] = expected_ena[1] && (expected_q[7:4] == 4'd9);
            expected_ena[3] = expected_ena[2] && (expected_q[11:8] == 4'd9);

            if (q !== expected_q) begin
                errors = errors + 1;
                $display("FAIL: count=%0d q=%h expected_q=%h", expected_val, q, expected_q);
            end
            if (ena !== expected_ena) begin
                errors = errors + 1;
                $display("FAIL: count=%0d ena=%b expected_ena=%b", expected_val, ena, expected_ena);
            end
        end
    endtask

    initial begin
        errors = 0;
        reset = 1;

        // synchronous reset takes effect on the first posedge; sample after
        // the following negedge once q has settled
        @(negedge clk);
        reset = 0;
        check_state(0);

        // run through two full 0000-9999 cycles, checking every count and
        // the ena chain at each step
        for (i = 1; i <= 20000; i = i + 1) begin
            @(negedge clk);
            check_state(i % 10000);
        end

        // reset mid-count and confirm it resumes counting from 0
        reset = 1;
        @(negedge clk);
        check_state(0);
        reset = 0;
        @(negedge clk);
        check_state(1);

        if (errors == 0)
            $display("PASSED: all tests passed");
        else
            $display("FAILED: %0d errors found", errors);

        $finish;
    end
endmodule
