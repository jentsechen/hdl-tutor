`timescale 1ns / 1ps

// Demonstrates the two simplest delay models for the same logic function
// out = (a & b) & (c & d):
//   - distributed: a delay value on each gate (per-element)
//   - lumped:      the cumulative worst-case delay moved onto the one
//                   output gate (per-module)
// Both models agree on the worst-case delay (5+4 = 7+4 = 11), but only the
// distributed model reacts faster when just one half of the logic changes.
module distributed (
    output out,
    input  a,
    b,
    c,
    d
);
    wire e, f;
    and #5 a1 (e, a, b);
    and #7 a2 (f, c, d);
    and #4 a3 (out, e, f);
endmodule

module lumped (
    output out,
    input  a,
    b,
    c,
    d
);
    wire e, f;
    and a1 (e, a, b);
    and a2 (f, c, d);
    and #11 a3 (out, e, f);  // delay of the whole module lumped onto one gate
endmodule

module testbench;
    reg a, b, c, d;
    wire out_dist, out_lump;

    distributed m1 (
        out_dist,
        a,
        b,
        c,
        d
    );
    lumped m2 (
        out_lump,
        a,
        b,
        c,
        d
    );

    always @(out_dist) $display("t=%0t distributed out -> %b", $time, out_dist);
    always @(out_lump) $display("t=%0t lumped      out -> %b", $time, out_lump);

    initial begin
        // c, d are already 1, so only the a-b path (5+4 = 9ns) is exercised.
        a = 0;
        b = 0;
        c = 1;
        d = 1;
        #10;
        $display("t=%0t: a,b -> 1 (c,d already settled)", $time);
        a = 1;
        b = 1;

        #30;
        $finish;
    end
endmodule
