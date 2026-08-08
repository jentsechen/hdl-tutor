`timescale 1ns/1ps

module testbench;
    // TODO: reg for each input, wire for each output
    integer errors;

    top_module dut (
        // TODO: port connections
    );

    // TODO: if the DUT is clocked, add a clock generator, e.g.:
    // reg clk = 0;
    // always #5 clk = ~clk;

    task check;
        // TODO: inputs describing the stimulus/expected result
        begin
            #1;
            // TODO: compare dut outputs against expected values with !==,
            // incrementing errors and $display-ing a FAIL line on mismatch
        end
    endtask

    initial begin
        errors = 0;

        // TODO: apply stimulus via check() — cover basic cases, edge
        // cases, and (for sequential designs) reset behavior

        if (errors == 0)
            $display("PASSED: all tests passed");
        else
            $display("FAILED: %0d errors found", errors);

        $finish;
    end
endmodule
