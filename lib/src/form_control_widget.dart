import 'package:ezy_form/easy_form.dart';
import 'package:flutter/material.dart';

import 'providers/ezy_form_provider.dart';
import 'providers/form_control_provider.dart';

/// A widget to consume a [FormControl]
///
/// [EzyFormControl] must be placed within a [EzyFormWidget].
///
/// This widget takes a builder which is responsible for building the widget
/// tree for the [FormControl]. The builder is called with the [BuildContext]
/// and the [FormControl] of the group.
///
/// The [formControlName] is the name of the [FormControl] to consume.
class EzyFormControl<TFC> extends StatelessWidget {
  const EzyFormControl({
    super.key,
    required this.builder,
    required this.formControlName,
  });
  final Widget Function(BuildContext context, FormControl<TFC> control) builder;
  final String formControlName;

  @override
  Widget build(BuildContext context) {
    final formGroup = EzyFormProvider.of(context);

    return EzyFormControlProvider(
      notifier: formGroup.control<TFC>(formControlName),
      child: Builder(builder: (childContext) {
        return builder(
          context,
          EzyFormControlProvider.of(childContext),
        );
      }),
    );
  }
}
