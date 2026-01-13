import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/health_metric_service.dart';
import '../models/health_metric.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});
  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  final _metricService = HealthMetricService();
  bool _isLoading = true;
  List<HealthMetric> _weights = [];
  List<HealthMetric> _steps = [];
  List<HealthMetric> _heartRates = [];
  List<HealthMetric> _waters = [];
  List<HealthMetric> _glucose = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _metricService.initialize();
    final all = _metricService.getForType(MetricType.weight);
    // take last 14 entries
    _weights = all;
    // load additional types for extra charts
    _steps = _metricService.getForType(MetricType.steps);
    _heartRates = _metricService.getForType(MetricType.heartRate);
    _waters = _metricService.getForType(MetricType.water);
    _glucose = _metricService.getForType(MetricType.glucose);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biểu đồ thống kê')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildChartCard('Cân nặng (lịch sử)', _buildMetricLineChart(_weights.map((e) => MapEntry(e.timestamp, e.value ?? 0)).toList(), Colors.blue, 'kg')),
                  const SizedBox(height: 16),
                  _buildChartCard('Số bước (7 ngày)', _buildMetricLineChart(_steps.map((e) => MapEntry(e.timestamp, e.value ?? 0)).toList(), Colors.green, 'steps')),
                  const SizedBox(height: 16),
                  _buildChartCard('Nhịp tim (bpm)', _buildMetricLineChart(_heartRates.map((e) => MapEntry(e.timestamp, e.value ?? 0)).toList(), Colors.red, 'bpm')),
                  const SizedBox(height: 16),
                  _buildChartCard('Nước uống (ml)', _buildMetricLineChart(_waters.map((e) => MapEntry(e.timestamp, e.value ?? 0)).toList(), Colors.cyan, 'ml')),
                  const SizedBox(height: 16),
                  _buildChartCard('Đường huyết (mg/dL)', _buildMetricLineChart(_glucose.map((e) => MapEntry(e.timestamp, e.value ?? 0)).toList(), Colors.purple, 'mg/dL')),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildChartCard(String title, Widget child) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(height: 220, child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart({required List<double> values, required Color color, required String unit}) {
    if (values.isEmpty || values.every((v) => v == 0)) {
      return const Center(child: Text('Chưa có dữ liệu'));
    }

    final spots = values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    final rawMax = values.reduce((a, b) => a > b ? a : b) * 1.2;
    final maxY = rawMax < 1 ? 1.0 : rawMax.toDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, meta) {
              return Text('${v.toInt()} $unit', style: const TextStyle(fontSize: 10));
            }),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= values.length) return const Text('');
                return Text('${idx + 1}', style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: color.withAlpha(40)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricLineChart(List<MapEntry<DateTime,double>> points, Color color, String unit) {
    if (points.isEmpty) return const Center(child: Text('Chưa có dữ liệu'));
    points.sort((a,b) => a.key.compareTo(b.key));
    final spots = points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList();
    final values = points.map((e) => e.value).toList();
    final rawMax = values.reduce((a,b) => a>b?a:b) * 1.2;
    final maxY = rawMax < 1 ? 1.0 : rawMax.toDouble();
    return LineChart(LineChartData(
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, meta) {
          return Text('${v.toInt()} $unit', style: const TextStyle(fontSize: 10));
        })),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
          final idx = value.toInt();
          if (idx < 0 || idx >= points.length) return const Text('');
          final date = points[idx].key;
          return Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10));
        })),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: color, barWidth: 3, dotData: FlDotData(show: true), belowBarData: BarAreaData(show: true, color: color.withAlpha(40)))],
    ));
  }
}


