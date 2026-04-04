import 'package:quickpick/localization/locale_preference.dart';
import 'package:flutter/cupertino.dart';

part 'locale_builder.dart';

class LocaleNotifier extends InheritedWidget {
  final _LocaleBuilderState? state;

  LocaleNotifier({
    this.state,
    required Widget child,
  }) : super(child: child);

  static LocaleNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleNotifier>();
  }

  change(String lng) => state!.changeLocale(lng);

  Locale? get locale => state!.locale;

  @override
  bool updateShouldNotify(LocaleNotifier oldWidget) => true;
}
