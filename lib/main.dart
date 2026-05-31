import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:quickpick/crypto/crypto.dart';
import 'package:quickpick/google/google_sign_in.dart';
import 'package:quickpick/localization/locale_notifier.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/notification/notification.dart';
import 'package:quickpick/product/base/page.dart';
import 'package:quickpick/product/profile/profile_language_state.dart';
import 'package:quickpick/product/signup/signup_legal_page.dart';
import 'package:quickpick/request/request.dart';
import 'package:quickpick/statistic/statistic.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Locales.init(["de", "en"]);
  await QuickPickNotification(navigatorKey: navigatorKey).setup();
  await QuickPickGoogleSignIn().setup();
  runApp(QuickPickApp());
}

class QuickPickApp extends StatefulWidget {
  const QuickPickApp({super.key});

  @override
  State<QuickPickApp> createState() => _QuickPickAppState();
}

class _QuickPickAppState extends State<QuickPickApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return FutureBuilder<String>(
      future: findLanguage(),
      builder: (context, AsyncSnapshot<String> languageSnapshot) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) =>
                  ProfileLanguageState(languageSnapshot.data ?? "de"),
            ),
          ],
          child: LocaleBuilder(
            builder: (locale) => MaterialApp(
              title: 'QuickPick',
              theme: ThemeData(
                useMaterial3: true,
                primaryColor: Colors.black,
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF2196F3),
                  surface: Color(0xFFE8E8E8),
                ),
              ),
              home: AppRouter(),
              debugShowCheckedModeBanner: false,
              localizationsDelegates: Locales.delegates,
              supportedLocales: Locales.supportedLocales,
              locale: locale,
              navigatorKey: navigatorKey,
            ),
          ),
        );
      },
    );
  }

  Future<String> findLanguage() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: "language") ?? "de";
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  late final Future<bool> _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = _initialize();
  }

  Future<bool> _initialize() async {
    await Crypto().ensureKeyPair();
    await QuickPickStatistic().keep(context);
    return await _isAuthorized();
  }

  Future<bool> _isAuthorized() async {
    const storage = FlutterSecureStorage();
    final user = await storage.read(key: "user");
    if (user == null) {
      return false;
    }
    final response = await Request.get(url: "/authorized/").send(context);
    return response != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAuthorized = snapshot.data ?? false;
        return isAuthorized ? ProductPage() : SignupLegalPage();
      },
    );
  }
}
