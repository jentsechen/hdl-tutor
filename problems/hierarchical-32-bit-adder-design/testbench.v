`timescale 1ns/1ps

// solution.v's top_module instantiates add16, which is not defined
// anywhere in this problem's files. Providing a standard ripple-carry
// implementation here so the design can be simulated standalone.
module add1(input a, input b, input cin, output sum, output cout);
    assign {cout, sum} = a + b + cin;
endmodule

module add16(input [15:0] a, input [15:0] b, input cin, output [15:0] sum, output cout);
    wire [16:0] carry;
    assign carry[0] = cin;
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_bit
            add1 u_add1(.a(a[i]), .b(b[i]), .cin(carry[i]), .sum(sum[i]), .cout(carry[i+1]));
        end
    endgenerate
    assign cout = carry[16];
endmodule

module testbench;
    reg  [31:0] a, b;
    wire [31:0] sum;
    integer i;
    integer errors;

    top_module dut(.a(a), .b(b), .sum(sum));

    task check;
        begin
            #1;
            if (sum !== (a + b)) begin
                errors = errors + 1;
                $display("FAIL: a=%h b=%h sum=%h expected=%h", a, b, sum, a + b);
            end
        end
    endtask

    initial begin
        errors = 0;

        // Basic cases
        a = 32'h0000_0000; b = 32'h0000_0000; check;
        a = 32'h0000_0001; b = 32'h0000_0001; check;
        a = 32'hFFFF_FFFF; b = 32'h0000_0001; check; // wraps around (overflow)
        a = 32'hFFFF_FFFF; b = 32'hFFFF_FFFF; check;

        // Carry propagation across the 16-bit boundary between add16 instances
        a = 32'h0000_FFFF; b = 32'h0000_0001; check;
        a = 32'h0001_FFFF; b = 32'h0000_0001; check;
        a = 32'h0000_FFFF; b = 32'h0000_FFFF; check;

        // Alternating bit patterns
        a = 32'hAAAA_AAAA; b = 32'h5555_5555; check;
        a = 32'h5555_5555; b = 32'hAAAA_AAAA; check;

        // Random tests
        for (i = 0; i < 1000; i = i + 1) begin
            a = $random;
            b = $random;
            check;
        end

        if (errors == 0)
            $display("PASSED: all tests passed");
        else
            $display("FAILED: %0d errors found", errors);

        $finish;
    end
endmodule
