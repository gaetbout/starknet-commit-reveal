"""Utilities for testing Cairo contracts."""
#Copied from https://github.com/OpenZeppelin/cairo-contracts/blob/main/tests/utils.py
from pathlib import Path
import math
from starkware.starkware_utils.error_handling import StarkException


def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")



async def assert_revert(fun, reverted_with=None):
    try:
        await fun
        assert False
    except StarkException as err:
        _, error = err.args
        if reverted_with is not None:
            assert reverted_with in error["message"]
