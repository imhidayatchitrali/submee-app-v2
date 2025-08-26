import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/providers/environment_service.dart';
import 'package:submee/widgets/handlers/helper_modal_checker.dart';

import 'generated/l10n.dart';
import 'providers/router_providers.dart';
import 'providers/state_providers.dart';
import 'providers/theme_provider.dart';
import 'widgets/handlers/navigation_handler.dart';
import 'widgets/handlers/version_handler.dart';
import 'widgets/hidden_gesture_detector.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
    ref.watch(environmentService);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);
    final themeData = ref.watch(themeDataProvider);
    return NavigationHandler(
      child: MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: locale,
        supportedLocales: S.delegate.supportedLocales,
        home: VersionChecker(
          child: HiddenGestureDetector(
            child: Container(
              child: MaterialApp.router(
                theme: themeData,
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                locale: locale,
                supportedLocales: S.delegate.supportedLocales,
                routerConfig: router.router,
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  return HelperModalChecker(child: child ?? const SizedBox());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
