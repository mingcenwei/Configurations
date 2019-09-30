#!/usr/bin/env python3

"""Used to get client-side host configurations from ~/.ssh/config"""

from sys import argv
from pathlib import Path

DELIMITER = argv[1]

with open(Path.home() / ".ssh/config") as config_file:
    in_wildcard_block: bool = False
    for line in config_file:
        if ((line.lstrip())[0: 5].strip()).lower() == "Host".lower():
            host = (line.lstrip())[5: ].strip()
            if host == "*":
                in_wildcard_block = True
                continue
            else:
                in_wildcard_block = False
                print(DELIMITER)
                print(line, end="")
                continue
        elif in_wildcard_block:
            continue
        elif line.strip() == "":
            continue
        else:
            print(line, end="")
