import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:submee/utils/preferences.dart';

enum LogLevel {
  debug,
  warning,
  error,
}

Future<void> configureLogger() async {
  Logger.addClient(DebugLoggerClient());
  if (!kDebugMode) {
    Logger.addClient(FirebaseCrashlyticsClient(FirebaseCrashlytics.instance));
  }
}

class Logger {
  static final _clients = <LoggerClient>[];

  static void d(
    String message, {
    dynamic e,
    StackTrace? s,
  }) {
    for (final c in _clients) {
      c.onLog(
        level: LogLevel.debug,
        message: message,
        e: e,
        s: s,
      );
    }
  }

  static void w(
    String message, {
    dynamic e,
    StackTrace? s,
  }) {
    for (final c in _clients) {
      c.onLog(
        level: LogLevel.warning,
        message: message,
        e: e,
        s: s,
      );
    }
  }

  static void e(
    String message, {
    dynamic e,
    StackTrace? s,
  }) {
    for (final c in _clients) {
      c.onLog(
        level: LogLevel.error,
        message: message,
        e: e,
        s: s,
      );
    }
  }

  static void addClient(LoggerClient client) {
    _clients.add(client);
  }
}

abstract class LoggerClient {
  void onLog({
    required LogLevel level,
    required String message,
    dynamic e,
    StackTrace? s,
  });
}

/// Debug logger that just prints to console
class DebugLoggerClient implements LoggerClient {
  static final dateFormat = DateFormat('HH:mm:ss.SSS');

  String _timestamp() {
    return dateFormat.format(DateTime.now());
  }

  @override
  void onLog({
    required LogLevel level,
    required String message,
    dynamic e,
    StackTrace? s,
  }) {
    switch (level) {
      case LogLevel.debug:
        debugPrint('\x1B[94m ${_timestamp()} [DEBUG] $message \x1B[4m');
        Preferences.addLog('[DEBUG] $message');
        if (e != null) {
          debugPrint(e.toString());
        }
        if (s != null) {
          debugPrint(s.toString());
        }
        break;
      case LogLevel.warning:
        debugPrint(
          '\x1B[33m ${_timestamp()} [WARNING] $message \x1B[55m',
        );
        Preferences.addLog('[WARNING] $message');
        if (e != null) {
          debugPrint(e.toString());
        }
        if (s != null) {
          debugPrint(s.toString());
        }
        break;
      case LogLevel.error:
        debugPrint(
          '\x1B[31m ${_timestamp()} [ERROR] $message \x1B[91m',
        );
        Preferences.addLog('[ERROR] $message');
        if (e != null) {
          debugPrint(e.toString());
        }
        if (s != null) {
          debugPrint(s.toString());
        }
        break;
    }
  }
}

/// Firebase Crashlytics logger that reports errors to Firebase
class FirebaseCrashlyticsClient implements LoggerClient {
  FirebaseCrashlyticsClient(this._crashlytics);
  final FirebaseCrashlytics _crashlytics;

  @override
  void onLog({
    required LogLevel level,
    required String message,
    dynamic e,
    StackTrace? s,
  }) {
    // Only report errors to Crashlytics
    if (level == LogLevel.error) {
      // Set custom keys for better filtering in the Firebase console
      _crashlytics.setCustomKey('log_level', level.toString());
      _crashlytics.setCustomKey('error_message', message);

      // Log the message as a non-fatal issue
      _crashlytics.log(message);

      // Record the error with the provided exception and stack trace
      _crashlytics.recordError(
        e ?? message, // Use exception if available, otherwise use message
        s, // Use provided stack trace if available
        reason: message, // Include message as context
        fatal: false, // Mark as non-fatal by default
      );
    } else if (level == LogLevel.warning) {
      // Optionally log warnings as non-fatal issues
      _crashlytics.log('[WARNING] $message');

      if (e != null) {
        _crashlytics.setCustomKey('warning_message', message);
        _crashlytics.recordError(
          e,
          s,
          reason: message,
          fatal: false,
        );
      }
    } else if (level == LogLevel.debug) {
      // Optionally log debug messages
      _crashlytics.log('[DEBUG] $message');
    }
  }
}
