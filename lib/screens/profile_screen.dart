import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _birthDateController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _userService.initialize();
    final u = _userService.currentUser;
    if (u != null) {
      _nameController.text = u.displayName ?? '';
      _heightController.text = u.height?.toString() ?? '';
      _weightController.text = u.targetWeight?.toString() ?? '';
      _birthDateController.text = '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id = _userService.currentUser?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final user = User(
      id: id,
      displayName: _nameController.text.trim(),
      email: _userService.currentUser?.email,
      height: double.tryParse(_heightController.text),
      targetWeight: double.tryParse(_weightController.text),
      createdAt: _userService.currentUser?.createdAt ?? DateTime.now(),
    );
    await _userService.saveCurrentUser(user);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu hồ sơ')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // Debug: confirm this build() is used after hot reload
    // ignore: avoid_print
    print('DEBUG: ProfileScreen built, name="${_nameController.text}" gender="$_gender" birth="${_birthDateController.text}"');
    final user = _userService.currentUser;
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);
    double? bmi;
    if (height != null && weight != null && height > 0) {
      final h = height / 100.0;
      bmi = weight / (h * h);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Lưu', style: TextStyle(color: Colors.white))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_nameController.text.isNotEmpty ? _nameController.text : 'Tên người dùng', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(user?.email ?? 'Chưa có email', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Họ tên', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(labelText: 'Giới tính', prefixIcon: Icon(Icons.person_outline)),
                        items: const [
                          DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                          DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                          DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                        ],
                        onChanged: (v) => setState(() => _gender = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _birthDateController,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Ngày sinh', prefixIcon: Icon(Icons.calendar_today)),
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(context: context, initialDate: _birthDate ?? DateTime(now.year - 20), firstDate: DateTime(1900), lastDate: now);
                          if (picked != null) {
                            setState(() {
                              _birthDate = picked;
                              _birthDateController.text = DateFormat('d/M/yyyy').format(picked);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Text('Thông tin sức khỏe', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Chiều cao (cm)', prefixIcon: Icon(Icons.height)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cân nặng (kg)', prefixIcon: Icon(Icons.monitor_weight)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (bmi != null)
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chỉ số BMI: ${bmi.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(_bmiCategory(bmi)),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                const Text('Thông tin tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(user?.email ?? 'Chưa có'),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Ngày tạo tài khoản'),
                  subtitle: Text(user?.createdAt != null ? DateFormat('d/M/yyyy').format(user!.createdAt!) : 'Chưa có'),
                ),

                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/input'),
                    icon: const Icon(Icons.add),
                    label: const Text('Nhập chỉ số sức khỏe'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Phân loại: Gầy';
    if (bmi < 25) return 'Phân loại: Bình thường';
    if (bmi < 30) return 'Phân loại: Thừa cân';
    return 'Phân loại: Béo phì';
  }
}


