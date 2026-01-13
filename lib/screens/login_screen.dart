import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;
    await Future.delayed(const Duration(milliseconds: 300));
    // For demo store credentials locally (NOT for production)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', true);
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Tên đăng nhập')),
            const SizedBox(height: 12),
            TextFormField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Đăng nhập'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


