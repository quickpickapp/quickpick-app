import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:quickpick/google/google_sign_in.dart';
import 'package:quickpick/localization/locale_notifier.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/notification/notification.dart';
import 'package:quickpick/product/base/page.dart';
import 'package:quickpick/product/profile/profile_language_state.dart';
import 'package:quickpick/product/signup/signup_name_page.dart';
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

class _QuickPickAppState extends State<QuickPickApp> with WidgetsBindingObserver {
  bool _initialized = false;

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
                    ProfileLanguageState(languageSnapshot.data ?? "de")),
          ],
          child: LocaleBuilder(
            builder: (locale) => MaterialApp(
              title: 'QuickPick',
              theme: ThemeData(
                useMaterial3: true,
                primaryColor: Colors.black,
                colorScheme: ColorScheme.light(
                    primary: Color(0xFF2196F3), surface: Color(0xFFE8E8E8)),
              ),
              home: Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    checkInitialization(context);
                  });
                  return SignupNamePage();//ProductPage(key: _productPageKey);
                },
              ),
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
    final language = await storage.read(key: "language") ?? "de";
    return language;
  }

  void checkInitialization(context) async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await QuickPickStatistic().keep(context);
    await checkAuthorization(context);
  }

  Future<void> checkAuthorization(context) async {
    const storage = FlutterSecureStorage();
    var email = await storage.read(key: "email");
    if (email == null) {
      return;
    }
    await Request.get(url: "/authorized/").send(context);
  }
}
