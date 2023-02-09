use src::VotingContract;

const SALT: felt = 42;
const VALUE_TO_SALT: felt = 'lama';
const PEDERSEN_HASH: felt = 100345159373659504674655006899959215960779660001895611658152852923411626331;

#[test]
#[available_gas(200000)]
fn test_hash_salt_with_value() {
    let hash = VotingContract::hash_salt_with_value(SALT, VALUE_TO_SALT);
    assert(hash == PEDERSEN_HASH, 'Should be PEDERSEN_HASH');
}

#[test]
#[available_gas(200000)]
fn test_commit_hash() {
    VotingContract::commit_hash(PEDERSEN_HASH);
    let caller = VotingContract::get_caller_address();
    let hash = VotingContract::get_hash_for(caller);
    assert(hash == PEDERSEN_HASH, 'Hash not correctly committed');
}

#[test]
#[available_gas(200000)]
fn test_get_hash_for_nothing_committed() {
    let caller = VotingContract::get_caller_address();
    let hash = VotingContract::get_hash_for(caller);
    assert(hash == 0, 'Hash should be zero');
}

#[test]
#[available_gas(200000)]
#[should_panic(expected = 'You should first commit something')]
fn test_reveal_with_nothing_committed() {
    VotingContract::reveal(1,1);
}

#[test]
#[available_gas(200000)]
fn test_reveal() {
    let mut a = VotingContract::get_vote_per_response(VALUE_TO_SALT);
    assert(a == 0, 'Hash should be zero');
    VotingContract::commit_hash(PEDERSEN_HASH);
    a = VotingContract::get_vote_per_response(VALUE_TO_SALT);
    assert(a == 0, 'Hash should be zero');
    VotingContract::reveal(SALT, VALUE_TO_SALT);
    a = VotingContract::get_vote_per_response(VALUE_TO_SALT);
    assert(a == 1, 'Hash should be one');
}

#[test]
#[available_gas(200000)]
fn test_reveal_value_reset() {
    VotingContract::commit_hash(PEDERSEN_HASH);
    VotingContract::reveal(SALT, VALUE_TO_SALT);
    let caller = VotingContract::get_caller_address();
    let hash = VotingContract::get_hash_for(caller);
    assert(hash == 0, 'Hash should be zero');
}

#[test]
#[available_gas(200000)]
#[should_panic(expected = 'You should first commit something')]
fn test_reveal_Cheating() {
    VotingContract::commit_hash(PEDERSEN_HASH);
    VotingContract::reveal(SALT-1, VALUE_TO_SALT);
}