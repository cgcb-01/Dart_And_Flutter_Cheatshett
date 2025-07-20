import 'dart:math';
import 'dart:io';

void main() {
  print("Welcome to the No Guessing Game!");
  Random rand = Random();
  int num = rand.nextInt(10);
  while (true) {
    print("Guess a number between 0 and 9:");
    int guess = int.parse(stdin.readLineSync()!);
    if (guess == num) {
      print("You Guessed Correct");
      break;
    } else if (guess < num) {
      print("Your Guess is low");
    } else {
      print("Your Guess is high");
    }
  }
}
