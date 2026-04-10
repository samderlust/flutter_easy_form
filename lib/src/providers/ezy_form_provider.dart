import 'package:flutter/material.dart';

import '../../ezy_form.dart';

class EzyFormProvider extends InheritedNotifier<FormGroup> {
  const EzyFormProvider({
    super.key,
    required super.child,
    required super.notifier,
  });

  static FormGroup of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<EzyFormProvider>();

    if (provider == null) {
      throw StateError(
        'No EzyFormProvider found in context. '
        'Wrap your form fields in an EzyFormWidget.',
      );
    }

    final notifier = provider.notifier;

    if (notifier == null) {
      throw StateError('EzyFormProvider was created without a FormGroup.');
    }

    return notifier;
  }

  @override
  bool updateShouldNotify(EzyFormProvider oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
