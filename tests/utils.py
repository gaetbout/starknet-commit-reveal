"""Utilities for testing Cairo contracts."""
#Copied from https://github.com/OpenZeppelin/cairo-contracts/blob/main/tests/utils.py
from pathlib import Path
import math


def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")