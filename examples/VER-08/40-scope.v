`timescale 1ns/1ps

module leaf;
    initial $display("Running in %m");
endmodule

module example;
    leaf leaf_a ();
    leaf leaf_b ();

    initial begin
        #1 $finish;
    end
endmodule
