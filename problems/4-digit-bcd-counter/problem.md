# 4-digit BCD Counter

Build a 4-digit BCD (binary-coded decimal) counter. Each decimal digit is
encoded using 4 bits: `q[3:0]` is the ones digit, `q[7:4]` is the tens digit,
etc. For digits `[3:1]`, also output an enable signal indicating when each
of the upper three digits should be incremented.

The counter has a synchronous active-high reset that sets `q` back to
`16'h0000`. On each clock cycle, the ones digit always increments (wrapping
from 9 back to 0), and each of the tens/hundreds/thousands digits
increments only when every digit below it is about to wrap — i.e. `ena[1]`
is asserted when the ones digit is 9, `ena[2]` is asserted when the ones and
tens digits are both 9, and `ena[3]` is asserted when the ones, tens, and
hundreds digits are all 9.
