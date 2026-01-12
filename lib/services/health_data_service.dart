import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_data.dart';

class HealthDataService {
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  HealthDataService._internal();

  static const String _healthDataKey = 'health_data_';

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<SharedPreferences> get _safePrefs async {
    if (_isInitialized && _prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    return _prefs!;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  Future<HealthData> getHealthDataForDate(DateTime date) async {
    final prefs = await _safePrefs;
    final key = '$_healthDataKey${_dateKey(date)}';
    final jsonStr = prefs.getString(key);
    if (jsonStr == null) return HealthData(date: date, steps: 0, water: 0);
    return HealthData.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  Future<void> saveHealthData(HealthData data) async {
    final prefs = await _safePrefs;
    final key = '$_healthDataKey${_dateKey(data.date)}';
    await prefs.setString(key, jsonEncode(data.toJson()));
  }

  Future<List<HealthData>> getHealthDataRange(DateTime start, DateTime end) async {
    final List<HealthData> list = [];
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    final prefs = await _safePrefs;
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      final key = '$_healthDataKey${_dateKey(current)}';
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        list.add(HealthData.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>));
      } else {
        list.add(HealthData(date: current, steps: 0, water: 0));
      }
      current = current.add(const Duration(days: 1));
    }
    return list;
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
}


