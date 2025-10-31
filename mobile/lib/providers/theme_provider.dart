/**
 * Theme Provider
 * 
 * Manages dark/light theme state throughout the app.
 */

import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  final StorageService _storage = StorageService();
  
  ThemeProvider() {
    _loadTheme();
  }
  
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  
  Future<void> _loadTheme() async {
    _isDarkMode = await _storage.isDarkMode();
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storage.setDarkMode(_isDarkMode);
    notifyListeners();
  }
  
  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _storage.setDarkMode(_isDarkMode);
    notifyListeners();
  }
}

