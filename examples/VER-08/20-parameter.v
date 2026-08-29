`timescale 1ns / 1ps

module counter #(
    parameter WIDTH = 2
) (
    input clk,
    input reset,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (reset) q <= 0;
        else q <= q + 1'b1;
    end
endmodule

module example;
    reg clk, reset;
    wire [1:0] q2;
    wire [2:0] q3;

    // Parameter assignment during module instantiation
    counter #() counter2 (
        .clk  (clk),
        .reset(reset),
        .q    (q2)
    );

    // Same module, different WIDTH
    counter #(
        .WIDTH(16)
    ) counter3 (
        .clk  (clk),
        .reset(reset),
        .q    (q3)
    );

    // Instantiated with the default WIDTH, then overridden via defparam
    // (an alternative to the instance-time #(...) override above)
    wire [3:0] q1;
    counter counter_defparam (
        .clk  (clk),
        .reset(reset),
        .q    (q1)
    );
    defparam counter_defparam.WIDTH = 1;

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        @(posedge clk);
        #1 reset = 0;

        repeat (8) begin
            #1 $display("q2=%0d q3=%0d q1(defparam)=%0d", q2, q3, q1);
            @(posedge clk);
        end

        $finish;
    end
endmodule
