`timescale 1ns / 1ps

// A single delay value is optimistic - real gates have a delay that varies
// with process, voltage, and temperature (PVT). `#(min:typ:max)` instead
// gives the simulator three values per transition and lets you pick, at
// simulation time, which corner to check against:
//   min - best-case (fast process, high voltage, low temp) -> hold checks
//   typ - typical, nominal corner -> everyday functional simulation
//   max - worst-case (slow process, low voltage, high temp) -> setup checks
//
// NOTE: Icarus Verilog always uses the typ value and ignores the selection
// switches below, so run this one in ModelSim to see min/max take effect:
//   python run_modelsim.py VER-09/30-min-typ-max-delay --delay-mode min
//   python run_modelsim.py VER-09/30-min-typ-max-delay --delay-mode typ
//   python run_modelsim.py VER-09/30-min-typ-max-delay --delay-mode max
// (internally this passes vsim the +mindelays / +typdelays / +maxdelays
// switch; with neither switch given, typ is also ModelSim's default).
module M (
    output out,
    input  a,
    b
);
    // rise/fall #(min:typ:max) on a single gate.
    and #(2: 5: 9) a1 (out, a, b);
endmodule

module testbench;
    reg a, b;
    wire out;

    M dut (
        out,
        a,
        b
    );

    always @(out) $display("t=%0t out -> %b", $time, out);

    initial begin
        a = 0;
        b = 0;
        #10;
        $display("t=%0t: a,b -> 1 (expect out @ t+2/+5/+9 depending on delay mode)", $time);
        a = 1;
        b = 1;
        #20;
        $finish;
    end
endmodule
