import 'package:easy_form/easy_form.dart';
import 'package:flutter/material.dart';

import 'providers/easy_form_provider.dart';
import 'providers/form_control_provider.dart';

/// A widget to consume a [FormControl]
///
/// [EasyFormControl] must be placed within a [EasyFormWidget].
///
/// This widget takes a builder which is responsible for building the widget
/// tree for the [FormControl]. The builder is called with the [BuildContext]
/// and the [FormControl] of the group.
///
/// The [formControlName] is the name of the [FormControl] to consume.
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
    final formGroup = EasyFormProvider.of(context);

    return EasyFormControlProvider(
      notifier: formGroup.control<TFC>(formControlName),
      child: Builder(builder: (childContext) {
        return builder(
          context,
          EasyFormControlProvider.of(childContext),
        );
      }),
    );
  }
}
