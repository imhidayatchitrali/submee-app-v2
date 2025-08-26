import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:submee/models/property_filters.dart';
import 'package:submee/utils/enum.dart';

import '../models/sublet_filters.dart';

class Preferences {
  factory Preferences() => _instancia;
  Preferences._internal();
  static final Preferences _instancia = Preferences._internal();
  static late SharedPreferences _prefs;
  static const platform = MethodChannel('packageInfo');
  static String? _version;
  static String? _buildNumber;
  static String? timezone;
  static Future<void> init([bool background = false]) async {
    _prefs = await SharedPreferences.getInstance();
    if (!background) {
      final buildNum = await platform.invokeMethod('getBuildNumber');
      _buildNumber = buildNum.toString().contains('.') ? '1' : buildNum.toString();
      _version = await platform.invokeMethod('getVersionNumber');
      timezone = await platform.invokeMethod('getTimeZoneName') as String;
    }
  }

  static String get version => _version ?? '';
  static String get buildNumber => _buildNumber ?? '1';
  static String get timeZone => timezone ?? '';

  static bool hasGetStarted() {
    return _prefs.getBool('hasSeenGetStarted') ?? false;
  }

  static Future<void> saveGetStarted() async {
    await _prefs.setBool('hasSeenGetStarted', true);
  }

  static Future<void> saveToken(String token) => _prefs.setString('auth_token', token);

  static Future<void> removeToken() => _prefs.remove('auth_token');

  static String? getToken() => _prefs.getString('auth_token');

  static Future<void> signout() async {
    await _prefs.remove('auth_token');
    await _prefs.setString('app_type', AppType.sublet.name);
    await _prefs.remove('user_id');
  }

  static Future<void> savePropertyFilters(PropertyFilters value) =>
      _prefs.setString('property_filters', jsonEncode(value.toJson()));

  static PropertyFilters getPropertyFilters() {
    final data = _prefs.getString('property_filters');
    if (data == null) {
      return PropertyFilters.defaultValues();
    }
    return PropertyFilters.fromJson(jsonDecode(data));
  }

  static AppType getAppType() => AppType.values.firstWhere(
        (e) => e.name == _prefs.getString('app_type'),
        orElse: () => AppType.sublet,
      );
  static Future<void> setAppType(AppType value) => _prefs.setString('app_type', value.name);

  static bool get isHost => getAppType() == AppType.host;

  static int? get userId => _prefs.getInt('user_id');
  static Future<void> setUserId(int value) => _prefs.setInt('user_id', value);

  static Future<void> saveSubletFilters(SubletFilters value) =>
      _prefs.setString('sublet_filters', jsonEncode(value.toJson()));

  static SubletFilters getSubletFilters() {
    final data = _prefs.getString('sublet_filters');
    if (data == null) {
      return SubletFilters.defaultValues();
    }
    return SubletFilters.fromJson(jsonDecode(data));
  }

  // Logs
  static List<String> get logs => _prefs.getStringList('logs') ?? [];
  static Future<void> addLog(String log) async {
    final List<String> _logs = List.from(_prefs.getStringList('logs') ?? []);
    _logs.add(log);
    if (_logs.length > 100) {
      _logs.removeAt(0);
    }
    await _prefs.setStringList('logs', _logs);
  }

  static Future<void> clearLogs() async {
    await _prefs.remove('logs');
  }
}
