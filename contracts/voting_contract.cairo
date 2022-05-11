# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.cairo_keccak.keccak import keccak_felts
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.starknet.common.syscalls import get_caller_address

@storage_var
func caller_address_hash_storage(address : felt) -> (hashed_response : Uint256):
end

@storage_var
func vote_per_response_storage(name : felt) -> (number_of_vote : felt):
end

@view
func view_get_keccak_hash{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    random_number : felt, value_to_hash : felt
) -> (hashed_value : Uint256):
    alloc_locals

    let (local bitwise_ptr : BitwiseBuiltin*) = alloc()
    let (local keccak_ptr : felt*) = alloc()
    let (local arr : felt*) = alloc()
    assert arr[0] = random_number  # salt
    assert arr[1] = value_to_hash  # actual value
    let (hashed_value) = keccak_felts{bitwise_ptr=bitwise_ptr, keccak_ptr=keccak_ptr}(2, arr)
    return (hashed_value)
end

@view
func view_get_vote_per_response{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    response : felt
) -> (number_of_vote : felt):
    let (current_number_of_vote) = vote_per_response_storage.read(response)
    return (current_number_of_vote)
end

@view
func view_get_hash_for{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (hashed_response : Uint256):
    let (hashed_response) = caller_address_hash_storage.read(address)
    return (hashed_response)
end

@external
func commit_hash{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(hash : Uint256):
    let (caller_address) = get_caller_address()
    caller_address_hash_storage.write(caller_address, hash)
    return ()
end

@external
func reveal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    number : felt, response : felt
):
    alloc_locals
    let (caller_address) = get_caller_address()
    let (committed_hash) = caller_address_hash_storage.read(caller_address)
    let (current_hash) = view_get_keccak_hash(number, response)
    let (is_eq) = uint256_eq(current_hash, committed_hash)
    assert is_eq = 1
    let (current_number_of_vote) = vote_per_response_storage.read(response)
    vote_per_response_storage.write(response, current_number_of_vote + 1)
    return ()
end
