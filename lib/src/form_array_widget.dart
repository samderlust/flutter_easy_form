import 'package:ezy_form/src/providers/ezy_form_array_provider.dart';
import 'package:flutter/material.dart';

import '../ezy_form.dart';
import 'providers/ezy_form_provider.dart';

/// A widget to consume a [FormArrayControl].
///
/// [EzyFormArrayControl] must be placed within a [EzyFormWidget].
///
/// This widget takes a builder which is responsible for building the widget
/// tree for the [FormArrayControl]. The builder is called with the
/// [BuildContext] and the [FormArrayControl] of the group.
///
/// The [formControlName] is the name of the [FormArrayControl] to consume.
class EzyFormArrayControl<TFC> extends StatelessWidget {
  const EzyFormArrayControl({
    super.key,
    required this.builder,
    required this.formControlName,
  });
  final Widget Function(
      BuildContext context, FormArrayControl<TFC> arrayControl) builder;
  final String formControlName;

  @override
  Widget build(BuildContext context) {
    final formGroup = EzyFormProvider.of(context);
    final formArray = formGroup.arrayControl<TFC>(formControlName);

    return EzyFormArrayProvider<TFC>(
      notifier: formArray,
      child: Builder(builder: (acontext) {
        final arrayCtrl = EzyFormArrayProvider.of<TFC>(acontext);

        return builder(context, arrayCtrl);
      }),
    );
  }
}
