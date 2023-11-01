use starknet::ContractAddress;

#[starknet::interface]
trait IVotingContract<TContractState> {
    fn hash_salt_with_value(self: @TContractState, salt: felt252, value_to_hash: felt252) -> felt252;
    fn get_vote_for_response(self: @TContractState, response: felt252) -> felt252;
    fn get_hash_for(self: @TContractState, address: ContractAddress) -> felt252;
    fn commit_hash(ref self: TContractState, hash: felt252);
    fn reveal(ref self: TContractState, number: felt252, response: felt252);
}

#[starknet::contract]
mod VotingContract {
    use hash::{HashStateTrait, HashStateExTrait};
    use pedersen::PedersenTrait;
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        caller_address_hash: LegacyMap<ContractAddress, felt252>,
        vote_for_response: LegacyMap<felt252, felt252>,
    }

    #[external(v0)]
    impl VotingContractImpl of super::IVotingContract<ContractState> {
        fn hash_salt_with_value(self: @ContractState, salt: felt252, value_to_hash: felt252) -> felt252 {
            PedersenTrait::new(salt).update_with(value_to_hash).finalize()
        }

        fn get_vote_for_response(self: @ContractState, response: felt252) -> felt252 {
            self.vote_for_response.read(response)
        }

        fn get_hash_for(self: @ContractState, address: ContractAddress) -> felt252 {
            self.caller_address_hash.read(address)
        }

        fn commit_hash(ref self: ContractState, hash: felt252) {
            self.caller_address_hash.write(get_caller_address(), hash);
        }

        fn reveal(ref self: ContractState, number: felt252, response: felt252) {
            let caller_address = get_caller_address();
            let committed_hash = self.get_hash_for(caller_address);
            assert(committed_hash != 0, 'No hash committed');
            let current_hash = self.hash_salt_with_value(number, response);
            assert(current_hash == committed_hash, 'You are trying to cheat');
            self.caller_address_hash.write(caller_address, 0);
            self.vote_for_response.write(response, self.vote_for_response.read(response) + 1);
        }
    }
}
