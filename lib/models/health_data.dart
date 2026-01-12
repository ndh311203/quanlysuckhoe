class HealthData {
  final DateTime date;
  final int steps;
  final double water;

  HealthData({
    required this.date,
    required this.steps,
    required this.water,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'steps': steps,
        'water': water,
      };

  factory HealthData.fromJson(Map<String, dynamic> json) => HealthData(
        date: DateTime.parse(json['date'] as String),
        steps: (json['steps'] as num?)?.toInt() ?? 0,
        water: (json['water'] as num?)?.toDouble() ?? 0.0,
      );
}


