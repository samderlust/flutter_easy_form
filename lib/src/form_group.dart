import 'package:easy_form/src/models/form_base.dart';
import 'package:easy_form/src/models/form_control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models/form_array_control.dart';

/// Declare a form
///
/// `FormGroup` is a collection of `FormControl`
class FormGroup with ChangeNotifier {
  final Map<String, FormControlBase> group;
  FormGroup(this.group);

  get isDirty => group.values.any((ctrl) => ctrl.isDirty);
  get isTouched => group.values.any((ctrl) => ctrl.isTouched);
  get isValid => group.values.every((ctrl) => ctrl.valid);

  bool assertControl(String ctrlName) {
    return (group[ctrlName] == null);
  }

  FormControl<T> control<T>(String ctrlName) =>
      group[ctrlName] == null && (group[ctrlName] is FormArrayControl)
          ? throw ArgumentError('Control $ctrlName not found')
          : group[ctrlName]! as FormControl<T>;

  FormArrayControl<T> arrayControl<T>(String ctrlName) =>
      group[ctrlName] == null
          ? throw ArgumentError('ArrayControl $ctrlName not found')
          : group[ctrlName]! as FormArrayControl<T>;

  Map<String, dynamic> get values => group.map(
        (key, value) => switch (value) {
          var v when v is FormControl =>
            MapEntry(key, (value as FormControl).value),
          var v when v is FormArrayControl => MapEntry(
              key,
              (value as FormArrayControl)
                  .controls!
                  .map((e) => e.value)
                  .toList()),
          _ => throw 'value is not a FormControl or FormArrayControl',
        },
      );

  bool validate() {
    for (var ctrl in group.values) {
      ctrl.validate();
    }
    notifyListeners();
    return isValid;
  }

  void reset() {
    for (var ctrl in group.values) {
      ctrl.reset();
    }
    notifyListeners();
  }

  void setArrayItem(String key, int index, dynamic value) {
    final ctrl = arrayControl(key).controls;
    if (ctrl == null) {
      return;
    }
    ctrl[index].setValue(value);
    notifyListeners();
  }

  @override
  String toString() => 'FormGroup(group: $group)';

  @override
  bool operator ==(covariant FormGroup other) {
    if (identical(this, other)) return true;

    return mapEquals(other.group, group);
  }

  @override
  int get hashCode => group.hashCode;
}

class DynamicFormProvider extends InheritedNotifier<FormGroup> {
  const DynamicFormProvider({
    super.key,
    required super.child,
    required super.notifier,
  });

  static FormGroup of(BuildContext context) {
    // return context
    //     .dependOnInheritedWidgetOfExactType<DynamicFormProvider>()!
    //     .data;
    final provider =
        context.dependOnInheritedWidgetOfExactType<DynamicFormProvider>();

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
  bool updateShouldNotify(DynamicFormProvider oldWidget) {
    return notifier != oldWidget.notifier;
  }
}

/// Render a form
class DynamicFormWidget extends StatelessWidget {
  const DynamicFormWidget({
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
    return DynamicFormProvider(
      notifier: formGroup,
      child: Builder(builder: (acontext) {
        return builder(context, DynamicFormProvider.of(acontext));
      }),
    );
  }
}

/// Consume a direct FormGroup
class DynamicFormConsumer extends StatelessWidget {
  const DynamicFormConsumer({super.key, required this.builder});

  final Widget Function(BuildContext context, FormGroup form) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, DynamicFormProvider.of(context));
  }
}
