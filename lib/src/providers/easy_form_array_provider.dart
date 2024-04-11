import 'package:easy_form/easy_form.dart';
import 'package:flutter/material.dart';

class EasyFormArrayProvider<T> extends InheritedNotifier<FormArrayControl<T>> {
  const EasyFormArrayProvider({
    super.key,
    required super.child,
    required super.notifier,
  });

  static FormArrayControl<T> of<T>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<EasyFormArrayProvider<T>>();

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
  bool updateShouldNotify(EasyFormArrayProvider<T> oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
