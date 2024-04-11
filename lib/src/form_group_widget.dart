import 'package:flutter/material.dart';

import 'models/form_group.dart';
import 'providers/ezy_form_provider.dart';

/// A widget to consume a [FormGroup]
///
/// This widget takes a builder which is responsible for building the widget
/// tree for the [FormGroup]. The builder is called with the [BuildContext]
/// and the [FormGroup] of the group.
///
/// The [formGroup] is the [FormGroup] to consume.
///
/// The [EzyFormWidget] has to be placed at top lever of the form.
class EzyFormWidget extends StatelessWidget {
  const EzyFormWidget({
    super.key,
    required this.builder,
    required this.formGroup,
  });

  final Widget Function(
    BuildContext context,
    FormGroup form,
  ) builder;
  final FormGroup formGroup;

  @override
  Widget build(BuildContext context) {
    return EzyFormProvider(
      notifier: formGroup,
      child: Builder(builder: (acontext) {
        return builder(context, EzyFormProvider.of(acontext));
      }),
    );
  }
}

/// Consume a direct FormGroup
///
/// have to be place within a [EzyFormWidget]
class EzyFormConsumer extends StatelessWidget {
  const EzyFormConsumer({super.key, required this.builder});

  final Widget Function(BuildContext context, FormGroup form) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, EzyFormProvider.of(context));
  }
}
