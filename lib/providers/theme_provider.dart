import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Provider for managing application theme (light/dark mode).
/// Persists theme preference to localStorage.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void _loadThemePreference() {
    _isDarkMode = StorageService.loadThemeMode();
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    StorageService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    StorageService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }
}
