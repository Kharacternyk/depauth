extension TitleCase on String {
  String title(String separator) {
    return split(separator).map((string) {
      if (string.isEmpty) {
        return string;
      }
      return string.substring(0, 1).toUpperCase() + string.substring(1);
    }).join(separator);
  }
}
