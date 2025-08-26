import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:submee/providers/router_providers.dart';
import 'package:submee/utils/logger.dart';

import '../../providers/modal_helper_provider.dart';
import '../banners/simple_helper_modal.dart';

class HelperModalChecker extends ConsumerStatefulWidget {
  const HelperModalChecker({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  ConsumerState<HelperModalChecker> createState() => _HelperModalCheckerState();
}

class _HelperModalCheckerState extends ConsumerState<HelperModalChecker> {
  GoRouter? _router;
  final _routeListener = RouteListener();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initial fetch of helpers
      ref.read(helperModalProvider.notifier).fetchUnseenHelpers();

      // Set up the router listener
      _setupRouterListener();

      // Set up periodic refresh
      _setupPeriodicRefresh();
    });
  }

  void _setupPeriodicRefresh() {
    // Refresh helpers every 30 minutes (adjust as needed)
    _refreshTimer = Timer.periodic(const Duration(minutes: 20), (_) {
      ref.read(helperModalProvider.notifier).refreshHelpers();
    });
  }

  void _setupRouterListener() {
    final router = ref.read(routerProvider).router;
    _router = router;

    // Add a listener to the routeInformationProvider
    router.routeInformationProvider.addListener(_onRouteChange);

    // Initial check for the current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final path = router.routeInformationProvider.value.uri.path;
      _checkForHelperOnRouteChange(path);
    });
  }

  void _onRouteChange() {
    if (_router != null) {
      final path = _router!.routeInformationProvider.value.uri.path;
      Logger.d('Route changed to: $path');

      // Check if the path has actually changed (to avoid duplicate checks)
      if (_routeListener.hasPathChanged(path)) {
        // Consider refreshing helpers on significant navigation events
        // For example, if navigating to a home screen or after completing a flow
        if (_isSignificantNavigation(path)) {
          ref.read(helperModalProvider.notifier).refreshHelpers();
        }

        _checkForHelperOnRouteChange(path);
      }
    }
  }

  bool _isSignificantNavigation(String path) {
    // Define routes that should trigger a refresh
    // For example, returning to home screen or completing a workflow
    return path == '/' || path == '/home' || path == '/dashboard';
  }

  @override
  void dispose() {
    // Clean up the listener and timer
    _router?.routeInformationProvider.removeListener(_onRouteChange);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(helperModalProvider, (previous, current) {
      // Only process when loading is complete and we have helpers
      if (!current.isLoading && previous?.isLoading == true && current.unseenHelpers.isNotEmpty) {
        // Check the current route when helpers are loaded
        if (_router != null) {
          _checkForHelperOnRouteChange(_router!.routeInformationProvider.value.uri.path);
        }
      }
    });

    return widget.child;
  }

  void _checkForHelperOnRouteChange(String path) {
    if (!mounted) return;

    final currentState = ref.read(helperModalProvider);

    // If there are unseen helpers and we're not currently loading
    if (!currentState.isLoading && currentState.unseenHelpers.isNotEmpty) {
      Logger.d('Checking for helpers on route: $path');

      // Check if there's a helper for this route
      final helper = ref.read(helperModalProvider.notifier).getHelperForRoute(path);

      if (helper != null) {
        ref.read(helperModalProvider.notifier).setHelperAsSeen(helper);
        // No need to check hasSeenHelper since getHelperForRoute now handles this
        Future.delayed(const Duration(seconds: 3), () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SimpleHelperModal(
              helperModal: helper,
              onDismiss: () async {
                await ref.read(helperModalProvider.notifier).markHelperAsSeen(helper.id);
              },
            ),
          );
        });
      }
    }
  }
}

// A simple helper class to track route changes
class RouteListener {
  String? lastPath;

  bool hasPathChanged(String newPath) {
    if (lastPath != newPath) {
      lastPath = newPath;
      return true;
    }
    return false;
  }
}
