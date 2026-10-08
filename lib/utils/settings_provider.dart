import 'package:flutter/widgets.dart';

import 'settings_controller.dart';

class SettingsProvider extends InheritedNotifier<SettingsController> {
  const SettingsProvider({
    super.key,
    required SettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static SettingsController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<SettingsProvider>();
    if (provider == null) {
      throw FlutterError('SettingsProvider not found in context');
    }
    return provider.notifier!;
  }

  static SettingsController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SettingsProvider>()
        ?.notifier;
  }
}
