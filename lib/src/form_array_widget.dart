import 'package:easy_form/src/providers/easy_form_array_provider.dart';
import 'package:flutter/material.dart';

import '../easy_form.dart';
import 'providers/easy_form_provider.dart';

/// A widget to consume a [FormArrayControl].
///
/// [EasyFormArrayControl] must be placed within a [EasyFormWidget].
///
/// This widget takes a builder which is responsible for building the widget
/// tree for the [FormArrayControl]. The builder is called with the
/// [BuildContext] and the [FormArrayControl] of the group.
///
/// The [formControlName] is the name of the [FormArrayControl] to consume.
class EasyFormArrayControl<TFC> extends StatelessWidget {
  const EasyFormArrayControl({
    super.key,
    required this.builder,
    required this.formControlName,
  });
  final Widget Function(
      BuildContext context, FormArrayControl<TFC> arrayControl) builder;
  final String formControlName;

  @override
  Widget build(BuildContext context) {
    final formGroup = EasyFormProvider.of(context);
    final formArray = formGroup.arrayControl<TFC>(formControlName);

    return EasyFormArrayProvider<TFC>(
      notifier: formArray,
      child: Builder(builder: (acontext) {
        final arrayCtrl = EasyFormArrayProvider.of<TFC>(acontext);

        return builder(context, arrayCtrl);
      }),
    );
  }
}
