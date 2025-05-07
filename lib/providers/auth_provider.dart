// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../utils/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;
  final DatabaseHelper _db = DatabaseHelper();
  User? _user;
  String? _lastError;

  User? get user => _user;
  bool get isAuth => _user != null;
  String? get lastError => _lastError;

  Future<bool> login(String email, String password) async {
    _lastError = null;

    // 1) Try local
    final localUser = await _db.getUser(email, password);
    if (localUser != null) {
      _user = localUser;
      await _saveToPrefs(localUser);
      notifyListeners();
      return true;
    }

    // 2) Remote
    final res = await _api.post('auth/login', body: {
      'username': email,
      'password': password,
    });

    if (res.success) {
      final data = res.body;
      final usr = User.fromMap({
        'id': data['id'],
        'name': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
        'email': data['email'] ?? email,
        'password': password,
      });
      _user = usr;
      await _db.insertUser(usr);
      await _saveToPrefs(usr);
      notifyListeners();
      return true;
    } else {
      _lastError = res.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(User u) async {
    _lastError = null;

    // 1) Prevent duplicate local
    if (await _db.checkUserExists(u.email)) {
      _lastError = 'User already exists locally';
      notifyListeners();
      return false;
    }

    // 2) Remote
    final res = await _api.post('users/add', body: {
      'firstName': u.name.split(' ').first,
      'lastName': u.name.split(' ').length > 1
          ? u.name.split(' ').sublist(1).join(' ')
          : '',
      'age': 0,
      'username': u.email,
      'password': u.password,
      'email': u.email,
    });

    if (res.success && res.body['id'] != null) {
      final data = res.body;
      final usr = User.fromMap({
        'id': data['id'],
        'name': u.name,
        'email': data['email'] ?? u.email,
        'password': u.password,
      });
      _user = usr;
      await _db.insertUser(usr);
      await _saveToPrefs(usr);
      notifyListeners();
      return true;
    } else {
      _lastError = res.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> _saveToPrefs(User u) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', u.id!);
    await prefs.setString('userName', u.name);
  }
}
