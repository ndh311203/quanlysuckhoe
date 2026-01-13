import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/google_fit_service.dart';
import '../services/health_data_service.dart';
import '../models/health_data.dart';
import '../services/health_metric_service.dart';
import '../models/health_metric.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useGoogleFit = false;
  final _strideController = TextEditingController(text: '0.78');
  bool _isLoading = true;
  // additional settings
  bool _enableNotifications = true;
  bool _remindWater = true;
  bool _remindExercise = false;
  bool _darkMode = false;
  String _language = 'Tiếng Việt';
  String _unit = 'metric';
  bool _appLockEnabled = false;
  final _pinController = TextEditingController();
  String? _username;

  @override
  void initState() {
    super.initState();
    _load();
    _loadAll();
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

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableNotifications = prefs.getBool('enable_notifications') ?? true;
      _remindWater = prefs.getBool('remind_water') ?? true;
      _remindExercise = prefs.getBool('remind_exercise') ?? false;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _language = prefs.getString('language') ?? 'Tiếng Việt';
      _unit = prefs.getString('unit') ?? 'metric';
      _appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
      _username = prefs.getString('username');
      _isLoading = false;
    });
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_notifications', _enableNotifications);
    await prefs.setBool('remind_water', _remindWater);
    await prefs.setBool('remind_exercise', _remindExercise);
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setString('language', _language);
    await prefs.setString('unit', _unit);
    await prefs.setBool('app_lock_enabled', _appLockEnabled);
    if (_pinController.text.isNotEmpty) {
      await prefs.setString('app_lock_pin', _pinController.text);
    }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu toàn bộ cài đặt')));
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
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Account
          Card(
            child: ListTile(
              title: const Text('👤 Tài khoản'),
              subtitle: Text(_username ?? 'Chưa đăng nhập'),
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'logout') {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('logged_in');
                    await prefs.remove('username');
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  } else if (v == 'profile') {
                    Navigator.pushNamed(context, '/profile');
                  } else if (v == 'password') {
                    _showChangePassword();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'profile', child: Text('Thông tin cá nhân')),
                  PopupMenuItem(value: 'password', child: Text('Đổi mật khẩu')),
                  PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Notifications
          Card(
            child: Column(
              children: [
                ListTile(title: const Text('🔔 Thông báo')),
                SwitchListTile(
                  title: const Text('Bật thông báo'),
                  value: _enableNotifications,
                  onChanged: (v) => setState(() => _enableNotifications = v),
                ),
                SwitchListTile(
                  title: const Text('Nhắc uống nước'),
                  value: _remindWater,
                  onChanged: (v) => setState(() => _remindWater = v),
                ),
                SwitchListTile(
                  title: const Text('Nhắc tập thể dục'),
                  value: _remindExercise,
                  onChanged: (v) => setState(() => _remindExercise = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Appearance
          Card(
            child: Column(
              children: [
                ListTile(title: const Text('🎨 Giao diện')),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
                ListTile(
                  title: const Text('Ngôn ngữ'),
                  trailing: DropdownButton<String>(
                    value: _language,
                    items: const [
                      DropdownMenuItem(value: 'Tiếng Việt', child: Text('Tiếng Việt')),
                      DropdownMenuItem(value: 'English', child: Text('English')),
                    ],
                    onChanged: (v) => setState(() => _language = v ?? 'Tiếng Việt'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Data health
          Card(
            child: Column(
              children: [
                ListTile(title: const Text('📊 Dữ liệu sức khoẻ')),
                ListTile(
                  title: const Text('Đơn vị đo'),
                  trailing: DropdownButton<String>(
                    value: _unit,
                    items: const [
                      DropdownMenuItem(value: 'metric', child: Text('Metric (kg, cm)')),
                      DropdownMenuItem(value: 'imperial', child: Text('Imperial (lb, in)')),
                    ],
                    onChanged: (v) => setState(() => _unit = v ?? 'metric'),
                  ),
                ),
                ListTile(
                  title: const Text('Sao lưu dữ liệu'),
                  onTap: _backupData,
                ),
                ListTile(
                  title: const Text('Xoá dữ liệu'),
                  onTap: _confirmClearData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Security
          Card(
            child: Column(
              children: [
                ListTile(title: const Text('🔒 Bảo mật')),
                SwitchListTile(
                  title: const Text('Khoá ứng dụng'),
                  value: _appLockEnabled,
                  onChanged: (v) => setState(() => _appLockEnabled = v),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Mã PIN (4 chữ số)'),
                    maxLength: 6,
                  ),
                ),
                ListTile(
                  title: const Text('Quyền riêng tư'),
                  subtitle: const Text('Xem chính sách quyền riêng tư'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // App info
          Card(
            child: Column(
              children: [
                ListTile(title: const Text('ℹ️ Thông tin ứng dụng')),
                ListTile(title: const Text('Phiên bản'), subtitle: const Text('1.0.0')),
                ListTile(title: const Text('Điều khoản'), onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              ElevatedButton(onPressed: _saveAll, child: const Text('Lưu tất cả')),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _syncGoogleFit, child: const Text('Đồng bộ Google Fit')),
            ],
          ),
          const SizedBox(height: 60),
        ],
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

  Future<void> _showChangePassword() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: TextField(controller: ctrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu mới')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('password', ctrl.text);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đổi mật khẩu')));
            Navigator.pop(ctx);
          }, child: const Text('Lưu')),
        ],
      ),
    );
  }

  Future<void> _backupData() async {
    try {
      final svc = HealthMetricService();
      await svc.initialize();
      final all = svc.getAll();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/health_metrics_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(HealthMetric.listToJson(all));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã sao lưu: ${file.path}')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi sao lưu: $e')));
    }
  }

  Future<void> _confirmClearData() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá dữ liệu'),
        content: const Text('Bạn có chắc muốn xoá toàn bộ dữ liệu sức khoẻ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xoá')),
        ],
      ),
    );
    if (ok == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('health_metrics');
      final svc = HealthMetricService();
      await svc.initialize();
      // overwrite by saving empty list
      for (final m in svc.getAll()) {
        // no-op; reinitialize will read removed key
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xoá dữ liệu')));
    }
  }
}


