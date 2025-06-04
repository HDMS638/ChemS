class ElementModel {
  final String name;
  final String symbol;
  final int atomicNumber;
  final double atomicMass;
  final String category;
  final int group;
  final int period;

  ElementModel({
    required this.name,
    required this.symbol,
    required this.atomicNumber,
    required this.atomicMass,
    required this.category,
    required this.group,
    required this.period,
  });

  factory ElementModel.fromJson(Map<String, dynamic> json) {
    return ElementModel(
      name: json['name'] ?? 'Unknown',
      symbol: json['symbol'] ?? '??',
      atomicNumber: json['atomicNumber'] ?? 0,
      atomicMass: (json['atomicMass'] ?? 0).toDouble(),
      category: json['category'] ?? 'Unknown',
      group: json['group'] ?? 0,
      period: json['period'] ?? 0,
    );
  }

  factory ElementModel.empty() {
    return ElementModel(
      name: '',
      symbol: '',
      atomicNumber: 0,
      atomicMass: 0.0,
      category: '',
      group: 0,
      period: 0,
    );
  }

  bool get isEmpty => atomicNumber == 0;
}