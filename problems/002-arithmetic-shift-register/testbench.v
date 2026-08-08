`timescale 1ns/1ps

module testbench;
    reg clk;
    reg load;
    reg ena;
    reg [1:0] amount;
    reg [63:0] data;
    wire [63:0] q;

    reg [63:0] model;
    integer errors;
    integer i;

    top_module dut (
        .clk(clk),
        .load(load),
        .ena(ena),
        .amount(amount),
        .data(data),
        .q(q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    function [63:0] next_value;
        input [63:0] cur;
        input ld;
        input en;
        input [1:0] amt;
        input [63:0] d;
        begin
            if (ld)
                next_value = d;
            else if (en) begin
                case (amt)
                    2'b00: next_value = {cur[62:0], 1'b0};        // logical shift left 1
                    2'b01: next_value = {cur[55:0], 8'd0};        // logical shift left 8
                    2'b10: next_value = {cur[63], cur[63:1]};     // arithmetic shift right 1
                    2'b11: next_value = {{8{cur[63]}}, cur[63:8]}; // arithmetic shift right 8
                endcase
            end else begin
                next_value = cur;
            end
        end
    endfunction

    // drives one clock edge using the currently-set inputs, then checks q
    // against a reference model that mirrors the expected DUT behavior
    task step;
        begin
            model = next_value(model, load, ena, amount, data);
            @(posedge clk);
            #1;
            if (q !== model) begin
                errors = errors + 1;
                $display("FAIL: load=%b ena=%b amount=%b data=%h q=%h expected=%h",
                          load, ena, amount, data, q, model);
            end
        end
    endtask

    initial begin
        errors = 0;
        load = 0;
        ena = 0;
        amount = 0;
        data = 0;

        // load a known value
        load = 1; data = 64'h0123_4567_89AB_CDEF;
        step;
        load = 0;

        // logical shift left by 1, several times
        ena = 1; amount = 2'b00;
        for (i = 0; i < 5; i = i + 1) step;

        // logical shift left by 8
        amount = 2'b01;
        for (i = 0; i < 3; i = i + 1) step;

        // load a positive value (MSB=0), then arithmetic shift right by 1 and by 8
        ena = 0; load = 1; data = 64'h7FFF_FFFF_FFFF_FFFF;
        step;
        load = 0; ena = 1; amount = 2'b10;
        for (i = 0; i < 5; i = i + 1) step;
        amount = 2'b11;
        for (i = 0; i < 3; i = i + 1) step;

        // load a negative value (MSB=1), check sign extension on arithmetic shifts
        ena = 0; load = 1; data = 64'hFFFF_FFFF_0000_0001;
        step;
        load = 0; ena = 1; amount = 2'b10;
        for (i = 0; i < 5; i = i + 1) step;
        amount = 2'b11;
        for (i = 0; i < 3; i = i + 1) step;

        // neither load nor ena asserted: q must hold its value
        ena = 0;
        for (i = 0; i < 3; i = i + 1) step;

        // load takes priority over ena when both are asserted
        load = 1; ena = 1; amount = 2'b00; data = 64'hDEAD_BEEF_1122_3344;
        step;
        load = 0;

        // randomized stress test
        for (i = 0; i < 500; i = i + 1) begin
            load = $random;
            ena = $random;
            amount = $random;
            data = {$random, $random};
            step;
        end

        if (errors == 0)
            $display("PASSED: all tests passed");
        else
            $display("FAILED: %0d errors found", errors);

        $finish;
    end
endmodule
