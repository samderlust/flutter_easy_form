import 'package:flutter/material.dart';

import '../ezy_form.dart';
import 'providers/ezy_form_group_array_provider.dart';
import 'providers/ezy_form_provider.dart';

/// A widget to consume a [FormGroupArray].
///
/// [EzyFormGroupArrayControl] must be placed within a [EzyFormWidget].
///
/// The [formControlName] is the name of the [FormGroupArray] to consume.
class EzyFormGroupArrayControl extends StatelessWidget {
  const EzyFormGroupArrayControl({
    super.key,
    required this.builder,
    required this.formControlName,
  });

  final Widget Function(
      BuildContext context, FormGroupArray groupArray) builder;
  final String formControlName;

  @override
  Widget build(BuildContext context) {
    final formGroup = EzyFormProvider.of(context);
    final groupArray = formGroup.groupArrayControl(formControlName);

    return EzyFormGroupArrayProvider(
      notifier: groupArray,
      child: Builder(builder: (innerContext) {
        final array = EzyFormGroupArrayProvider.of(innerContext);
        return builder(context, array);
      }),
    );
  }
}
