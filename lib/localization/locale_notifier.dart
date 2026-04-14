import 'package:flutter/cupertino.dart';
import 'package:quickpick/localization/locale_preference.dart';

part 'locale_builder.dart';

class LocaleNotifier extends InheritedWidget {
  final _LocaleBuilderState? state;

  const LocaleNotifier({super.key, 
    this.state,
    required super.child,
  });

  static LocaleNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleNotifier>();
  }

  change(String lng) => state!.changeLocale(lng);

  Locale? get locale => state!.locale;

  @override
  bool updateShouldNotify(LocaleNotifier oldWidget) => true;
}
