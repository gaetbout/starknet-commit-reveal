#[contract]
mod VotingContract {
    use starknet::get_caller_address;
    use starknet::ContractAddress;

    struct Storage {
        caller_address_hash: LegacyMap<ContractAddress, felt252>,
        vote_for_response: LegacyMap<felt252, felt252>,
    }

    #[view]
    fn hash_salt_with_value(salt: felt252, value_to_hash: felt252) -> felt252 {
        pedersen(salt, value_to_hash)
    }

    #[view]
    fn get_vote_for_response(response: felt252) -> felt252 {
        vote_for_response::read(response)
    }

    #[view]
    fn get_hash_for(address: ContractAddress) -> felt252 {
        caller_address_hash::read(address)
    }

    #[external]
    fn commit_hash(hash: felt252) {
        caller_address_hash::write(get_caller_address(), hash);
    }

    #[external]
    fn reveal(number: felt252, response: felt252) {
        let caller_address = get_caller_address();
        let committed_hash = caller_address_hash::read(caller_address);
        assert(committed_hash != 0, 'No hash committed');
        let current_hash = hash_salt_with_value(number, response);
        assert(current_hash == committed_hash, 'You are trying to cheat');
        caller_address_hash::write(caller_address, 0);
        vote_for_response::write(response, vote_for_response::read(response) + 1);
    }
}
