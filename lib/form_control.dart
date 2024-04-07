import 'package:dynamic_form/dynamic_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'validators/validator_base.dart';

class FormControl<T> {
  T? _value;
  bool dirty;
  bool touched;
  String? error;
  List<ValidatorFn<T>> validators;
  FormControl(
    this._value, {
    this.dirty = false,
    this.touched = false,
    this.validators = const [],
  });

  bool get valid => error == null;
  T? get value => _value;

  void validate() {
    error = null;
    for (var validator in validators) {
      final e = validator(_value);
      if (e != null) {
        error = e;
        break;
      }
    }
  }

  void reset() {
    _value = null;
    dirty = false;
    touched = false;
    error = null;
  }

  void markAsDirty() {
    dirty = true;
    touched = true;
  }

  void markAsTouched() {
    touched = true;
  }

  void setValue(T? v) {
    _value = v;
    dirty = true;
    touched = true;
    // validate();
  }

  @override
  String toString() {
    return 'FormControl(value: $_value, dirty: $dirty, touched: $touched, error: $error)';
  }

  @override
  bool operator ==(covariant FormControl<T> other) {
    if (identical(this, other)) return true;

    return other._value == _value &&
        other.dirty == dirty &&
        other.touched == touched &&
        other.error == error &&
        listEquals(other.validators, validators);
  }

  @override
  int get hashCode {
    return _value.hashCode ^
        dirty.hashCode ^
        touched.hashCode ^
        error.hashCode ^
        validators.hashCode;
  }
}

class DynamicFormControl<TFC> extends StatelessWidget {
  const DynamicFormControl({
    super.key,
    required this.builder,
    required this.formControlName,
  });
  final Widget Function(BuildContext context, FormControlInteract<TFC> control)
      builder;
  final String formControlName;

  @override
  Widget build(BuildContext context) {
    final formGroup = DynamicFormProvider.of(context);
    return builder(
      context,
      FormControlInteract<TFC>(formControlName, formGroup),
    );
  }
}

class FormControlInteract<T> {
  final String key;
  final FormGroup formGroup;

  FormControlInteract(this.key, this.formGroup);

  void setValue(T? value) => formGroup.set(key, value);

  void reset() => formGroup.control(key).reset();

  T? get value => formGroup.control(key).value;

  void validate() => formGroup.control(key).validate();

  void markAsDirty() => formGroup.control(key).markAsDirty();

  void markAsTouched() => formGroup.control(key).markAsTouched();

  bool get valid => formGroup.control(key).valid;

  bool get dirty => formGroup.control(key).dirty;

  bool get touched => formGroup.control(key).touched;

  String? get error => formGroup.control(key).error;
}
