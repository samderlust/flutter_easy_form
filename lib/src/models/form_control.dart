import 'package:flutter/foundation.dart';

import '../validators.dart';
import 'form_control_base.dart';

/// A [FormControl] represents a form control.
///
/// A [FormControl] can be validated and reset, and can be marked as dirty
/// or touched.
/// It holds a value of type [T] and a list of [ValidatorFn] to validate the
/// value.
///
/// The [FormControl] notifies its listeners when its value, dirty or touched
/// status changes.
class FormControl<T> with ChangeNotifier implements FormControlBase {
  /// The current value of the form control.
  T? _value;

  /// Whether the form control has been modified by the user.
  bool dirty;

  /// Whether the form control has been touched by the user.
  bool touched;

  /// The validation error of the form control, if any.
  String? error;

  /// The list of validators to validate the value of the form control.
  List<ValidatorFn<T>> validators;

  /// The callback to be executed when the form control is reset.
  VoidCallback? _onReset;

  /// Constructs a [FormControl] with an initial value.
  ///
  /// [value] The initial value of the form control.
  /// [dirty] Whether the form control has been modified by the user.
  /// [touched] Whether the form control has been touched by the user.
  /// [validators] The list of validators to validate the value of the form control.
  FormControl(
    this._value, {
    this.dirty = false,
    this.touched = false,
    this.validators = const [],
  });

  /// The validation status of the form control.
  ///
  /// A form control is valid if there is no validation error.
  @override
  bool get valid => error == null;

  /// The current value of the form control.
  T? get value => _value;

  /// Whether the form control has been modified by the user.
  @override
  bool get isDirty => dirty;

  /// Whether the form control has been touched by the user.
  @override
  bool get isTouched => touched;

  /// Sets a callback to be executed when the form control is reset.
  ///
  /// [fn] The callback to be executed.
  void onReset(VoidCallback fn) {
    _onReset = fn;
  }

  /// Validates the value of the form control using the validators.
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

  /// Resets the form control to its initial state.
  @override
  void reset() {
    _value = null;
    dirty = false;
    touched = false;
    error = null;
    _onReset?.call();
    notifyListeners();
  }

  /// Marks the form control as dirty.
  @override
  void markAsDirty() {
    dirty = true;
    touched = true;
    notifyListeners();
  }

  /// Marks the form control as touched.
  @override
  void markAsTouched() {
    touched = true;
    notifyListeners();
  }

  /// Sets the value of the form control.
  ///
  /// [v] The new value of the form control.
  void setValue(T? v) {
    _value = v;
    dirty = true;
    touched = true;
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
