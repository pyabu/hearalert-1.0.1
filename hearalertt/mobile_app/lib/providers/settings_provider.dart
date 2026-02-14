import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/models.dart';



class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _vibrationKey = 'vibration_intensity';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _sensitivityKey = 'sensitivity';
  static const String _contactsKey = 'sos_contacts';
  static const String _glassKey = 'glass_intensity';
  static const String _glowKey = 'glow_brightness';
  static const String _animKey = 'animation_speed';
  static const String _highContrastKey = 'high_contrast';
  static const String _largeTextKey = 'large_text';
  static const String _screenFlashKey = 'screen_flash';
  static const String _flashlightKey = 'flashlight_enabled';
  static const String _sosMessageKey = 'sos_message';

  ThemeMode _themeMode = ThemeMode.system;
  VibrationIntensity _vibrationIntensity = VibrationIntensity.high;
  bool _notificationsEnabled = true;
  double _sensitivity = 0.5; // 0.0 to 1.0
  List<Contact> _sosContacts = [];
  Color _accentColor = const Color(0xFF3B82F6); // Default Blue
  bool _onboardingCompleted = false;
  
  // Accessibility
  bool _highContrast = false;
  bool _largeText = false;
  bool _screenFlash = true;

  // Feedback
  bool _flashlightEnabled = true;

  // Emergency
  String _sosMessage = "Help! I am deaf and in an emergency. Please assist me.";

  // Visual Experience
  double _glassIntensity = 0.1; // 0.0 to 0.5
  double _glowBrightness = 1.0; // 0.5 to 2.0
  double _animationSpeed = 1.0; // 0.5 to 2.0

  ThemeMode get themeMode => _themeMode;
  VibrationIntensity get vibrationIntensity => _vibrationIntensity;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get onboardingCompleted => _onboardingCompleted;
  double get sensitivity => _sensitivity;
  List<Contact> get sosContacts => _sosContacts;
  Color get accentColor => _accentColor;
  
  bool get highContrast => _highContrast;
  bool get largeText => _largeText;
  bool get screenFlash => _screenFlash;
  bool get flashlightEnabled => _flashlightEnabled;
  String get sosMessage => _sosMessage;

  double get glassIntensity => _glassIntensity;
  double get glowBrightness => _glowBrightness;
  double get animationSpeed => _animationSpeed;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners();
  }

  Future<void> setVibrationIntensity(VibrationIntensity intensity) async {
    _vibrationIntensity = intensity;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_vibrationKey, intensity.index);
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  Future<void> addContact(Contact contact) async {
    _sosContacts.add(contact);
    notifyListeners();
    await _saveContacts();
  }

  Future<void> removeContact(String name) async {
    _sosContacts.removeWhere((c) => c.name == name);
    notifyListeners();
    await _saveContacts();
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_sosContacts.map((c) => c.toJson()).toList());
    await prefs.setString(_contactsKey, encoded);
  }

  Future<void> setSensitivity(double value) async {
    _sensitivity = value.clamp(0.0, 1.0);
    notifyListeners();
     final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sensitivityKey, _sensitivity);
  }

  Future<void> setGlassIntensity(double value) async {
    _glassIntensity = value.clamp(0.0, 0.5);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_glassKey, _glassIntensity);
  }

  Future<void> setGlowBrightness(double value) async {
    _glowBrightness = value.clamp(0.5, 2.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_glowKey, _glowBrightness);
  }

  Future<void> setAnimationSpeed(double value) async {
    _animationSpeed = value.clamp(0.5, 2.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_animKey, _animationSpeed);
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, value);
  }

  Future<void> setLargeText(bool value) async {
    _largeText = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_largeTextKey, value);
  }

  Future<void> setScreenFlash(bool value) async {
    _screenFlash = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_screenFlashKey, value);
  }

  Future<void> toggleFlashlight() async {
    _flashlightEnabled = !_flashlightEnabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_flashlightKey, _flashlightEnabled);
  }

  Future<void> setSosMessage(String message) async {
    _sosMessage = message;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sosMessageKey, message);
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    
    // Load persisted settings
    _themeMode = ThemeMode.values[prefs.getInt(_themeKey) ?? ThemeMode.system.index];
    _vibrationIntensity = VibrationIntensity.values[prefs.getInt(_vibrationKey) ?? VibrationIntensity.high.index];
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _sensitivity = prefs.getDouble(_sensitivityKey) ?? 0.5;
    
    _highContrast = prefs.getBool(_highContrastKey) ?? false;
    _largeText = prefs.getBool(_largeTextKey) ?? false;
    _screenFlash = prefs.getBool(_screenFlashKey) ?? true;
    _flashlightEnabled = prefs.getBool(_flashlightKey) ?? true;
    
    _glassIntensity = prefs.getDouble(_glassKey) ?? 0.1;
    _glowBrightness = prefs.getDouble(_glowKey) ?? 1.0;
    _animationSpeed = prefs.getDouble(_animKey) ?? 1.0;
    _sosMessage = prefs.getString(_sosMessageKey) ?? "Help! I am deaf and in an emergency. Please assist me.";

    final contactsJson = prefs.getString(_contactsKey);
    if (contactsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(contactsJson);
        _sosContacts = decoded.map((item) => Contact.fromJson(item)).toList();
      } catch (e) {
        debugPrint("Error loading contacts: $e");
      }
    }
    
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }
}
