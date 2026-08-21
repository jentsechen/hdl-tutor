module top_module (
    input  clk,
    input  reset,
    input  in,
    output disc,
    output flag,
    output err
);

  localparam [3:0] CNT0 = 4'd0, CNT1 = 4'd1, CNT2 = 4'd2, CNT3 = 4'd3;
  localparam [3:0] CNT4 = 4'd4, CNT5 = 4'd5, CNT6 = 4'd6;
  localparam [3:0] DISC = 4'd7, FLAG = 4'd8, ERR = 4'd9;

  reg [3:0] state, next_state;

  always @(posedge clk) begin
    if (reset) state <= CNT0;
    else state <= next_state;
  end

  always @* begin
    case (state)
      CNT0: next_state = in ? CNT1 : CNT0;
      CNT1: next_state = in ? CNT2 : CNT0;
      CNT2: next_state = in ? CNT3 : CNT0;
      CNT3: next_state = in ? CNT4 : CNT0;
      CNT4: next_state = in ? CNT5 : CNT0;
      CNT5: next_state = in ? CNT6 : DISC;
      CNT6: next_state = in ? ERR : FLAG;
      ERR: next_state = in ? ERR : CNT0;
      DISC: next_state = in ? CNT1 : CNT0;
      FLAG: next_state = in ? CNT1 : CNT0;
      default: next_state = CNT0;
    endcase
  end

  assign disc = (state == DISC);
  assign flag = (state == FLAG);
  assign err  = (state == ERR);

endmodule
