use commit_reveal::voting_contract::{IVotingContractDispatcher, IVotingContractDispatcherTrait, VotingContract};
use core::option::OptionTrait;
use core::traits::TryInto;
use starknet::{deploy_syscall, ContractAddress, contract_address_try_from_felt252, testing::set_contract_address};

const SALT: felt252 = 42;
const VALUE_TO_SALT: felt252 = 'lama';

// Computed using: https://www.stark-utils.xyz/signature
const PEDERSEN_HASH: felt252 = 0x38cb18d2caa96cd242db94dbc924881817745fb1bb1ecc15d5dbd0e8bc795b;

fn deploy_contract() -> IVotingContractDispatcher {
    let class_hash = VotingContract::TEST_CLASS_HASH.try_into().unwrap();
    let (contract_address, _) = deploy_syscall(class_hash, 0, array![].span(), false).unwrap();
    IVotingContractDispatcher { contract_address }
}

#[test]
#[available_gas(2000000)]
fn test_hash_salt_with_value() {
    let voting_contract = deploy_contract();

    let hash = voting_contract.hash_salt_with_value(SALT, VALUE_TO_SALT);
    assert(hash == PEDERSEN_HASH, 'Should be PEDERSEN_HASH');
}

#[test]
#[available_gas(2000000)]
fn test_commit_hash() {
    let voting_contract = deploy_contract();
    let caller = 'caller 1'.try_into().unwrap();

    set_contract_address(caller);
    voting_contract.commit_hash(PEDERSEN_HASH);

    let hash = voting_contract.get_hash_for(caller);
    assert(hash == PEDERSEN_HASH, 'Hash not correctly committed');
}

#[test]
#[available_gas(2000000)]
fn test_get_hash_for_nothing_committed() {
    let voting_contract = deploy_contract();
    let caller = 'caller 2'.try_into().unwrap();

    set_contract_address(caller);
    let hash = voting_contract.get_hash_for(caller);
    assert(hash == 0, 'Hash should be zero');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('No hash committed', 'ENTRYPOINT_FAILED'))]
fn test_reveal_with_nothing_committed() {
    let voting_contract = deploy_contract();

    set_contract_address('caller 3'.try_into().unwrap());
    voting_contract.reveal(1, 1);
}

#[test]
#[available_gas(2000000)]
fn test_reveal() {
    let voting_contract = deploy_contract();
    set_contract_address('caller 4'.try_into().unwrap());

    let mut vote = voting_contract.get_vote_for_response(VALUE_TO_SALT);
    assert(vote == 0, 'Hash should be zero');
    voting_contract.commit_hash(PEDERSEN_HASH);

    vote = voting_contract.get_vote_for_response(VALUE_TO_SALT);
    assert(vote == 0, 'Hash should be zero');
    voting_contract.reveal(SALT, VALUE_TO_SALT);

    vote = voting_contract.get_vote_for_response(VALUE_TO_SALT);
    assert(vote == 1, 'Hash should be one');
}

#[test]
#[available_gas(2000000)]
fn test_reveal_value_reset() {
    let voting_contract = deploy_contract();
    let caller = 'caller 5'.try_into().unwrap();

    set_contract_address(caller);
    voting_contract.commit_hash(PEDERSEN_HASH);
    voting_contract.reveal(SALT, VALUE_TO_SALT);
    let hash = voting_contract.get_hash_for(caller);
    assert(hash == 0, 'Hash should be zero');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('You are trying to cheat', 'ENTRYPOINT_FAILED'))]
fn test_reveal_cheating() {
    let voting_contract = deploy_contract();
    set_contract_address('caller 6'.try_into().unwrap());

    voting_contract.commit_hash(PEDERSEN_HASH);
    voting_contract.reveal(SALT - 1, VALUE_TO_SALT);
}
