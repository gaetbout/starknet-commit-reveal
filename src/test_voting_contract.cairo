use src::VotingContract;
use starknet_testing::set_caller_address;
use traits::TryInto;
use starknet::FeltTryIntoContractAddress;
use option::OptionTrait;

const SALT: felt = 42;
const VALUE_TO_SALT: felt = 'lama';

// Computed using: https://www.stark-utils.xyz/signature
const PEDERSEN_HASH: felt = 0x38cb18d2caa96cd242db94dbc924881817745fb1bb1ecc15d5dbd0e8bc795b;

#[test]
#[available_gas(2000000)]
fn test_hash_salt_with_value() {
    set_caller_address(felt_to_contract_address(1));
    let hash = VotingContract::hash_salt_with_value(SALT, VALUE_TO_SALT);
    assert(hash == PEDERSEN_HASH, 'Should be PEDERSEN_HASH');
}

#[test]
#[available_gas(2000000)]
fn test_commit_hash() {
    set_caller_address(felt_to_contract_address(2));
    VotingContract::commit_hash(PEDERSEN_HASH);
    let hash = VotingContract::get_hash_for(felt_to_contract_address(2));
    assert(hash == PEDERSEN_HASH, 'Hash not correctly committed');
}

#[test]
#[available_gas(2000000)]
fn test_get_hash_for_nothing_committed() {
    set_caller_address(felt_to_contract_address(3));
    let hash = VotingContract::get_hash_for(felt_to_contract_address(3));
    assert(hash == 0, 'Hash should be zero');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected = 'You should first commit something')]
fn test_reveal_with_nothing_committed() {
    set_caller_address(felt_to_contract_address(4));
    VotingContract::reveal(1, 1);
}

#[test]
#[available_gas(2000000)]
fn test_reveal() {
    set_caller_address(felt_to_contract_address(5));
    let mut a = VotingContract::get_vote_for_response(VALUE_TO_SALT);
    assert(a == 0, 'Hash should be zero');
    VotingContract::commit_hash(PEDERSEN_HASH);
    a = VotingContract::get_vote_for_response(VALUE_TO_SALT);
    assert(a == 0, 'Hash should be zero');
    VotingContract::reveal(SALT, VALUE_TO_SALT);
    a = VotingContract::get_vote_for_response(VALUE_TO_SALT);
    assert(a == 1, 'Hash should be one');
}

#[test]
#[available_gas(2000000)]
fn test_reveal_value_reset() {
    set_caller_address(felt_to_contract_address(6));
    VotingContract::commit_hash(PEDERSEN_HASH);
    VotingContract::reveal(SALT, VALUE_TO_SALT);
    let hash = VotingContract::get_hash_for(felt_to_contract_address(6));
    assert(hash == 0, 'Hash should be zero');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected = 'You should first commit something')]
fn test_reveal_Cheating() {
    set_caller_address(felt_to_contract_address(7));
    VotingContract::commit_hash(PEDERSEN_HASH);
    VotingContract::reveal(SALT - 1, VALUE_TO_SALT);
}

fn felt_to_contract_address(f: felt) -> ContractAddress {
    f.try_into().unwrap()
}
