`timescale 1ns/1ps

module testbench;
    reg clk;
    reg reset;
    reg w;
    wire z;

    integer errors;
    integer i;

    localparam [2:0] A = 0, B = 1, C = 2, D = 3, E = 4, F = 5;
    reg [2:0] model_state;

    top_module dut (
        .clk(clk),
        .reset(reset),
        .w(w),
        .z(z)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    function [2:0] next_state_of;
        input [2:0] s;
        input wv;
        begin
            case (s)
                A: next_state_of = wv ? A : B;
                B: next_state_of = wv ? D : C;
                C: next_state_of = wv ? D : E;
                D: next_state_of = wv ? A : F;
                E: next_state_of = wv ? D : E;
                F: next_state_of = wv ? D : C;
                default: next_state_of = A;
            endcase
        end
    endfunction

    function z_of;
        input [2:0] s;
        begin
            z_of = (s == E) || (s == F);
        end
    endfunction

    // compares the DUT's z against the reference model's z once the
    // combinational output has had time to settle
    task check_z;
        begin
            #1;
            if (z !== z_of(model_state)) begin
                errors = errors + 1;
                $display("FAIL: state=%0d w=%b z=%b expected=%b", model_state, w, z, z_of(model_state));
            end
        end
    endtask

    task step;
        input wv;
        begin
            w = wv;
            @(posedge clk);
            model_state = next_state_of(model_state, wv);
            check_z;
        end
    endtask

    task do_reset;
        begin
            reset = 1;
            @(posedge clk);
            model_state = A;
            // check_z's own #1 delay lets the DUT's synchronous reset
            // resolve before we touch `reset` again, avoiding a same-edge
            // race between this deassertion and the DUT's always block
            check_z;
            reset = 0;
        end
    endtask

    initial begin
        errors = 0;
        w = 0;
        reset = 0;
        model_state = A;

        do_reset;

        // walk through a scripted sequence exercising every edge of the
        // state diagram at least once
        step(1'b1); // A --1--> A
        step(1'b0); // A --0--> B
        step(1'b1); // B --1--> D
        step(1'b0); // D --0--> F
        step(1'b0); // F --0--> C
        step(1'b0); // C --0--> E
        step(1'b0); // E --0--> E
        step(1'b1); // E --1--> D
        step(1'b1); // D --1--> A
        step(1'b0); // A --0--> B
        step(1'b0); // B --0--> C
        step(1'b1); // C --1--> D
        step(1'b0); // D --0--> F
        step(1'b1); // F --1--> D

        // reset should return to A regardless of current state
        do_reset;

        // randomized stress test
        for (i = 0; i < 500; i = i + 1) begin
            step($random);
        end

        // reset again from a random state, then re-check a short sequence
        do_reset;
        step(1'b0);
        step(1'b0);
        step(1'b1);

        if (errors == 0)
            $display("PASSED: all tests passed");
        else
            $display("FAILED: %0d errors found", errors);

        $finish;
    end
endmodule
