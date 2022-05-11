# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.cairo_keccak.keccak import keccak_felts, finalize_keccak
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bool import TRUE, FALSE

@storage_var
func caller_address_hash_storage(address : felt) -> (hashed_response : Uint256):
end

@storage_var
func vote_per_response_storage(name : felt) -> (number_of_vote : felt):
end

@view
func view_get_keccak_hash{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(salt : felt, value_to_hash : felt) -> (hashed_value : Uint256):
    alloc_locals
    let (local keccak_ptr_start) = alloc()
    let keccak_ptr = keccak_ptr_start
    let (local arr : felt*) = alloc()
    assert arr[0] = salt
    assert arr[1] = value_to_hash
    let (hashed_value) = keccak_felts{keccak_ptr=keccak_ptr}(2, arr)
    finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr)
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
func reveal{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(number : felt, response : felt):
    alloc_locals
    let (caller_address) = get_caller_address()
    let (committed_hash) = caller_address_hash_storage.read(caller_address)
    let (is_eq_to_zero) = uint256_eq(committed_hash, Uint256(0, 0))
    with_attr error_message("You should first commit something"):
        assert is_eq_to_zero = FALSE
    end
    let (current_hash) = view_get_keccak_hash(number, response)
    let (is_eq) = uint256_eq(current_hash, committed_hash)
    with_attr error_message("You are trying to cheat"):
        assert is_eq = TRUE
    end
    caller_address_hash_storage.write(caller_address, Uint256(0, 0))
    let (current_number_of_vote) = vote_per_response_storage.read(response)
    vote_per_response_storage.write(response, current_number_of_vote + 1)
    return ()
end
