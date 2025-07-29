import 'dart:io';
import 'dart:math';

// Function to determine the Player move
String playerMove() {
  print("Enter your move (rock, paper, or scissors): ");
  String? move = stdin
      .readLineSync(); // the quetsion mark is used to allow null values.
  if (move == null ||
      !['rock', 'paper', 'scissors'].contains(move.toLowerCase())) {
    print("Invalid move. Please try again.");
    return playerMove();
  }
  return move.toLowerCase();
}

// Function to determine the computer move
String computerMove() {
  List<String> moves = ['rock', 'paper', 'scissors'];
  Random random = Random();
  return moves[random.nextInt(moves.length)];
}

// Function to determine the winner
String determineWinner(String player, String computer) {
  if (player == computer) {
    return "It's a tie";
  } else if ((player == 'rock' && computer == 'scissors') ||
      (player == 'paper' && computer == 'rock') ||
      (player == 'scissors' && computer == 'paper')) {
    return "You win!";
  } else {
    return "Computer wins!";
  }
}

// Main function to run the game
void main() {
  print("Welcome to Rock, Paper, Scissors!");
  String player = playerMove();
  String computer = computerMove();
  while (true) {
    print("You chose: $player");
    print("Computer chose: $computer");
    // Determine the winner
    String result = determineWinner(player, computer);
    print(result);
    print("Do you want to play again? (yes/no)");
    String? playAgain = stdin.readLineSync();
    if (playAgain == null || playAgain.toLowerCase() != 'yes') {
      print("Thanks for playing!");
      break;
    }
  }
}
