import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_learn/app/app.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/config/app_flavor.dart';

Future<void> mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppFlavorConfig.init();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi'),
      startLocale: const Locale('vi'),
      child: const App(),
    ),
  );
}
