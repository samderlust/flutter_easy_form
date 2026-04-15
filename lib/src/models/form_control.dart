import 'package:flutter/foundation.dart';

import '../validators.dart';
import 'form_control_base.dart';
import 'form_node.dart';

/// A [FormControl] represents a form control.
///
/// A [FormControl] can be validated and reset, and can be marked as dirty
/// or touched.
/// It holds a value of type [T] and a list of [ValidatorFn] to validate the
/// value.
///
/// The [FormControl] notifies its listeners when its value, dirty or touched
/// status changes.
class FormControl<T> with ChangeNotifier implements FormControlBase, FormNode {
  /// The current value of the form control.
  T? _value;

  /// Snapshot of the value supplied to the constructor, used by [reset].
  final T? _initialValue;

  /// Whether the form control has been modified by the user.
  bool dirty;

  /// Whether the form control has been touched by the user.
  bool touched;

  /// The validation error of the form control, if any.
  String? error;

  /// The list of validators to validate the value of the form control.
  List<ValidatorFn<T>> validators;

  /// Optional callback that converts the control's value to a
  /// JSON-compatible type (e.g. `DateTime` → `String`).
  ///
  /// Used by [FormGroup.toJsonMap]. When `null`, the raw [value] is used.
  final Object? Function(T? value)? _toJson;

  /// Optional callback that converts a JSON-compatible value back to
  /// this control's type (e.g. `String` → `DateTime`).
  ///
  /// Used by [FormGroup.patchValue] / [FormGroup.setValue] when loading
  /// a raw JSON map. When `null`, the incoming value is passed through
  /// as-is.
  final T? Function(dynamic value)? fromJson;

  /// Returns the JSON-compatible representation of [value].
  ///
  /// If a [toJson] callback was supplied, it is used. Otherwise the raw
  /// [value] is returned.
  Object? get jsonValue => _toJson != null ? _toJson(value) : value;

  /// The callback to be executed when the form control is reset.
  VoidCallback? _onReset;

  /// Constructs a [FormControl] with an initial value.
  ///
  /// [value] The initial value of the form control. This value is
  /// captured and restored by [reset].
  /// [dirty] Whether the form control has been modified by the user.
  /// [touched] Whether the form control has been touched by the user.
  /// [validators] The list of validators to validate the value of the form control.
  /// [toJson] Optional serializer for [FormGroup.toJsonMap].
  /// [fromJson] Optional deserializer for [FormGroup.patchValue] / [setValue].
  FormControl(
    T? value, {
    this.dirty = false,
    this.touched = false,
    this.validators = const [],
    Object? Function(T? value)? toJson,
    this.fromJson,
  })  : _toJson = toJson,
        _value = value,
        _initialValue = value;

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

  /// Resets the form control back to the value supplied to the
  /// constructor, and clears `dirty` / `touched` / `error`.
  ///
  /// Use [clear] instead if you want the value wiped to `null` regardless
  /// of the initial value.
  @override
  void reset() {
    _value = _initialValue;
    dirty = false;
    touched = false;
    error = null;
    _onReset?.call();
    notifyListeners();
  }

  /// Clears the form control to an empty state — value becomes `null`
  /// and `dirty` / `touched` / `error` are cleared.
  ///
  /// Unlike [reset] this ignores the value supplied to the constructor;
  /// use it to wipe a form to a blank slate (e.g. a "Clear" button).
  @override
  void clear() {
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
  /// By default this marks the control as `dirty` and `touched` (it
  /// represents a user edit). Pass `markDirty: false` for programmatic
  /// updates that should not flip those flags — e.g. populating a form
  /// from a server response. See also [patchValue].
  ///
  /// No-op when [v] equals the current value: nothing changes and no
  /// listeners are notified.
  void setValue(T? v, {bool markDirty = true}) {
    if (v == _value) return;
    _value = v;
    if (markDirty) {
      dirty = true;
      touched = true;
    }
    notifyListeners();
  }

  /// Programmatically writes [v] to the control without marking it as
  /// `dirty` or `touched`. Convenience wrapper around
  /// `setValue(v, markDirty: false)`.
  ///
  /// Use this when loading values from an external source (e.g. an API
  /// response) so the form's `isDirty` keeps tracking only true user
  /// edits.
  void patchValue(T? v) => setValue(v, markDirty: false);

  @override
  String toString() {
    return 'FormControl(value: $_value, dirty: $dirty, touched: $touched, error: $error)';
  }
}
