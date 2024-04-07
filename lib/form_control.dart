import 'validators/validator_base.dart';
import 'package:flutter/foundation.dart';

class FormControl<T> with ChangeNotifier {
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

    notifyListeners();
  }

  void reset() {
    _value = null;
    dirty = false;
    touched = false;
    error = null;
    notifyListeners();
  }

  void markAsDirty() {
    dirty = true;
    touched = true;
    notifyListeners();
  }

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
