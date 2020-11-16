#!/usr/bin/env python3

"""Under the same directory as "fish_variable" (~/.config/fish)"""

from subprocess import run
from pathlib import Path

START_LINE = 13
END_LINE = 41


parent_dir = Path(__file__).parent
with open(parent_dir / "fish_variables") as file, open(parent_dir / "outfile.txt", "w") as outfile:
	for _ in range(START_LINE - 1):
		file.readline()

	for _ in range(END_LINE - START_LINE):
		line: str = file.readline()
		start_i = line.index(" ") + 1
		end_i = line.index(":")

		var_name = line[start_i: end_i]

		value = run(["fish", "-c", "echo $" + var_name], text=True, capture_output=True)
		print("set --universal", var_name, "'" + value.stdout[:-1] + "'", file=outfile)

