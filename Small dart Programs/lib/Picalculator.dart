import 'dart:math';

void main() {
  const int n = 1000000; // Number of terms in the series
  double series = 1.0;
  double denominator = 3.0;
  double negate = -1.0;
  double PI = 3.141592653589793;
  //making the sum of the series
  for (int i = 1; i <= n; i++) {
    series += negate / denominator;
    denominator += 2.0;
    negate *= -1.0; // Alternate between adding and subtracting
  }
  double pi = series * 4.0; // Calculate Pi
  print('Approximation of Pi using $n terms: $pi');
  print("The real value of Pi is: $PI");
  print("We are off by: ${PI - pi}");
}
