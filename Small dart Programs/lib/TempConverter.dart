import 'Dart:io';
import 'dart:math';

//Function to convert Celsius to Fahrenheit and vice versa.
double celsiusToFahrenheit() {
  print("Enter a temperature in Celsius:");
  //Taking input from the user.
  double celsius = double.parse(stdin.readLineSync()!);
  double fahrenheit = (celsius * 9 / 5) + 32;
  print("$celsius Celsius is $fahrenheit Fahrenheit");
  return fahrenheit;
}

//Function to convert Fahrenheit to Celsius.
double fahrenheitToCelsius() {
  print("Enter a temperature in Fahrenheit:");
  //Taking input from the user.
  double fahrenheit = double.parse(stdin.readLineSync()!);
  double celsius = (fahrenheit - 32) * 5 / 9;
  print("$fahrenheit Fahrenheit is $celsius Celsius");
  return celsius;
}

void main() {
  print("Enter a temperature in Celsius:");
  //Choice of the user.
  print(
    "Enter the Scale of conversion: \n1. Celsius to Fahrenheit \n2. Fahrenheit to Celsius",
  );
  int choice = int.parse(stdin.readLineSync()!);
  if (choice == 1) {
    celsiusToFahrenheit();
  } else if (choice == 2) {
    fahrenheitToCelsius();
  } else {
    print("Presetly We cant make this conversion.");
  }
}
