import 'dart:async';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/app.dart';
import 'package:submee/utils/logger.dart';
import 'package:submee/utils/preferences.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      // Ensure Flutter is initialized
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      await Firebase.initializeApp();

      // Configure Firebase Crashlytics
      final crashlytics = FirebaseCrashlytics.instance;

      // Only enable Crashlytics in non-debug mode
      if (!kDebugMode) {
        // Enable auto collection of Crashlytics reports
        await crashlytics.setCrashlyticsCollectionEnabled(true);

        // Pass all uncaught Flutter errors to Crashlytics
        FlutterError.onError = (FlutterErrorDetails details) {
          Logger.e(
            'Flutter Error: ${details.exception}',
            e: details.exception,
            s: details.stack,
          );
          crashlytics.recordFlutterError(details);
        };

        // Catch errors from the current Isolate
        Isolate.current.addErrorListener(
          RawReceivePort((pair) async {
            final List<dynamic> errorAndStacktrace = pair;
            final error = errorAndStacktrace[0];
            final stackTrace = errorAndStacktrace[1];

            Logger.e(
              'Isolate Error: $error',
              e: error,
              s: stackTrace as StackTrace,
            );
            await crashlytics.recordError(error, stackTrace);
          }).sendPort,
        );
      }

      // Initialize your logger (now it will include the Crashlytics client in production)
      await configureLogger();

      // Initialize other services
      await Preferences.init();
      await dotenv.load(fileName: 'assets/environment/local.env');

      // Run the app
      runApp(
        const ProviderScope(
          child: App(),
        ),
      );
    },
    (error, stackTrace) async {
      Logger.e(
        'Uncaught Error: ${error.toString()}',
        e: error,
        s: stackTrace,
      );
    },
  );
}
