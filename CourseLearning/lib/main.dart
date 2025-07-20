//My first Dart program.
import 'dart:io';

void main() {
  print("Hello, World!");

  //Some Programming Fundamentals
  var x = 5; //var keyword automatically infers the type
  String name = "John";
  int age = 30;
  //So we can explicitly define types as well.
  print("Name: $name, Age: $age, x: $x");

  //Some Aritmatic operators
  int a = 10;
  int b = 20;
  int sum = a + b;
  int sub = a - b;
  int mul = a * b;
  int mod = a % b; //Modulus operator
  double div1 = a / b; //Floating point division
  int div2 = a ~/ b; //Integer division(rounds to an integer)

  print(
    "Sum: $sum, Subtraction: $sub, Multiplication: $mul, Modulus: $mod, Division (float): $div1, Division (int): $div2",
  );
  //String and values in print
  int temp = 35;
  print(
    "\"The temperature today is $temp\" as said by the weather Department.",
  );

  //Control Statements and the Loops.
  for (int i = 0; i < 5; i++) {
    print("This is iteration number $i");
  }

  bool c = bool.parse(stdin.readLineSync()!);
  if (c)
    print("This is True ");
  else
    print("This is False");

  //Switch case
  String animal = stdin.readLineSync()!;
  switch (animal) {
    case "Dog":
      print("It Barks");
      break;
    case "Cat":
      print("It Meows");
      break;
    default:
      print("Dont Know");
  }
}
