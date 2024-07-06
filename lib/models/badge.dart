class CustomBadge {
  final String name;
  final String description;
  final bool isEarned;

  CustomBadge({
    required this.name,
    required this.description,
    this.isEarned = false,
  });
}
