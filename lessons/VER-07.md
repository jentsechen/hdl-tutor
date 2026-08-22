# VER-07 | Testbench & Integrated RTL Design

1. [DUT and Testbench Structure](#dut-and-testbench-structure)
2. [`initial`](#initial)
3. [Clock and Reset Generation](#clock-and-reset-generation)
4. [Input Stimulus](#input-stimulus)
5. [System Tasks](#system-tasks)
6. [Waveform Debugging](#waveform-debugging)
7. [Design Verification Flow](#design-verification-flow)

## DUT and Testbench Structure

The **DUT** (Design Under Test) is the module being verified - it's never
modified by the testbench itself. A testbench is a separate module that:

1. Declares `reg` to drive the DUT's inputs and `wire`s to observe its
   outputs
2. Instantiates the DUT
3. Uses an `initial` block to apply stimulus and check results
4. Ends the simulation with `$finish`

See
[examples/VER-07/00-dut-and-testbench-structure.v](../examples/VER-07/00-dut-and-testbench-structure.v)
for this skeleton applied to a small adder DUT.

## `initial`

Every `initial` block starts running at time 0. Statements *within* one
block execute in order, but separate `initial` blocks run **concurrently**
and interleave with each other based on their own delays - this is how a
testbench can, for example, generate a clock in one `initial`/`always`
block while applying stimulus in another.

See
[examples/VER-07/01-initial.v](../examples/VER-07/01-initial.v)
for three `initial` blocks interleaving.

## Clock and Reset Generation

**Clock generation** - the standard free-running clock pattern:

```verilog
reg clk;
initial clk = 0;
always #5 clk = ~clk; // 10ns period -> 100MHz
```

See
[examples/VER-07/10-clock-generation.v](../examples/VER-07/10-clock-generation.v).

**Reset generation** - assert reset at the start of simulation, hold it
across a couple of clock edges so the DUT definitely samples it, then
release it so the DUT starts from a known state:

```verilog
initial begin
    reset = 1;
    @(posedge clk);
    @(posedge clk);
    reset = 0;
end
```

See
[examples/VER-07/11-reset-generation.v](../examples/VER-07/11-reset-generation.v).

## Input Stimulus

Rather than writing out every test case by hand, stimulus is often driven
from a small table (or loop) of test vectors applied to the DUT one at a
time.

See
[examples/VER-07/20-input-stimulus.v](../examples/VER-07/20-input-stimulus.v).

## System Tasks

| syntax | description |
|---|---|
| `$display` | Prints its arguments immediately, once - like `printf`. |
| `$monitor` | Set up once; automatically re-prints whenever any of its listed variables changes value. Only plain signals can be passed to it (not expressions) - assign an expression to a wire first if you need one. |
| `$strobe` | Like `$display`, but prints only after every statement scheduled for the current simulation time has executed - so it always shows the final, settled value instead of a possibly-stale one. |
| `$finish` | Stops the simulator immediately, wherever it's called. Without it, a testbench with a free-running clock would simulate forever. |

See
[examples/VER-07/30-system-tasks.v](../examples/VER-07/30-system-tasks.v)
for all four together: a one-off `$display`, a `$display`/`$strobe` pair
showing the stale-vs-settled value difference at the same simulation time,
a `$monitor` that keeps re-printing as values change, and `$finish` cutting
off a free-running clock that would otherwise never stop.

## Waveform Debugging

`$dumpfile`/`$dumpvars` record every signal change to a `.vcd` file that a
waveform viewer can open, so you can visually step through signal
transitions instead of reading `$display` text:

```verilog
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, testbench); // 0 = dump this scope and everything below it
end
```

See
[examples/VER-07/40-waveform-debugging.v](../examples/VER-07/40-waveform-debugging.v).
Running it produces `waveform.vcd` in your current directory; open it with
GTKWave (bundled alongside Icarus Verilog at
`C:\iverilog\gtkwave\bin\gtkwave.exe`).

## Design Verification Flow

1. Design the DUT
2. Write a testbench around it
3. Generate clock/reset and apply input stimulus
4. Observe the DUT's outputs and compare them against expected behavior
5. If something's wrong, debug using `$display`/`$monitor` text output or a
   waveform viewer
6. Fix the DUT (or the testbench) and repeat from step 3
