`timescale 1ns/1ps

module testbench;
    reg clk;
    reg reset;
    reg in;
    wire disc;
    wire flag;
    wire err;

    integer errors;
    integer i;

    localparam [3:0] CNT0 = 4'd0, CNT1 = 4'd1, CNT2 = 4'd2, CNT3 = 4'd3;
    localparam [3:0] CNT4 = 4'd4, CNT5 = 4'd5, CNT6 = 4'd6;
    localparam [3:0] DISC = 4'd7, FLAG = 4'd8, ERR = 4'd9;
    reg [3:0] model_state;

    top_module dut (
        .clk(clk),
        .reset(reset),
        .in(in),
        .disc(disc),
        .flag(flag),
        .err(err)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    function [3:0] next_state_of;
        input [3:0] s;
        input inv;
        begin
            case (s)
                CNT0: next_state_of = inv ? CNT1 : CNT0;
                CNT1: next_state_of = inv ? CNT2 : CNT0;
                CNT2: next_state_of = inv ? CNT3 : CNT0;
                CNT3: next_state_of = inv ? CNT4 : CNT0;
                CNT4: next_state_of = inv ? CNT5 : CNT0;
                CNT5: next_state_of = inv ? CNT6 : DISC;
                CNT6: next_state_of = inv ? ERR : FLAG;
                ERR:  next_state_of = inv ? ERR : CNT0;
                DISC: next_state_of = inv ? CNT1 : CNT0;
                FLAG: next_state_of = inv ? CNT1 : CNT0;
                default: next_state_of = CNT0;
            endcase
        end
    endfunction

    // compares the DUT's outputs against the reference model once the
    // combinational logic has had time to settle
    task check;
        begin
            #1;
            if (disc !== (model_state == DISC) ||
                flag !== (model_state == FLAG) ||
                err  !== (model_state == ERR)) begin
                errors = errors + 1;
                $display("FAIL: state=%0d in=%b disc=%b flag=%b err=%b expected disc=%b flag=%b err=%b",
                          model_state, in, disc, flag, err,
                          model_state == DISC, model_state == FLAG, model_state == ERR);
            end
        end
    endtask

    task step;
        input inv;
        begin
            in = inv;
            @(posedge clk);
            model_state = next_state_of(model_state, inv);
            check;
        end
    endtask

    task do_reset;
        begin
            reset = 1;
            @(posedge clk);
            model_state = CNT0;
            // check's own #1 delay lets the DUT's synchronous reset resolve
            // before we touch `reset` again, avoiding a same-edge race
            // between this deassertion and the DUT's always block
            check;
            reset = 0;
        end
    endtask

    initial begin
        errors = 0;
        in = 0;
        reset = 0;
        model_state = CNT0;

        do_reset;

        // a flag byte (six 1s bounded by 0s): CNT0..CNT6 then FLAG, then
        // back to CNT0
        step(1'b0);
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b0); // CNT6 --0--> FLAG
        step(1'b0); // FLAG --0--> CNT0

        // stuffed bit: five 1s then a 0 (discard), then a 1 (DISC->CNT1)
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b0); // CNT5 --0--> DISC
        step(1'b1); // DISC --1--> CNT1
        step(1'b0); // CNT1 --0--> CNT0

        // stuffed bit followed directly by 0: DISC --0--> CNT0
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b0); // CNT5 --0--> DISC
        step(1'b0); // DISC --0--> CNT0

        // seven consecutive 1s: overruns into ERR, stays in ERR while in=1
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1); // CNT0..CNT6
        step(1'b1); // CNT6 --1--> ERR
        step(1'b1); // ERR --1--> ERR
        step(1'b0); // ERR --0--> CNT0

        // FLAG --1--> CNT1
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1);
        step(1'b1); // CNT0..CNT6
        step(1'b0); // CNT6 --0--> FLAG
        step(1'b1); // FLAG --1--> CNT1
        step(1'b0); // CNT1 --0--> CNT0

        // reset mid-sequence should force CNT0 regardless of current state
        step(1'b1);
        step(1'b1);
        step(1'b1);
        do_reset;

        // randomized stress test
        for (i = 0; i < 1000; i = i + 1) begin
            step($random);
        end

        do_reset;

        if (errors == 0)
            $display("PASSED: all tests passed");
        else
            $display("FAILED: %0d errors found", errors);

        $finish;
    end
endmodule
