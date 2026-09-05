`timescale 1ns / 1ps

// A classic synthesizable-RTL pitfall: an incomplete `if` (or incomplete
// sensitivity list) infers a level-sensitive LATCH instead of the intended
// multiplexer, because the synthesis tool must remember `out`'s old value
// for the case that isn't covered. Unlike most synthesis-only style
// concerns, this one is visible in simulation too - not just in the
// gate-level netlist.
module bad_latch (
    output reg out,
    input      control,
    a,
    b
);
    // No `else` branch: when control == 0, out is not assigned anything,
    // so it must hold its previous value -> a latch.
    always @(control or a) if (control) out = a;
endmodule

module good_mux (
    output reg out,
    input      control,
    a,
    b
);
    // Every branch assigns out, and the sensitivity list covers every
    // signal read -> a clean combinational multiplexer.
    always @(control or a or b)
        if (control) out = a;
        else out = b;
endmodule

// `SYNTH` is defined (with `-D SYNTH` on the yosys read_verilog command line)
// only when synthesizing: it excludes this testbench module, since Yosys's
// Verilog frontend elaborates `initial` blocks while reading the file and
// otherwise aborts on the `$finish` below before synthesis passes ever run.
`ifndef SYNTH
module testbench;
    reg control, a, b;
    wire out_latch, out_mux;

    bad_latch dut1 (
        out_latch,
        control,
        a,
        b
    );
    good_mux dut2 (
        out_mux,
        control,
        a,
        b
    );

    initial begin
        $monitor("t=%0t control=%b a=%b b=%b | out_latch=%b out_mux=%b", $time, control, a, b,
                 out_latch, out_mux);

        a = 1;
        b = 0;
        control = 1;
        #10;

        control = 0;  // out_mux should follow b (0); out_latch should freeze at its last value (1)
        #10;

        b = 1;  // out_mux follows b again; out_latch is still stuck
        #10;

        $finish;
    end
endmodule
`endif
