import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/health_data_service.dart';
import '../models/health_data.dart';
import '../services/health_metric_service.dart';
import '../models/health_metric.dart';

class HealthInputScreen extends StatefulWidget {
  const HealthInputScreen({super.key});

  @override
  State<HealthInputScreen> createState() => _HealthInputScreenState();
}

class _HealthInputScreenState extends State<HealthInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepsController = TextEditingController();
  final _waterController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _hrController = TextEditingController();
  final _kmController = TextEditingController();

  final _service = HealthDataService();
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _stepsController.dispose();
    _waterController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _hrController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Determine steps: prefer km if provided, otherwise use steps input
    int steps = int.tryParse(_stepsController.text) ?? 0;
    final kmVal = double.tryParse(_kmController.text);
    if (kmVal != null && kmVal > 0) {
      // read stride from prefs (default 0.78 m)
      final prefs = await SharedPreferences.getInstance();
      final stride = prefs.getDouble('stride_length_m') ?? 0.78;
      steps = (kmVal * 1000 / stride).round();
    }

    final data = HealthData(
      date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
      steps: steps,
      water: double.tryParse(_waterController.text) ?? 0,
    );

    try {
      await _service.saveHealthData(data);
      // also write metric entries for weight, water, steps, height, heart rate for historical charts
      try {
        final metricService = HealthMetricService();
        await metricService.initialize();
        final metricTimestamp = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        final weightVal = double.tryParse(_weightController.text);
        if (weightVal != null && weightVal > 0) {
          await metricService.addMetric(HealthMetric(id: DateTime.now().millisecondsSinceEpoch.toString(), type: MetricType.weight, value: weightVal, timestamp: metricTimestamp));
        }
        final heightVal = double.tryParse(_heightController.text);
        if (heightVal != null && heightVal > 0) {
          await metricService.addMetric(HealthMetric(id: (DateTime.now().millisecondsSinceEpoch+1).toString(), type: MetricType.height, value: heightVal, timestamp: metricTimestamp));
        }
        final hrVal = double.tryParse(_hrController.text);
        if (hrVal != null && hrVal > 0) {
          await metricService.addMetric(HealthMetric(id: (DateTime.now().millisecondsSinceEpoch+2).toString(), type: MetricType.heartRate, value: hrVal, timestamp: metricTimestamp));
        }
        final waterVal = double.tryParse(_waterController.text);
        if (waterVal != null && waterVal > 0) {
          await metricService.addMetric(HealthMetric(id: (DateTime.now().millisecondsSinceEpoch+3).toString(), type: MetricType.water, value: waterVal, timestamp: metricTimestamp));
        }
        if (steps > 0) {
          await metricService.addMetric(HealthMetric(id: (DateTime.now().millisecondsSinceEpoch+4).toString(), type: MetricType.steps, value: steps.toDouble(), timestamp: metricTimestamp));
        }
      } catch (e) {
        // ignore metric sync errors but log for debugging
        // ignore: avoid_print
        print('DEBUG: failed to sync metrics: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu dữ liệu sức khỏe')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi lưu dữ liệu: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập chỉ số sức khỏe'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Ngày'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stepsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số bước (steps)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kmController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Quãng đường (km) — sẽ chuyển thành bước'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _waterController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nước (ml)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Chiều cao (cm)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hrController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nhịp tim (bpm)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cân nặng (kg)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



