import 'package:health/health.dart';

class GoogleFitService {
  final dynamic _health = Health();

  Future<bool> requestPermissions() async {
    final types = [HealthDataType.STEPS];
    final permissions = [HealthDataAccess.READ];
    final granted = await (_health.requestAuthorization(types, permissions: permissions) as Future<bool?>);
    return granted ?? false;
  }

  /// Sync steps: returns map of date -> total steps for that date
  Future<Map<DateTime, int>> syncFromGoogleFit(DateTime start, DateTime end) async {
    final types = [HealthDataType.STEPS];
    final has = await (_health.hasPermissions(types) as Future<bool?>);
    if (has != true) {
      final ok = await requestPermissions();
      if (!ok) throw Exception('No permission for Google Fit');
    }

    final data = await (_health.getHealthDataFromTypes(start, end, types) as Future<List<dynamic>>);
    final Map<DateTime, int> byDay = {};
    for (final dp in data) {
      try {
        final dateFrom = dp.dateFrom as DateTime;
        final date = DateTime(dateFrom.year, dateFrom.month, dateFrom.day);
        final value = dp.value;
        final intValue = (value is num) ? value.toInt() : int.tryParse(value.toString()) ?? 0;
        byDay[date] = (byDay[date] ?? 0) + intValue;
      } catch (_) {
        // ignore malformed points
      }
    }
    return byDay;
  }
}


