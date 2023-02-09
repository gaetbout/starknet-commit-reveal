#[contract]
mod VotingContract {
    use starknet::get_caller_address;
    struct Storage {
        caller_address_hash: LegacyMap::<felt, felt>,
        vote_per_response: LegacyMap::<felt, felt>,
    }

    // TODO Should prob mock get_caller_address
    #[view]
    fn hash_salt_with_value(salt: felt, value_to_hash: felt) -> felt {
        pedersen(salt, value_to_hash)
    }

    #[view]
    fn get_vote_per_response(response: felt) -> felt {
        vote_per_response::read(response)
    }

    #[view]
    fn get_hash_for(address: felt) -> felt {
        caller_address_hash::read(address)
    }

    #[external]
    fn commit_hash(hash: felt) {
        let caller = get_caller_address();
        debug::print_felt(caller);
        caller_address_hash::write(caller, hash);
    }

    #[external]
    fn reveal(number: felt, response: felt) { 
        let caller_address = get_caller_address();
        let committed_hash = caller_address_hash::read(caller_address);
        assert(committed_hash != 0, 'No hash committed');
        let current_hash = hash_salt_with_value(number, response);
        assert(current_hash == committed_hash, 'You are trying to cheat');
        caller_address_hash::write(caller_address, 0);
        vote_per_response::write(response, vote_per_response::read(response) + 1);
    }
}
