import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  bool _hapticFeedbackEnabled = true;
  bool _soundEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;

  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  bool get soundEnabled => _soundEnabled;
  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    _hapticFeedbackEnabled = _prefs.getBool('haptic_feedback') ?? true;
    _soundEnabled = _prefs.getBool('sound_enabled') ?? true;

    final themeModeString = _prefs.getString('theme_mode') ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == themeModeString,
      orElse: () => ThemeMode.system,
    );

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool enabled) async {
    _hapticFeedbackEnabled = enabled;
    await _prefs.setBool('haptic_feedback', enabled);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _prefs.setBool('sound_enabled', enabled);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString('theme_mode', mode.name);
    notifyListeners();
  }
}
