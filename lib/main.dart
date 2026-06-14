import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:quickpick/crypto/crypto.dart';
import 'package:quickpick/localization/locale_notifier.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/notification/notification.dart';
import 'package:quickpick/product/base/page.dart';
import 'package:quickpick/product/profile/profile_language_state.dart';
import 'package:quickpick/product/profile/profile_theme_state.dart';
import 'package:quickpick/product/signup/signup_legal_page.dart';
import 'package:quickpick/product/signup/signup_phone_page.dart';
import 'package:quickpick/request/request.dart';
import 'package:quickpick/statistic/statistic.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Locales.init(["de", "en"]);
  await QuickPickNotification(navigatorKey: navigatorKey).setup();
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
    return FutureBuilder<({String language, String theme})>(
      future: _loadPreferences(),
      builder:
          (context, AsyncSnapshot<({String language, String theme})> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final language = snapshot.data?.language ?? "de";
        final theme = snapshot.data?.theme ?? "light";
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => ProfileLanguageState(language),
            ),
            ChangeNotifierProvider(
              create: (_) => ProfileThemeState(theme),
            ),
          ],
          child: Consumer<ProfileThemeState>(
            builder: (context, themeState, _) => LocaleBuilder(
              builder: (locale) => MaterialApp(
                title: 'QuickPick',
                themeMode: themeState.themeMode,
                theme: ThemeData(
                    useMaterial3: true,
                    primaryColor: Colors.black,
                    colorScheme: ColorScheme.light(
                      primary: Colors.indigo,
                      surface: Color(0xFFE8E8E8),
                    ),
                    appBarTheme: AppBarTheme(
                      backgroundColor: Colors.white,
                    ),
                    bottomNavigationBarTheme: BottomNavigationBarThemeData(
                      backgroundColor: Colors.white,
                    ),
                    scaffoldBackgroundColor: Color(0xFFFAFAFA),
                    dividerColor: Colors.black12),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  primaryColor: Colors.white,
                  colorScheme: ColorScheme.dark(
                    primary: Colors.indigoAccent,
                    surface: Color(0xFF1E1E1E),
                    surfaceContainerHighest: Color(0xFF2A2A2A),
                  ),
                  appBarTheme: AppBarTheme(
                    backgroundColor: Color(0xFF2A2A2A),
                  ),
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    backgroundColor: Color(0xFF2A2A2A),
                  ),
                  scaffoldBackgroundColor: Color(0xFF1B1B1B),
                  dividerColor: Color(0xFF3B3B3B),
                ),
                home: AppRouter(),
                debugShowCheckedModeBanner: false,
                localizationsDelegates: Locales.delegates,
                supportedLocales: Locales.supportedLocales,
                locale: locale,
                navigatorKey: navigatorKey,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<({String language, String theme})> _loadPreferences() async {
    const storage = FlutterSecureStorage();
    final language = await storage.read(key: "language") ??
        PlatformDispatcher.instance.locale.languageCode;
    final theme = await storage.read(key: "theme") ??
        (PlatformDispatcher.instance.platformBrightness == Brightness.dark
            ? "dark"
            : "light");
    return (language: language, theme: theme);
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  late final Future<({bool isAuthorized, bool legalAccepted})> _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = _initialize();
  }

  Future<({bool isAuthorized, bool legalAccepted})> _initialize() async {
    await Crypto().ensureKeyPair();
    await QuickPickStatistic().keep(context);
    const storage = FlutterSecureStorage();
    final legalAccepted = await storage.read(key: "legal_accepted") == "true";
    final isAuthorized = await _isAuthorized();
    return (isAuthorized: isAuthorized, legalAccepted: legalAccepted);
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
    return FutureBuilder<({bool isAuthorized, bool legalAccepted})>(
      future: _authFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary)),
          );
        }

        final data = snapshot.data;
        if (data == null || !data.isAuthorized) {
          return data?.legalAccepted == true
              ? SignupPhonePage()
              : SignupLegalPage();
        }
        return ProductPage();
      },
    );
  }
}
