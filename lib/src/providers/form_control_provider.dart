import 'package:flutter/material.dart';

import '../../easy_form.dart';

class EasyFormControlProvider<T> extends InheritedNotifier<FormControl<T>> {
  const EasyFormControlProvider({
    super.key,
    required super.child,
    required super.notifier,
  });

  static FormControl<T> of<T>(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<EasyFormControlProvider<T>>();

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
  bool updateShouldNotify(EasyFormControlProvider<T> oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
