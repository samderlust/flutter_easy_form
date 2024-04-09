import 'package:easy_form/easy_form.dart';
import 'package:flutter/material.dart';

import 'form_group.dart';

/// DynamicFormControl
///
/// build widget for each `FormControl` in a `FormGroup`
class EasyFormControl<TFC> extends StatelessWidget {
  const EasyFormControl({
    super.key,
    required this.builder,
    required this.formControlName,
  });
  final Widget Function(BuildContext context, FormControl<TFC> control) builder;
  final String formControlName;

  @override
  Widget build(BuildContext context) {
    final formGroup = DynamicFormProvider.of(context);

    return EasyFormProvider(
      notifier: formGroup.control<TFC>(formControlName),
      child: Builder(builder: (childContext) {
        return builder(
          context,
          EasyFormProvider.of(childContext),
        );
      }),
    );
  }
}

class EasyFormProvider<T> extends InheritedNotifier<FormControl<T>> {
  const EasyFormProvider({
    super.key,
    required super.child,
    required super.notifier,
  });

  static FormControl<T> of<T>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<EasyFormProvider<T>>();

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
  bool updateShouldNotify(EasyFormProvider<T> oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
