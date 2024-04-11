import 'package:flutter/material.dart';

import '../../easy_form.dart';

class EasyFormProvider extends InheritedNotifier<FormGroup> {
  const EasyFormProvider({
    super.key,
    required super.child,
    required super.notifier,
  });

  static FormGroup of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<EasyFormProvider>();

    if (provider == null) {
      throw Exception("No Provider found in context");
    }

    final notifier = provider.notifier;

    if (notifier == null) {
      throw Exception("No notifier found in Provider");
    }

    return notifier;
  }

  @override
  bool updateShouldNotify(EasyFormProvider oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
