import 'package:easy_form/src/models/form_base.dart';
import 'package:flutter/foundation.dart';

import '../validators.dart';

/// Handle each field in a form
class FormControl<T> with ChangeNotifier implements FormControlBase {
  T? _value;
  bool dirty;
  bool touched;
  String? error;
  List<ValidatorFn<T>> validators;
  VoidCallback? _onReset;
  FormControl(
    this._value, {
    this.dirty = false,
    this.touched = false,
    this.validators = const [],
  });

  @override
  bool get valid => error == null;
  T? get value => _value;

  @override
  bool get isDirty => dirty;

  @override
  bool get isTouched => touched;

  void onReset(VoidCallback fn) {
    _onReset = fn;
  }

  @override
  void validate() {
    error = null;
    for (var validator in validators) {
      final e = validator(_value);
      if (e != null) {
        error = e;
        break;
      }
    }
    notifyListeners();
  }

  @override
  void reset() {
    _value = null;
    dirty = false;
    touched = false;
    error = null;
    _onReset?.call();
    notifyListeners();
  }

  @override
  void markAsDirty() {
    dirty = true;
    touched = true;
    notifyListeners();
  }

  @override
  void markAsTouched() {
    touched = true;
    notifyListeners();
  }

  void setValue(T? v) {
    _value = v;
    dirty = true;
    touched = true;
    // validate();
    notifyListeners();
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
