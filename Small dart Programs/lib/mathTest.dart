import 'dart:io';
import 'dart:math';

void main() {
  Random rand = new Random();
  int answer = 0, userans, operand1, operand2, operation;
  int questionCount = 0, correct = 0;
  while (true) {
    questionCount++;
    operand1 = rand.nextInt(10) + 1; // Random number between 1 and 10
    operand2 = rand.nextInt(10) + 1; // Random number between 1 and 10
    operation = rand.nextInt(4); // Random operation: 0-3

    switch (operation) {
      case 0: // Addition
        answer = operand1 + operand2;
        print('$operand1 + $operand2 = ?');
        break;
      case 1: // Subtraction
        answer = operand1 - operand2;
        print('$operand1 - $operand2 = ?');
        break;
      case 2: // Multiplication
        answer = operand1 * operand2;
        print('$operand1 * $operand2 = ?');
        break;
      case 3: // Division
        if (operand2 == 0) continue; // Avoid division by zero
        answer = (operand1 / operand2).round();
        print('$operand1 / $operand2 = ?');
        break;
    }

    try {
      userans = int.parse(stdin.readLineSync()!);
    } catch (e) {
      print('Thanks for Playing!');
      print("Your score is $correct out of $questionCount.");
      break;
    }

    if (userans == answer) {
      correct++;
      print('Correct!');
    } else {
      print('Wrong! The correct answer is $answer.');
    }
  }
}
