import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/health_metric.dart';

class HealthMetricService {
  static const _key = 'health_metrics';
  List<HealthMetric> _metrics = [];
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        _metrics = HealthMetric.listFromJson(raw);
      } catch (_) {
        _metrics = [];
      }
    } else {
      _metrics = [];
    }
  }

  Future<void> addMetric(HealthMetric metric) async {
    _metrics.add(metric);
    await _save();
  }

  Future<void> _save() async {
    final jsonStr = HealthMetric.listToJson(_metrics);
    try {
      if (_prefs == null) _prefs = await SharedPreferences.getInstance();
      final ok = await _prefs!.setString(_key, jsonStr);
      // ignore: avoid_print
      print('DEBUG: HealthMetricService._save -> prefs set key=$_key ok=$ok length=${jsonStr.length}');
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: HealthMetricService._save -> prefs error: $e');
    }
    // write fallback file so we can inspect persistence
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/health_metrics.json');
      await file.writeAsString(jsonStr);
      final exists = await file.exists();
      // ignore: avoid_print
      print('DEBUG: HealthMetricService._save -> file written ${file.path} exists=$exists length=${jsonStr.length}');
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: HealthMetricService._save -> file write error: $e');
    }
  }

  List<HealthMetric> getAll() => List.unmodifiable(_metrics);

  HealthMetric? getLatest(MetricType type) {
    for (var i = _metrics.length - 1; i >= 0; i--) {
      if (_metrics[i].type == type) return _metrics[i];
    }
    return null;
  }

  List<HealthMetric> getForType(MetricType type) => _metrics.where((m) => m.type == type).toList();
}


