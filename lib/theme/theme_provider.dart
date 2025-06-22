import 'package:flutter/material.dart';
fix/no-complaints-message

class ThemeProvider with ChangeNotifier {
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
 main
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

 fix/no-complaints-message
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme(_isDarkMode);
    notifyListeners();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }
 main
}
