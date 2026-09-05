`timescale 1ns / 1ps

// $setup / $hold / $width: system tasks that check timing constraints
// during simulation, declared inside a `specify` block.
//
// Same caveat as 10-path-delay-specify.v: Icarus Verilog does not evaluate
// these checks, so run this one in ModelSim with path delays enabled:
//   python run_modelsim.py VER-09/20-timing-checks --specify
// ModelSim will print a "$setup(...)" violation around t=10, because d
// changes only 2ns before the clock edge but the required setup time is 3ns.
module dff (
    output reg q,
    input      d,
    clk
);
    // Timing-check violations toggle this reg; without a real testbench
    // checker task, we just let ModelSim's own violation message report it.
    reg notifier;

    specify
        // Violation if (posedge clk time) - (d change time) < 3
        $setup(d, posedge clk, 3, notifier);
        // Violation if (d change time) - (posedge clk time) < 2
        $hold(posedge clk, d, 2, notifier);
        // Violation if clk does not stay high for at least 4ns
        $width(posedge clk, 4);
    endspecify

    always @(posedge clk) q <= d;
endmodule

module testbench;
    reg d, clk;
    wire q;

    dff dut (
        q,
        d,
        clk
    );

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        d = 0;
        #8 d = 1;  // changes at t=8, only 2ns before the t=10 clock edge
        #3 d = 0;  // changes at t=11, only 1ns after the t=10 clock edge
        #30;
        $finish;
    end
endmodule
