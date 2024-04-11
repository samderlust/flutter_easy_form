import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

class EzyFormArrayProvider<T> extends InheritedNotifier<FormArrayControl<T>> {
  const EzyFormArrayProvider({
    super.key,
    required super.child,
    required super.notifier,
  });

  static FormArrayControl<T> of<T>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<EzyFormArrayProvider<T>>();

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
  bool updateShouldNotify(EzyFormArrayProvider<T> oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
