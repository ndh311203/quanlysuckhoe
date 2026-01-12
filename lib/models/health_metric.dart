import 'dart:convert';

enum MetricType { weight, height, bmi, bloodPressure, heartRate, glucose, steps, water }

class HealthMetric {
  final String id;
  final MetricType type;
  final double? value;
  final int? systolic;
  final int? diastolic;
  final DateTime timestamp;

  HealthMetric({
    required this.id,
    required this.type,
    this.value,
    this.systolic,
    this.diastolic,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'value': value,
      'systolic': systolic,
      'diastolic': diastolic,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id'] as String,
      type: MetricType.values.firstWhere((e) => e.name == (json['type'] as String)),
      value: (json['value'] as num?)?.toDouble(),
      systolic: json['systolic'] as int?,
      diastolic: json['diastolic'] as int?,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp'] as String) : DateTime.now(),
    );
  }

  static List<HealthMetric> listFromJson(String jsonStr) {
    final decoded = json.decode(jsonStr) as List<dynamic>;
    return decoded.map((e) => HealthMetric.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<HealthMetric> list) {
    final mapped = list.map((e) => e.toJson()).toList();
    return json.encode(mapped);
  }
}


