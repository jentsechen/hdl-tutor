`timescale 1ns / 1ps

// Pin-to-pin (path) delays, assigned inside a `specify`/`endspecify` block
// instead of on individual gates. The module's internal gates all have zero
// delay - the specify block is the only source of timing here.
//
// NOTE: this only works as intended in a simulator that actually evaluates
// specify-block path delays. Icarus Verilog parses the syntax but does not
// apply it, so running this with `run_example.py` will show `out` changing
// with (near) zero delay. Run it in ModelSim instead, with path delays
// enabled:
//   python run_modelsim.py VER-09/10-path-delay-specify --specify
// There you should see the a/b path settle at t=19 (10 + fast) and the c/d
// path settle at t=91 (80 + slow).
module M (
    output out,
    input  a,
    b,
    c,
    d
);
    wire e, f;

    specify
        // specparam: named constants for use only inside this specify block
        specparam fast = 9, slow = 11;

        // Parallel connection (=>): each source bit drives the delay of the
        // matching destination bit. Here out is scalar, so this is just a
        // plain source -> destination path delay.
        (a => out) = fast;
        (b => out) = fast;
        (c => out) = slow;
        (d => out) = slow;

        // A full connection (*>) would instead say every bit of the source
        // field drives every bit of the destination field, e.g.:
        //   (a, b *> out) = fast;
    endspecify

    and a1 (e, a, b);
    and a2 (f, c, d);
    and a3 (out, e, f);
endmodule

module testbench;
    reg a, b, c, d;
    wire out;

    M dut (
        out,
        a,
        b,
        c,
        d
    );

    always @(out) $display("t=%0t out -> %b", $time, out);

    initial begin
        // Stage 1: exercise the fast path - only a, b move; c, d stay at 1
        // the whole time, so f (and its contribution to out) never changes.
        a = 0;
        b = 0;
        c = 1;
        d = 1;
        #10;
        $display("t=%0t: a,b -> 1 (fast path, expect out @ t+9)", $time);
        a = 1;
        b = 1;
        #30;

        // Let everything settle back to 0 before stage 2 (don't-care timing).
        a = 0;
        b = 0;
        c = 0;
        d = 0;
        #30;

        // Stage 2: exercise the slow path - a, b settle at 1 first (so e
        // stays constant), then only c, d move.
        a = 1;
        b = 1;
        #10;
        $display("t=%0t: c,d -> 1 (slow path, expect out @ t+11)", $time);
        c = 1;
        d = 1;
        #30;

        $finish;
    end
endmodule
