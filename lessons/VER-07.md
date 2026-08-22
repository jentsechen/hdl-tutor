# VER-07 | Hierarchical & Reusable RTL Design

1. [Introduction](#1-introduction)
2. [Function and Task](#2-function-and-task)
3. [Parameters](#3-parameters)
4. [Conditional Compilation](#4-conditional-compilation)
5. [Useful Simulation System Tasks](#5-useful-simulation-system-tasks)
6. [`force` and `release`](#6-force-and-release)

## 1. Introduction

**Why Reusable RTL?**

As a design becomes larger, repeatedly writing the same logic makes the
code difficult to maintain. Verilog provides several ways to organize and
reuse code:

```
System
│
├── Modules
│   ├── Submodules
│   ├── Functions
│   └── Tasks
│
└── Parameters
```

**Hierarchical Module Design**

- Module definition: Hardware Template
- Module instance: Actual Hardware Block

## 2. Function and Task

### Function

A Verilog function is used to describe a reusable computation that:

- Has at least one input
- Produces exactly one return value
- Executes in zero simulation time
- Cannot contain delay or event-control statements

**Structure**

```verilog
function [WIDTH-1:0] <function_name>;
    input ...;
    begin
        <function_name> = ...;
    end
endfunction
```

The name of the function acts as an implicit return variable. If no return
width is specified, the default function result is only one bit.

**Example: Function with Multiple Inputs**

```verilog
function [7:0] multiply;
    input [3:0] a;
    input [3:0] b;
    begin
        multiply = a * b;
    end
endfunction
```

Invocation: `result = multiply(a, b);`

See
[examples/VER-07/00-function/example.v](../examples/VER-07/00-function/example.v)
for `multiply` called from both a continuous assign and procedural code,
plus a demonstration that a function call never advances simulation time.

### Task

A task is another reusable behavioral construct, but it is more flexible
than a function. A task can:

- Have zero or more inputs
- Have multiple outputs
- Have `input`, `output`, and `inout` arguments
- Contain delays
- Contain event controls
- Invoke another task or function

**Structure**

```verilog
task task_name;
    input ...;
    output ...;
    begin
        // statements
    end
endtask
```

**Example: Multiple Outputs** — suppose we frequently need AND, OR, and XOR
results from the same two operands. See
[examples/VER-07/01-task/example.v](../examples/VER-07/01-task/example.v).

Invocation: `logic_operations(a, b, and_out, or_out, xor_out);`

### Task vs. Function

| Feature | Function | Task |
|---|---|---|
| Input arguments | ≥ 1 | 0 or more |
| Output arguments | No | Yes |
| Return value | Exactly one | No direct return |
| Multiple outputs | No | Yes |
| `#delay` | No | Yes |
| Event control | No | Yes |
| Can call function | Yes | Yes |
| Can call task | No | Yes |
| Simulation time | Zero | May consume time |
| Typical use | Calculation | Procedure / stimulus |

## 3. Parameters

**Definition**: parameters allow one module definition to support several
configurations.

**Example**

```verilog
module counter #(parameter WIDTH = 8) (
    input  clk,
    input  reset,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (reset) q <= 0;
        else q <= q + 1'b1;
    end
endmodule
```

**Override** — two mechanisms:

- Parameter assignment during module instantiation
- `defparam`

See
[examples/VER-07/02-parameter/example.v](../examples/VER-07/02-parameter/example.v)
for both an 8-bit and a 16-bit instance of the same `counter` module, plus a
`defparam` override.

```verilog
// Parameter assignment during instantiation
counter #(.WIDTH(8)) counter8 (
    .clk   (clk),
    .reset (reset),
    .q     (q8)
);

// defparam
defparam counter16.WIDTH = 16;
```

## 4. Conditional Compilation

Sometimes we want some Verilog code to exist only in certain
configurations.

```verilog
`define DEBUG
`ifdef DEBUG
    always @(posedge clk) $display("counter = %d", q);
`endif
```

See
[examples/VER-07/03-conditional-compilation/example.v](../examples/VER-07/03-conditional-compilation/example.v).

## 5. Useful Simulation System Tasks

| syntax | description | example |
|---|---|---|
| `$display` | Print a value immediately | `$display("q = %b", q);` |
| `%m` | Print the current hierarchical scope | `$display("Running in %m");` |
| `$strobe` | Prints after assignments scheduled for the current simulation time have executed | `$strobe("q = %b", q);` |
| `$random` | Generate random test values | `input_data = $random;` |

See the matching examples:
[display](../examples/VER-07/04-display/example.v),
[strobe](../examples/VER-07/05-strobe/example.v),
[random](../examples/VER-07/06-random/example.v).

## 6. `force` and `release`

`force` and `release` can override registers or nets, and are recommended
for stimulus/debugging rather than design blocks.

**Example**

```verilog
initial begin
    #50;
    force dut.q = 1'b1;
    #20;
    release dut.q;
end
```

See
[examples/VER-07/07-force-release/example.v](../examples/VER-07/07-force-release/example.v).
