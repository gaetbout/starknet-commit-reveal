#[contract]
mod VotingContract {

    use starknet::get_caller_address;
    struct Storage {
        caller_address_hash: LegacyMap::<felt, u256>,
        vote_per_response: LegacyMap::<felt, felt>,
    }
    
    
#[view]
fn hash(salt: felt, value_to_hash: felt) -> u256 {
    // let (local keccak_ptr_start) = alloc();
    // let keccak_ptr = keccak_ptr_start;
    // let (local arr: felt*) = alloc();
    // assert arr[0] = salt;
    // assert arr[1] = value_to_hash;
    // let (hashed_value) = keccak_felts{keccak_ptr=keccak_ptr}(2, arr);
    // finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr);
    // return (hashed_value,);
}

#[view]
fn get_vote_per_response(
    response: felt
) -> felt  {vote_per_response::read(response);
}

#[view]
fn view_get_hash_for(
    address: felt
) -> u256 {
    caller_address_hash::read(address);
}

#[external]
fn commit_hash(hash: u256) {
    caller_address_hash::write(get_caller_address(), hash);
}

#[external]
fn reveal(number: felt, response: felt) {
    // alloc_locals;
    // let (caller_address) = get_caller_address();
    // let (committed_hash) = caller_address_hash_storage.read(caller_address);
    // let (is_eq_to_zero) = uint256_eq(committed_hash, Uint256(0, 0));
    // with_attr error_message("You should first commit something") {
    //     assert is_eq_to_zero = FALSE;
    // }
    // let (current_hash) = view_get_keccak_hash(number, response);
    // let (is_eq) = uint256_eq(current_hash, committed_hash);
    // with_attr error_message("You are trying to cheat") {
    //     assert is_eq = TRUE;
    // }
    // caller_address_hash_storage.write(caller_address, Uint256(0, 0));
    // let (current_number_of_vote) = vote_per_response_storage.read(response);
    // vote_per_response_storage.write(response, current_number_of_vote + 1);
    // return ();
}
}
