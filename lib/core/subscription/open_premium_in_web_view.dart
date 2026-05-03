import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/constants/app_constants.dart';
import 'package:smart_learn/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/features/web_view/presentation/helpers/hvui_web_session.dart';
import 'package:smart_learn/router/route_names.dart';

const String _kPremiumWebPath = '/premium';

String premiumUpgradePageFullUrl() => '$kWebBaseUrl$_kPremiumWebPath';

/// Mở trang Premium trong WebView, cùng cách tiêm session HVUI như [ProfilePage]._openWebView.
Future<void> openPremiumUpgradeInWebView(BuildContext context) async {
  Map<String, dynamic>? hvuiPayload;
  final authState = context.read<AuthBloc>().state;
  if (authState is AuthAuthenticated) {
    hvuiPayload = await buildHvuiSessionPayload(
      user: authState.user,
      local: getIt<AuthLocalDatasource>(),
    );
  }

  if (!context.mounted) return;

  context.pushNamed(
    RouteNames.webView,
    extra: <String, dynamic>{
      'url': premiumUpgradePageFullUrl(),
      'title': 'Nâng cấp Premium',
      'hvui_session_payload': ?hvuiPayload,
    },
  );
}
