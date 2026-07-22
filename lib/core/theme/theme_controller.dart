import 'package:flutter/material.dart';

import '../storage/secure_storage_service.dart';

/// Holds the user's light/dark preference (toggled from Profile) and
/// persists it - a device/UI preference, not session state, so it
/// survives logout (see `SecureStorageService.clear()`).
class ThemeController extends ChangeNotifier {
  final SecureStorageService _secureStorage;

  ThemeMode _mode = ThemeMode.light;

  ThemeController({required SecureStorageService secureStorage}) : _secureStorage = secureStorage;

  ThemeMode get mode => _mode;
  bool get isDarkMode => _mode == ThemeMode.dark;

  /// Reads the persisted preference, if any. Defaults to light (set
  /// synchronously above) until this resolves, so the very first frame
  /// doesn't have to wait on it.
  Future<void> loadSaved() async {
    final saved = await _secureStorage.readThemeMode();
    if (saved == 'dark') {
      _mode = ThemeMode.dark;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode(bool enabled) async {
    _mode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _secureStorage.saveThemeMode(enabled ? 'dark' : 'light');
  }
}
