#!/usr/bin/env python3
"""Compile & simulate one examples/<lesson>/<topic>.v with ModelSim, then open the waveform GUI."""
import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

EXAMPLES_DIR = Path(__file__).parent / "examples"
MODELSIM_FALLBACK_DIR = Path(r"C:\intelFPGA\20.1\modelsim_ase\win32aloem")


def find_tool(name):
    candidate = MODELSIM_FALLBACK_DIR / f"{name}.exe"
    if candidate.exists():
        return str(candidate)
    path = shutil.which(name)
    if path:
        return path
    sys.exit(f"error: could not find '{name}' in {MODELSIM_FALLBACK_DIR} or on PATH")


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
    parser.add_argument("example", nargs="?", help="e.g. VER-07/40-waveform-debugging")
    parser.add_argument("--top", default="testbench", help="top-level module name (default: testbench)")
    parser.add_argument("--no-gui", action="store_true", help="skip launching the waveform GUI")
    args = parser.parse_args()

    example_name = choose_example(args.example)
    example_file = EXAMPLES_DIR / f"{example_name}.v"
    wlf_out = example_file.with_suffix(".wlf")

    vlib = find_tool("vlib")
    vlog = find_tool("vlog")
    vsim = find_tool("vsim")

    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_dir = Path(tmp_dir)

        vlib_cmd = [vlib, "work"]
        print("+", " ".join(vlib_cmd), flush=True)
        subprocess.run(vlib_cmd, cwd=tmp_dir, check=True)

        vlog_cmd = [vlog, str(example_file)]
        print("+", " ".join(vlog_cmd), flush=True)
        subprocess.run(vlog_cmd, cwd=tmp_dir, check=True)

        vsim_cmd = [vsim, "-c", f"work.{args.top}", "-do", "log -r /*; run -all; quit -f"]
        print("+", " ".join(vsim_cmd), flush=True)
        subprocess.run(vsim_cmd, cwd=tmp_dir, check=True)

        produced = tmp_dir / "vsim.wlf"
        if not produced.exists():
            sys.exit(f"error: simulation did not produce {produced}")
        shutil.copy(produced, wlf_out)

    print(f"waveform saved to {wlf_out}")

    if not args.no_gui:
        gui_cmd = [vsim, "-view", str(wlf_out), "-do", "add wave -r /*; wave zoom full"]
        print("+", " ".join(gui_cmd), flush=True)
        subprocess.Popen(gui_cmd)


if __name__ == "__main__":
    main()
