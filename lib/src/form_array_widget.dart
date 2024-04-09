import 'package:flutter/material.dart';

import '../easy_form.dart';
import 'form_group.dart';

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
    final formGroup = DynamicFormProvider.of(context);
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

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

class EasyFormArrayProvider<T> extends InheritedNotifier<FormArrayControl<T>> {
  const EasyFormArrayProvider({
    super.key,
    required super.child,
    required super.notifier,
  });

  static FormArrayControl<T> of<T>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<EasyFormArrayProvider<T>>();

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
  bool updateShouldNotify(EasyFormArrayProvider<T> oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
