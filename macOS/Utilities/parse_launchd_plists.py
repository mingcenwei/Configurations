#!/usr/bin/env python3

"""Used to get "ProgramArguments" from plists"""

from sys import argv
import xml.etree.ElementTree as ET

# Parse the XML document
tree = ET.parse(argv[1])
root = tree.getroot()

# Set to "Ture" if a node's tag is "key" and text is "ProgramArguments"
is_target: bool = False
# If the value of the key "ProgramArguments" is an array,
# this variable will be used to count the number of the remaining string values
count: int = 0
for node in root.iter():
    if count != 0:
        print(node.text)
        count -= 1
        continue
    elif is_target:
        is_target = False
        if node.tag == "array":
            count = len(tuple(node.iter())) - 1
            continue
        elif node.tag == "string":
            print(node.text)
            continue
        else:
            raise Exception("syntax error")
    elif node.tag == "key" and node.text == "ProgramArguments":
        is_target = True
        continue
    else:
        continue
