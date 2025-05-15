class FavoriteItem {
  final String name;
  final String title;
  final String formula;

  FavoriteItem({
    required this.name,
    required this.title,
    required this.formula,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'title': title,
    'formula': formula,
  };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      name: json['name'],
      title: json['title'],
      formula: json['formula'],
    );
  }
}
