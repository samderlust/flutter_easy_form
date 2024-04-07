// ignore_for_file: public_member_api_docs, sort_constructors_first
library dynamic_form;

import 'package:dynamic_form/form_control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class FormGroup with ChangeNotifier {
  final Map<String, FormControl> group;
  FormGroup(this.group);

  get isDirty => group.values.any((ctrl) => ctrl.dirty);
  get isTouched => group.values.any((ctrl) => ctrl.touched);
  get isValid => group.values.every((ctrl) => ctrl.valid);

  FormControl control(String ctrlName) => group[ctrlName] == null
      ? throw ArgumentError('Control $ctrlName not found')
      : group[ctrlName]!;

  Map<String, dynamic> get values =>
      group.map((key, value) => MapEntry(key, value.value));

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

  void set(String key, dynamic value) {
    control(key).setValue(value);
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

class DynamicFormConsumer extends StatelessWidget {
  const DynamicFormConsumer({super.key, required this.builder});

  final Widget Function(BuildContext context, FormGroup form) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, DynamicFormProvider.of(context));
  }
}
