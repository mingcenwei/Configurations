#!/usr/bin/env python3

"""Used to get server sshd configuration from /etc/ssh/sshd_config"""

from sys import argv

DELIMITER = argv[1]

with open("/etc/ssh/sshd_config") as config_file:
    in_match_block: bool = False
    for line in config_file:
        if not in_match_block:
            if ((line.lstrip())[0: 5].strip()).lower() == "Port".lower():
                ports = (line.lstrip())[5: ].split()
                for port in ports:
                    print(port)
                continue
            elif ((line.lstrip())[0: 6].strip()).lower() == "Match".lower():
                in_match_block = True
                print(DELIMITER)
                print(line, end="")
                continue
            else:
                continue
        else:
            if ((line.lstrip())[0: 6].strip()).lower() == "Match".lower():
                host = line[6: ].strip()
                print(DELIMITER)
                print(line, end="")
                continue
            elif line.strip() == "":
                continue
            else:
                print(line, end="")
