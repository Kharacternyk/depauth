extension TitleCase on String {
  String get title => split(" ").map((string) {
        if (string.isEmpty) {
          return string;
        }
        return string.substring(0, 1).toUpperCase() + string.substring(1);
      }).join(" ");
}
