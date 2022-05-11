"""contract.cairo test file."""
import os
import asyncio
import pytest
from starkware.starknet.testing.starknet import Starknet
from utils import (str_to_felt)

CONTRACT_FILE = os.path.join("contracts", "voting_contract.cairo")

'''Fix asyncio crash'''
@pytest.fixture(scope="session")
def event_loop():
    return asyncio.get_event_loop()


@pytest.fixture(scope="session")
async def contract():
    starknet = await Starknet.empty()
    return await starknet.deploy(source=CONTRACT_FILE,)


@pytest.mark.asyncio
async def test_default_flow(contract):
    lama_as_felt = str_to_felt('lama')
    execution_info = await contract.view_get_keccak_hash(random_number=42, value_to_hash=lama_as_felt).invoke()
    assert execution_info.result.hashed_value == 0



