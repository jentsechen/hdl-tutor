#!/usr/bin/env python3
"""Compile & run one examples/<lesson>/<topic>.v with Icarus Verilog."""
import argparse
import subprocess
import sys
import shutil
import tempfile
from pathlib import Path

EXAMPLES_DIR = Path(__file__).parent / "examples"
IVERILOG_FALLBACK_DIR = Path(r"C:\iverilog\bin")


def find_tool(name):
    path = shutil.which(name)
    if path:
        return path
    candidate = IVERILOG_FALLBACK_DIR / f"{name}.exe"
    if candidate.exists():
        return str(candidate)
    sys.exit(f"error: could not find '{name}' on PATH or in {IVERILOG_FALLBACK_DIR}")


def list_examples():
    return sorted(
        str(p.relative_to(EXAMPLES_DIR).with_suffix("")).replace("\\", "/")
        for p in EXAMPLES_DIR.glob("*/*.v")
    )


def choose_example(name):
    examples = list_examples()
    if not examples:
        sys.exit(f"error: no examples found under {EXAMPLES_DIR}")
    if name:
        if name not in examples:
            sys.exit(f"error: unknown example '{name}'. available: {', '.join(examples)}")
        return name
    print("Available examples:")
    for i, e in enumerate(examples, 1):
        print(f"  {i}. {e}")
    choice = input(f"Select an example [1-{len(examples)}]: ").strip()
    try:
        return examples[int(choice) - 1]
    except (ValueError, IndexError):
        sys.exit("error: invalid selection")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("example", nargs="?", help="e.g. VER-07/00-function")
    args = parser.parse_args()

    example_name = choose_example(args.example)
    example_file = EXAMPLES_DIR / f"{example_name}.v"

    iverilog = find_tool("iverilog")
    vvp = find_tool("vvp")

    with tempfile.TemporaryDirectory() as tmp_dir:
        sim_out = Path(tmp_dir) / "sim.vvp"
        compile_cmd = [iverilog, "-o", str(sim_out), str(example_file)]
        print("+", " ".join(compile_cmd), flush=True)
        subprocess.run(compile_cmd, check=True)

        run_cmd = [vvp, str(sim_out)]
        print("+", " ".join(run_cmd), flush=True)
        result = subprocess.run(run_cmd)

    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
