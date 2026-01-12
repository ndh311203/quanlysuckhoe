import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const String _currentUserKey = 'current_user';

  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_currentUserKey);
    if (jsonStr != null) {
      _currentUser = User.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    }
  }

  Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = user;
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = null;
    await prefs.remove(_currentUserKey);
  }
}


