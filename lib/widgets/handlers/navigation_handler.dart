import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/utils/logger.dart';

import '../../providers/router_providers.dart';
import '../../services/navigation_service.dart';

class NavigationHandler extends ConsumerStatefulWidget {
  const NavigationHandler({required this.child, Key? key}) : super(key: key);
  final Widget child;

  @override
  _NavigationHandlerState createState() => _NavigationHandlerState();
}

class _NavigationHandlerState extends ConsumerState<NavigationHandler> {
  StreamSubscription<NavigationEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    // Setup the subscription after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSubscription();
    });
  }

  void _setupSubscription() {
    final streamController = ref.read(navigationStreamProvider);

    _subscription = streamController.stream.listen((event) {
      Logger.d('Navigation event listen: ${event.path}');
      final router = ref.read(routerProvider);
      if (router.router.state?.path != event.path) {
        router.router.push(event.path);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
