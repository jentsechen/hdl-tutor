# hdl-tutor

Verilog practice problems, each graded by a testbench run through [Icarus Verilog](http://iverilog.icarus.com/).

## Layout

Each problem lives under `problems/<problem-name>/` and contains:

- `problem.md` — problem description
- `template.v` — starter skeleton to practice on
- `solution.v` — reference solution
- `testbench.v` — checks a module named `top_module` against expected behavior

`problems/` is reference-only and never modified by the script. Your working
copy is written to `workspace/top_module.v` instead. There's only ever one
file in `workspace/` — the one you're currently practicing on.

## Prerequisites

- Python 3
- Icarus Verilog (`iverilog` / `vvp`)

If Icarus Verilog isn't on your `PATH`, install it with:

```powershell
winget install --id Icarus.Verilog -e
```

`run_testbench.py` also falls back to `C:\iverilog\bin` automatically if the
tools aren't found on `PATH`.

## Usage

The script has two steps, run separately:

```powershell
# 1. copy template.v or solution.v into workspace/top_module.v
python run_testbench.py copy

# 2. compile & simulate workspace/top_module.v against a problem's testbench.v
python run_testbench.py run
```

With no arguments, each step interactively asks you to pick a problem from
`problems/` (and `copy` also asks for `template.v` vs `solution.v`).

You can skip the prompts by passing arguments directly:

```powershell
python run_testbench.py copy hierarchical-32-bit-adder-design --source template
python run_testbench.py copy hierarchical-32-bit-adder-design --source solution
python run_testbench.py run hierarchical-32-bit-adder-design
```

Typical workflow while practicing:

1. `python run_testbench.py copy <problem-name> --source template`
2. Edit `workspace/top_module.v` and write your answer.
3. `python run_testbench.py run <problem-name>`
4. Repeat 2–3 until the testbench reports `PASSED`.

`copy` always overwrites `workspace/top_module.v` with the chosen source, so
only run it again once you actually want to discard your current progress
(e.g. starting a different problem, or resetting from `template.v`).

`workspace/` is git-ignored.
