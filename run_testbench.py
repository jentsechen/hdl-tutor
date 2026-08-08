#!/usr/bin/env python3
"""Two-step workflow to practice a problem with Icarus Verilog:
  1. copy - copy template.v or solution.v into workspace/top_module.v
  2. run  - compile & simulate workspace/top_module.v against a problem's testbench.v
"""
import argparse
import shutil
import subprocess
import sys
from pathlib import Path

PROBLEMS_DIR = Path(__file__).parent / "problems"
WORKSPACE_DIR = Path(__file__).parent / "workspace"
TOP_MODULE = WORKSPACE_DIR / "top_module.v"
IVERILOG_FALLBACK_DIR = Path(r"C:\iverilog\bin")


def find_tool(name):
    path = shutil.which(name)
    if path:
        return path
    candidate = IVERILOG_FALLBACK_DIR / f"{name}.exe"
    if candidate.exists():
        return str(candidate)
    sys.exit(f"error: could not find '{name}' on PATH or in {IVERILOG_FALLBACK_DIR}")


def list_problems():
    return sorted(
        p.name for p in PROBLEMS_DIR.iterdir()
        if p.is_dir() and not p.name.startswith("_") and (p / "testbench.v").exists()
    )


def choose_problem(name):
    problems = list_problems()
    if not problems:
        sys.exit(f"error: no problems found under {PROBLEMS_DIR}")
    if name:
        if name not in problems:
            sys.exit(f"error: unknown problem '{name}'. available: {', '.join(problems)}")
        return name
    print("Available problems:")
    for i, p in enumerate(problems, 1):
        print(f"  {i}. {p}")
    choice = input(f"Select a problem [1-{len(problems)}]: ").strip()
    try:
        return problems[int(choice) - 1]
    except (ValueError, IndexError):
        sys.exit("error: invalid selection")


def choose_source(source):
    if source:
        return source
    choice = input("Use [t]emplate.v (practice) or [s]olution.v? [t/s]: ").strip().lower()
    if choice in ("t", "template"):
        return "template"
    if choice in ("s", "solution"):
        return "solution"
    sys.exit("error: invalid selection")


def choose_action(action):
    if action:
        return action
    choice = input("[c]opy template/solution, or [r]un testbench? [c/r]: ").strip().lower()
    if choice in ("c", "copy"):
        return "copy"
    if choice in ("r", "run"):
        return "run"
    sys.exit("error: invalid selection")


def do_copy(problem, source):
    problem_name = choose_problem(problem)
    source_name = choose_source(source)
    source_file = PROBLEMS_DIR / problem_name / f"{source_name}.v"
    if not source_file.exists():
        sys.exit(f"error: {source_file} not found")

    WORKSPACE_DIR.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source_file, TOP_MODULE)
    print(f"copied {source_file} -> {TOP_MODULE}")


def do_run(problem):
    problem_name = choose_problem(problem)
    testbench = PROBLEMS_DIR / problem_name / "testbench.v"
    if not testbench.exists():
        sys.exit(f"error: {testbench} not found")
    if not TOP_MODULE.exists():
        sys.exit(f"error: {TOP_MODULE} not found - run the 'copy' step first")

    iverilog = find_tool("iverilog")
    vvp = find_tool("vvp")

    sim_out = WORKSPACE_DIR / "sim.vvp"
    compile_cmd = [iverilog, "-o", str(sim_out), str(TOP_MODULE), str(testbench)]
    print("+", " ".join(compile_cmd), flush=True)
    subprocess.run(compile_cmd, check=True)

    run_cmd = [vvp, str(sim_out)]
    print("+", " ".join(run_cmd), flush=True)
    result = subprocess.run(run_cmd)

    sim_out.unlink(missing_ok=True)
    sys.exit(result.returncode)


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    sub = parser.add_subparsers(dest="action")

    copy_p = sub.add_parser("copy", help="copy template.v or solution.v into workspace/top_module.v")
    copy_p.add_argument("problem", nargs="?", help="problem folder name under problems/")
    copy_p.add_argument("-s", "--source", choices=["template", "solution"])

    run_p = sub.add_parser("run", help="compile & simulate workspace/top_module.v against a problem's testbench.v")
    run_p.add_argument("problem", nargs="?", help="problem folder name under problems/")

    args = parser.parse_args()

    action = choose_action(args.action)
    if action == "copy":
        do_copy(getattr(args, "problem", None), getattr(args, "source", None))
    else:
        do_run(getattr(args, "problem", None))


if __name__ == "__main__":
    main()
