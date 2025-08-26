import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationEvent {
  NavigationEvent(this.path);
  final String path;
}

final navigationStreamProvider = StateProvider<StreamController<NavigationEvent>>((ref) {
  final controller = StreamController<NavigationEvent>.broadcast();
  ref.onDispose(() => controller.close());
  return controller;
});
