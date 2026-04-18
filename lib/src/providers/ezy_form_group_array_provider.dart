import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

class EzyFormGroupArrayProvider
    extends InheritedNotifier<FormGroupArray> {
  const EzyFormGroupArrayProvider({
    super.key,
    required super.child,
    required super.notifier,
  });

  static FormGroupArray of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<EzyFormGroupArrayProvider>();

    if (provider == null) {
      throw StateError(
        'No EzyFormGroupArrayProvider found in context. '
        'Use EzyFormGroupArrayControl inside an EzyFormWidget.',
      );
    }

    final notifier = provider.notifier;

    if (notifier == null) {
      throw StateError(
        'EzyFormGroupArrayProvider was created without a FormGroupArray.',
      );
    }

    return notifier;
  }

  @override
  bool updateShouldNotify(EzyFormGroupArrayProvider oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
