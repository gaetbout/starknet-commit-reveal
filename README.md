# Commit reveal

As you probably know, everything on the blockchain is public.  
Which can lead to some problems to design some application... Here is a brief overview: 
 - Rock, cisor, paper game: Player 2 would just have to wait that player 1 submits his move, read the transaction and play accordingly.  
 - Battleship: Player 2 could just read the board of player one, and the shoot all its submarines.
 - A quizz: Player 2 could wait for the response of player 1 (starts to see the schema here?)
 - A voting system: In a private system it is idea that each vote has no impact on other voter's opinion. But if everyone can read that player 1 voted for someone specific it could affect their response.   
 
The solution allows to hide temporarily some data from other users. It is called the **commit-reveal scheme**.  
This pattern is splitted in two steps:
 1. Commit a hidden value to the blockchain
 2. Reveal the commited value and ensure that it is the correct value.  


## Commit
The user calls the method with a hashed value of the reponse.  
This hashed response needs to be done with some random value as salt. Why?  
Otherwise the oponent could just read the transaction and then hash it (for example in a simple rock, cisor, paper it is quite easy to figure out the hashed value of these moves).  
It is important to note that the random value shouldn't be something the that can be easily discovered such as a timestamp, the address of the user, ...  
There exists some more complex version where the user first send the hash of a random number that the contract combine with the current block hash to generate some randomness, but let's keep it simple.

## Reveal
Now the user will just send the random number and his response and the contract will make sure that it corresponds to the previous answer the user sent on the previous step.

## Example contract
To make it the simplest possible, this contract will just be a voting system.  
Where user first have to submit their hashed response then they have to reveal it.  
It'll then add 1 vote for that value.  
Each user can vote as much as they want (very democratic, I know!).

## Addition
I made here a very simple version of the commit reveal.  
It could be enhanced to add a timestamp up to when all user can sumbit their answers or slash them if they don't respond in time.  
If we use the version that includes the step to first send a random number that we hash with the current block hash, it could be used to generate some randomness in the game.


## More information 

For more information or clarification have a look here:  
 https://medium.com/gitcoin/commit-reveal-scheme-on-ethereum-25d1d1a25428  
 https://github.com/scaffold-eth/scaffold-eth/tree/commit-reveal-scafold  
 https://github.com/scaffold-eth/scaffold-eth-examples/tree/commit-reveal-with-frontend  
 https://youtu.be/LDOzDQ44dM4  