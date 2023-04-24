[![Twitter URL](https://img.shields.io/twitter/url.svg?label=Follow%20%40gaetbout&style=social&url=https%3A%2F%2Ftwitter.com%2Fgaetbout)](https://twitter.com/gaetbout)
# How to install

**Prerequisit:** Have cargo installed

Clone this repository and move into the repository:
```shell
git clone https://github.com/gaetbout/starknet-commit-reveal
cd starknet-commit-reveal
```
Clone Starkware's repo
```shell
git clone https://github.com/starkware-libs/cairo --depth=1 --branch v1.0.0-alpha.7
```
Build the project
```shell
cargo build --release --bin cairo-test --manifest-path cairo/Cargo.toml
```

You can now run the tests using:
```shell
./cairo/target/release/cairo-test . --starknet
```

# Commit reveal

As you probably know, everything on the blockchain is public.  
Which can lead to some problems to design some application... Here is a brief overview: 
 - Rock, cisor, paper game: Player 2 would just have to wait that player 1 submits his move, read the transaction and play accordingly.  
 - Battleship: Player 2 could just read the board of player one, and the shoot all its submarines.
 - A quizz: Player 2 could wait for the response of player 1 (starts to see the schema here?)
 - A voting system: In a private system it is the idea that each vote has no impact on other voter's opinion. But if everyone can read what other people are voting it could affect their response.   
 
The solution allows to hide temporarily some data from other users. It is called the **commit-reveal scheme**.  
This pattern is splitted in two steps:
 1. Commit a hash of the response to the blockchain  
 2. Reveal the commited value and ensure that it is the value submitted at the previous step  


## Commit
The user calls the method with a hashed value of the reponse.  
This hashed response needs to be done with some random value as salt. Why?  
Otherwise the oponent could just make some guesses and he could find the response (for example in a simple rock, cisor, paper it is quite easy to figure out the hash value of each move).  
It is important to note that the random value shouldn't be something the that can be easily discovered such as a timestamp, the address of the user, ...  
There exists some more complex version where the user first send the hash of a random number that the contract combine with the current block hash to generate some randomness, but let's keep it simple here.

## Reveal
Now the user will just send the random number and his response and the contract will make sure that it corresponds to the previous answer the user sent on the previous step.

## Example contract
To make it the simplest possible, this contract will just be a voting system.  
Where user first have to submit their hashed response then they have to reveal it.  
It'll then add 1 vote for that value.  
Of course the client shouldn't call the method view_get_keccak_hash to hash its values otherwise someone could just read all transactions. This should be done entirely from the client side, it is just here for help purposes.  
Each user can vote as much as they want (very democratic, I know!).

## Addition
I made here a very simple version of the commit-reveal.  
There is no temporal limit for example. In a game there should be one to ensure that no player is trying to block the game because he knows he lost the game. This could be achieved trough a slashing system.  
If we use the version that includes the step that consist of sending a random number it could be used to generate some randomness in the game. Make sure that the contract hash that random number with some other stuff that the user can't be aware of.  

## More information 

For more information or clarification have a look here:  
 https://medium.com/gitcoin/commit-reveal-scheme-on-ethereum-25d1d1a25428  
 https://github.com/scaffold-eth/scaffold-eth/tree/commit-reveal-scafold  
 https://github.com/scaffold-eth/scaffold-eth-examples/tree/commit-reveal-with-frontend  
 https://youtu.be/LDOzDQ44dM4  
