import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/theme/app_theme.dart';
import 'package:submee/utils/preferences.dart';

import '../utils/enum.dart';

class ThemeNotifier extends StateNotifier<AppType> {
  ThemeNotifier() : super(AppType.sublet) {
    _loadTheme();
  }

  // Load saved theme from shared preferences
  Future<void> _loadTheme() async {
    final appType = Preferences.getAppType();
    state = appType;
  }

  // Save theme to shared preferences
  Future<void> _saveTheme(AppType theme) async {
    switch (theme) {
      case AppType.host:
        await Preferences.setAppType(AppType.host);
        break;
      case AppType.sublet:
        await Preferences.setAppType(AppType.sublet);
        break;
    }
  }

  // Method to change the theme
  Future<void> setTheme(AppType theme) async {
    state = theme;
    await _saveTheme(theme);
  }

  // Toggle between themes
  Future<void> toggleTheme() async {
    state = state == AppType.sublet ? AppType.host : AppType.sublet;
    await _saveTheme(state);
  }

  Future<void> toggleHostTheme() async {
    state = AppType.host;
    await _saveTheme(AppType.host);
  }

  Future<void> toggleUserTheme() async {
    state = AppType.sublet;
    await _saveTheme(AppType.sublet);
  }
}

// Create our provider
final themeProvider = StateNotifierProvider<ThemeNotifier, AppType>((ref) {
  return ThemeNotifier();
});

// Create a provider that returns the actual ThemeData based on the current theme state
final themeDataProvider = Provider<ThemeData>((ref) {
  final appType = ref.watch(themeProvider);
  return AppTheme.getTheme(type: appType);
});
