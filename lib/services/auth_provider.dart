import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/info_models.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('logged_user');
    if (userJson != null) {
      _user = User.fromJson(jsonDecode(userJson));
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(LogInRequest request) async {
    final data = await ApiService.login(request);
    _user = User.fromJson(data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_user', jsonEncode(_user!.toJsonStorage()));
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_user');
    notifyListeners();
  }
}
