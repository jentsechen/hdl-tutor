`timescale 1ns / 1ps

// A small, purely combinational, technology-independent RTL description -
// deliberately simple so it's a good first module to push through an actual
// synthesis tool. See "9. Synthesis + Gate-Level Simulation Flow" in
// VER-09.md for the Yosys command to synthesize it and the ModelSim
// commands to gate-level-simulate the result against this same stimulus.
//
// `GATELEVEL` is defined (with `+define+GATELEVEL` on the vlog command line)
// only when gate-level-simulating: it excludes this RTL definition so the
// synthesized netlist's `magnitude_comparator` module - compiled from a
// separate file - is the only one, instead of conflicting with this one.
`ifndef GATELEVEL
module magnitude_comparator (
    output A_gt_B,
    A_lt_B,
    A_eq_B,
    input [3:0] A,
    B
);
    assign A_gt_B = (A > B);
    assign A_lt_B = (A < B);
    assign A_eq_B = (A == B);
endmodule
`endif

// `SYNTH` is defined (with `-D SYNTH` on the yosys read_verilog command
// line) only when synthesizing: it excludes this testbench module, since
// Yosys's Verilog frontend elaborates `initial` blocks while reading the
// file and otherwise aborts on the `$finish` below before synthesis passes
// ever run.
`ifndef SYNTH
module testbench;
    reg [3:0] A, B;
    wire A_gt_B, A_lt_B, A_eq_B;

    magnitude_comparator dut (
        A_gt_B,
        A_lt_B,
        A_eq_B,
        A,
        B
    );

    initial begin
        $monitor("t=%0t A=%b B=%b A_gt_B=%b A_lt_B=%b A_eq_B=%b", $time, A, B, A_gt_B, A_lt_B,
                 A_eq_B);

        A = 4'b1010;
        B = 4'b1001;
        #10 A = 4'b1110;
        B = 4'b1111;
        #10 A = 4'b0000;
        B = 4'b0000;
        #10 A = 4'b1000;
        B = 4'b1100;
        #10 A = 4'b0110;
        B = 4'b1110;
        #10 A = 4'b1110;
        B = 4'b1110;
        #10 $finish;
    end
endmodule
`endif
