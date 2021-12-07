# code-vs-zombie
This is an solution for the challenge Code vs Zombie in [Codingame](https://www.codingame.com/ide/puzzle/code-vs-zombies)

![preview](https://static.codingame.com/servlet/fileservlet?id=4769410464205&format=puzzle_cover)


## Todo list
```diff
+ Naive implementation of the Monte Carlo algorithm 
  + Simulate a game with random moves for Ash and for the Zombies
  + Save the history of each move
  + Update score every turn
  + Find the best scoring game and if there are multiple game with the same score pick the one that has less turns 
- Convert code into python
- Find a gaming engine that will display a game simulation (ex: https://www.pygame.org/)
- Implement some testing framework for judging model behaviour
- Make the model more similar to the codingame framework 
  - Zombies don't move randomly, they pick human targets including Ash
  - Ash should pick a target zombie randomly as wwell   
  - The scoring system should reflect the combo calculations
- keep track of time and simulate games as long as we are under the 100 ms instead of a predetermined number
- Do performance testing and optimize the codebase to be able to simulated more games during the 100 ms allowed in one turn
```
## Contribute
Fork the repo and create a PR and request 
https://git-scm.com/book/en/v2/GitHub-Contributing-to-a-Project
