import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/providers/environment_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../../models/app_version.dart';
import '../../providers/state_providers.dart';
import '../../utils/preferences.dart';

class VersionChecker extends ConsumerWidget {
  const VersionChecker({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the appVersionProvider
    final appVersionAsync = ref.watch(appVersionProvider);
    final isDevelop = ref.watch(environmentService).environment.environmentName == 'develop';
    return appVersionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => child, // Continue with the app on error
      data: (appVersion) {
        // Get the current app version from the package info
        final currentVersion = Preferences.version;

        // Check if update is needed
        if (!isDevelop && isUpdateRequired(currentVersion, appVersion.version)) {
          // Show update dialog after the widget is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showUpdateDialog(context, appVersion);
          });
        }

        // Return the app content
        return child;
      },
    );
  }

  // Helper method to check if version update is required
  bool isUpdateRequired(String currentVersion, String minimumVersion) {
    final current = currentVersion.split('.').map(int.parse).toList();
    final minimum = minimumVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (current[i] < minimum[i]) {
        return true;
      } else if (current[i] > minimum[i]) {
        return false;
      }
    }
    return false; // Versions are equal
  }

  // Show update dialog
  void _showUpdateDialog(BuildContext context, AppVersion appVersion) {
    final locale = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: !appVersion.requiredUpdate,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Text(
          appVersion.message ??
              'A new version of the app is available. Please update to continue using the app.',
        ),
        actions: [
          if (!appVersion.requiredUpdate)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
          TextButton(
            onPressed: () {
              // Open app store URL
              launchUrl(Uri.parse(appVersion.downloadUrl));

              // Close the app if force update is required
              if (appVersion.requiredUpdate) {
                SystemNavigator.pop();
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(locale.update_now),
          ),
        ],
      ),
    );
  }
}
