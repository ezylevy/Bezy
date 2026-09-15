enum GameMode {
  learning,
  challenge;

  bool get allowsHints => this == GameMode.learning;
  bool get allowsSolutions => this == GameMode.learning;
}
