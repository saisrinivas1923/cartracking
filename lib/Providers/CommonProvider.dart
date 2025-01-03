import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false; // Manual dark mode toggle

  bool get isDarkMode => _isDarkMode;

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeMode get themeMode {
    // If manual dark mode is toggled, use it; otherwise, follow system theme
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

class CurrentIndexProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}