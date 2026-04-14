import 'dart:async';

import 'package:flutter/foundation.dart';

/// Converts a [Stream] into a [ChangeNotifier] for use with
/// GoRouter's `refreshListenable` parameter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
