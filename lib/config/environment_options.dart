import 'package:flutter/foundation.dart';

class EnvironmentOptions {
  static const String _environmentParameter =
      String.fromEnvironment("ENVIRONMENT");
  static const QuickPickEnvironment environment =
      kIsWeb && _environmentParameter == "STAGING"
          ? QuickPickEnvironment.staging
          : QuickPickEnvironment.production;
}

enum QuickPickEnvironment {
  production("quickpick-app.com", "quickpick.lukasbreuer.de"),
  staging("", "");

  const QuickPickEnvironment(this._domain, this._endpoint);

  final String _domain;
  final String _endpoint;

  String get domain => _domain;

  String get endpoint => _endpoint;
}
