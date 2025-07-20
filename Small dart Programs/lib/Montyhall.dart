// Monty Hall problem simulation in Dart
import 'dart:math';

void main() {
  const int Trials = 1000000;
  int correct = 0;
  Random rand = new Random();
  print(
    "Simulating the Monty Hall problem for $Trials trials...",
  ); // Stimulating the problem to sow switcing is good.
  for (int i = 0; i < Trials; i++) {
    int randDoor = rand.nextInt(3) + 1;
    int guess = 1; //Lets fix a no to be guessed as 1
    int revealedDoor;
    //We need to reveal a door that does not ave the prize
    if (randDoor == 2)
      revealedDoor = 3;
    else if (randDoor == 3)
      revealedDoor = 2;
    else
      // If the prize is behind door 1, we can reveal either door 2 or 3
      revealedDoor = rand.nextInt(2) + 2;

    if (revealedDoor == 2) //We had guessed 1 revealed 2 choose 3
      guess = 3;
    else if (revealedDoor == 3)
      guess = 2; //same way above and update guess

    if (randDoor == guess)
      correct++; //If after switc guess is correct increment count.
  }
  print(
    "The percentage of correct guesses was ${(correct / Trials) * 100}%",
  ); //Result shows switching is better >66.5%
}
