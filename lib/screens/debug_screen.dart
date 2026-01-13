import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Map<String, dynamic> _prefs = {};
  String _metricsJson = '';

  @override
  void initState() {
    super.initState();
    _loadDebug();
  }

  Future<void> _loadDebug() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'logged_in',
      'username',
      'enable_notifications',
      'remind_water',
      'remind_exercise',
      'dark_mode',
      'language',
      'unit',
      'app_lock_enabled',
      'app_lock_pin'
    ];
    final Map<String, dynamic> out = {};
    for (final k in keys) {
      out[k] = prefs.get(k);
    }

    String metrics = '';
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/health_metrics.json');
      if (await file.exists()) metrics = await file.readAsString();
    } catch (_) {}

    setState(() {
      _prefs = out;
      _metricsJson = metrics;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SharedPreferences', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_prefs.isEmpty ? 'No prefs loaded' : _prefs.toString()),
              const SizedBox(height: 16),
              const Text('Health metrics JSON', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_metricsJson.isEmpty ? 'No metrics file' : _metricsJson),
            ],
          ),
        ),
      ),
    );
  }
}



