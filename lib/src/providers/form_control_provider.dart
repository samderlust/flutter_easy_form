import 'package:flutter/material.dart';

import '../../ezy_form.dart';

class EzyFormControlProvider<T> extends InheritedNotifier<FormControl<T>> {
  const EzyFormControlProvider({
    super.key,
    required super.child,
    required super.notifier,
  });

  static FormControl<T> of<T>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<EzyFormControlProvider<T>>();

    if (provider == null) {
      throw StateError(
        'No EzyFormControlProvider<$T> found in context. '
        'Use EzyFormControl<$T> inside an EzyFormWidget.',
      );
    }

    final notifier = provider.notifier;

    if (notifier == null) {
      throw StateError(
        'EzyFormControlProvider<$T> was created without a FormControl.',
      );
    }

    return notifier;
  }

  @override
  bool updateShouldNotify(EzyFormControlProvider<T> oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
