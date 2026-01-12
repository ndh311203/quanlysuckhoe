import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/google_fit_service.dart';
import '../services/health_data_service.dart';
import '../models/health_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useGoogleFit = false;
  final _strideController = TextEditingController(text: '0.78');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useGoogleFit = prefs.getBool('use_google_fit') ?? false;
      final s = prefs.getDouble('stride_length_m') ?? 0.78;
      _strideController.text = s.toString();
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final stride = double.tryParse(_strideController.text) ?? 0.78;
    await prefs.setBool('use_google_fit', _useGoogleFit);
    await prefs.setDouble('stride_length_m', stride);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu cài đặt')));
    }
  }

  @override
  void dispose() {
    _strideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Sử dụng Google Fit để lấy bước chân'),
              value: _useGoogleFit,
              onChanged: (v) => setState(() => _useGoogleFit = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _strideController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Chiều dài bước (m)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(onPressed: _save, child: const Text('Lưu cài đặt')),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _useGoogleFit ? _syncGoogleFit : null,
                  child: const Text('Đồng bộ Google Fit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncGoogleFit() async {
    final svc = GoogleFitService();
    final healthSvc = HealthDataService();
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
      final map = await svc.syncFromGoogleFit(start, now);
      for (final entry in map.entries) {
        final date = entry.key;
        final steps = entry.value;
        final existing = await healthSvc.getHealthDataForDate(date);
        final hd = HealthData(date: date, steps: steps, water: existing.water);
        await healthSvc.saveHealthData(hd);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đồng bộ Google Fit')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi đồng bộ: $e')));
      }
    }
  }
}


