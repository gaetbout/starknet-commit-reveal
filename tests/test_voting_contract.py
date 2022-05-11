"""contract.cairo test file."""
import os
import pytest
from starkware.starknet.testing.starknet import Starknet
from utils import (str_to_felt)

CONTRACT_FILE = os.path.join("contracts", "voting_contract.cairo")
SALT = 42
STR_TO_HASH = 'lama'
STR_AS_FELT = str_to_felt(STR_TO_HASH)
# Value got from running view_get_keccak_hash on the SALT and STR_AS_FELT 
HASHED_VALUE=(143675897352951598121481950682655164173, 154398317978373570478440553082667491100)

pytest.caller_address = 100

@pytest.fixture(scope="session")
async def contract():
    starknet = await Starknet.empty()
    return await starknet.deploy(source=CONTRACT_FILE,)

@pytest.fixture
async def caller_address():
    pytest.caller_address += 1
    return pytest.caller_address


@pytest.mark.asyncio
async def test_view_get_keccak_hash(contract):
    execution_info = await contract.view_get_keccak_hash(salt=SALT, value_to_hash=STR_AS_FELT).invoke()
    assert execution_info.result.hashed_value == HASHED_VALUE

@pytest.mark.asyncio
async def test_commit_hash(contract, caller_address):
    await contract.commit_hash(HASHED_VALUE).invoke(caller_address)
    execution_info = await contract.view_get_hash_for(caller_address).call()
    assert execution_info.result.hashed_response == HASHED_VALUE
    
@pytest.mark.asyncio
async def test_view_get_hash_for_nothing_committed(contract, caller_address):
    execution_info = await contract.view_get_hash_for(caller_address).call()
    assert execution_info.result.hashed_response == (0,0)
    

@pytest.mark.asyncio
async def test_reveal_with_nothing_committed(contract, caller_address):
    with pytest.raises(Exception) as execution_info:
        await contract.reveal(1,1).invoke()
    assert "You should first commit something" in execution_info.value.args[1]["message"]
    

@pytest.mark.asyncio
async def test_reveal(contract, caller_address):
    execution_info = await contract.view_get_vote_per_response(STR_AS_FELT).invoke()
    assert execution_info.result.number_of_vote == 0
    await contract.commit_hash(HASHED_VALUE).invoke(caller_address)
    execution_info = await contract.view_get_vote_per_response(STR_AS_FELT).invoke()
    assert execution_info.result.number_of_vote == 0
    await contract.reveal(SALT, STR_AS_FELT).invoke(caller_address)
    execution_info = await contract.view_get_vote_per_response(STR_AS_FELT).invoke()
    assert execution_info.result.number_of_vote == 1

@pytest.mark.asyncio
async def test_reveal_value_reset(contract, caller_address):
    await contract.commit_hash(HASHED_VALUE).invoke(caller_address)
    await contract.reveal(SALT, STR_AS_FELT).invoke(caller_address)
    execution_info = await contract.view_get_hash_for(caller_address).call()
    assert execution_info.result.hashed_response == (0,0)

@pytest.mark.asyncio
async def test_reveal_Cheating(contract, caller_address):
    await contract.commit_hash(HASHED_VALUE).invoke(caller_address)
    with pytest.raises(Exception) as execution_info:
        await contract.reveal(SALT-1, STR_AS_FELT).invoke(caller_address)
    assert "You are trying to cheat" in execution_info.value.args[1]["message"]
    