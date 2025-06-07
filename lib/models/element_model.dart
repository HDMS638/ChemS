class ElementModel {
  final Map<String, String> name;
  final String symbol;
  final int atomicNumber;
  final double atomicMass;
  final Map<String, String> category;
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
      name: Map<String, String>.from(json['name'] ?? {'en': 'Unknown', 'ko': '알 수 없음'}),
      symbol: json['symbol'] ?? '??',
      atomicNumber: json['atomicNumber'] ?? 0,
      atomicMass: (json['atomicMass'] ?? 0).toDouble(),
      category: Map<String, String>.from(json['category'] ?? {'en': 'Unknown', 'ko': '알 수 없음'}),
      group: json['group'] is int ? json['group'] : int.tryParse(json['group'].toString()) ?? 0,
      period: json['period'] is int ? json['period'] : int.tryParse(json['period'].toString()) ?? 0,
    );
  }

  factory ElementModel.empty() {
    return ElementModel(
      name: {'en': '', 'ko': ''},
      symbol: '',
      atomicNumber: 0,
      atomicMass: 0.0,
      category: {'en': '', 'ko': ''},
      group: 0,
      period: 0,
    );
  }

  bool get isEmpty => atomicNumber == 0;
}
