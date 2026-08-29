`timescale 1ns/1ps

module testbench;
    reg [7:0] input_data;
    integer i;

    initial begin
        for (i = 0; i < 5; i = i + 1) begin
            input_data = $random;
            $display("input_data = %0d (%b)", input_data, input_data);
        end

        $finish;
    end
endmodule
