class Fraction {
  final int nominator;
  final int denominator;

  Fraction._(this.nominator, this.denominator);

  factory Fraction(int nominator, int denominator) {
    final gcd = nominator.gcd(denominator);
    return Fraction._(nominator ~/ gcd, denominator ~/ gcd);
  }

  double toDouble() => nominator / denominator;
}
