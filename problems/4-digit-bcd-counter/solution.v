module top_module (
    input clk,
    input reset,
    output [3:1] ena,
    output reg [15:0] q
);
  assign ena[1] = q[3:0] == 4'd9;
  assign ena[2] = ena[1] && q[7:4] == 4'd9;
  assign ena[3] = ena[2] && q[11:8] == 4'd9;
  always @(posedge clk) begin
    if (reset) q <= 16'd0;
    else begin
      q[3:0] <= (q[3:0] == 4'd9) ? 4'd0 : q[3:0] + 4'd1;
      if (ena[1]) q[7:4] <= (q[7:4] == 4'd9) ? 4'd0 : q[7:4] + 4'd1;
      if (ena[2]) q[11:8] <= (q[11:8] == 4'd9) ? 4'd0 : q[11:8] + 4'd1;
      if (ena[3]) q[15:12] <= (q[15:12] == 4'd9) ? 4'd0 : q[15:12] + 4'd1;
    end
  end
endmodule
