import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App environment flavors.
enum Flavor { dev, staging, production }

/// Runtime flavor configuration resolved from `--dart-define` + `.env` file.
class AppFlavorConfig {
  AppFlavorConfig._();

  static late final Flavor flavor;

  /// Initialize flavor and load the corresponding `.env` file.
  static Future<void> init() async {
    const flavorStr = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    flavor = Flavor.values.firstWhere(
      (f) => f.name == flavorStr,
      orElse: () => Flavor.dev,
    );

    await dotenv.load(fileName: 'assets/env/.env.${flavor.name}');
  }

  // ─── Env getters ───

  static String get apiBaseUrl => dotenv.get('API_BASE_URL');

  static String get appName => dotenv.get('APP_NAME', fallback: 'Smart Learn');

  static bool get enableLogging =>
      dotenv.get('ENABLE_LOGGING', fallback: 'false') == 'true';

  static String get sentryDsn => dotenv.get('SENTRY_DSN', fallback: '');

  // ─── Flavor checks ───

  static bool get isDev => flavor == Flavor.dev;
  static bool get isStaging => flavor == Flavor.staging;
  static bool get isProduction => flavor == Flavor.production;
}
