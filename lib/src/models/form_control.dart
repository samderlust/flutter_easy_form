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

  /// Asynchronous validators run after all synchronous [validators] pass.
  ///
  /// Use these for server-side checks (e.g. email uniqueness). While
  /// running, [pending] is `true` and listeners are notified so the UI
  /// can show a loading indicator.
  List<AsyncValidatorFn<T>> asyncValidators;

  /// `true` while asynchronous validators are running.
  bool _pending = false;

  /// Whether async validators are currently running.
  bool get pending => _pending;

  /// Whether this control has any async validators configured.
  bool get hasAsyncValidators => asyncValidators.isNotEmpty;

  /// The callback to be executed when the form control is reset.
  VoidCallback? _onReset;

  /// Whether the control is enabled.
  bool _enabled;

  /// Constructs a [FormControl] with an initial value.
  ///
  /// [value] The initial value of the form control. This value is
  /// captured and restored by [reset].
  /// [dirty] Whether the form control has been modified by the user.
  /// [touched] Whether the form control has been touched by the user.
  /// [validators] Synchronous validators for the control.
  /// [asyncValidators] Asynchronous validators, run after sync validators pass.
  /// [enabled] Whether the control starts enabled (default `true`).
  FormControl(
    T? value, {
    this.dirty = false,
    this.touched = false,
    this.validators = const [],
    this.asyncValidators = const [],
    bool enabled = true,
  })  : _value = value,
        _initialValue = value,
        _enabled = enabled;

  /// Whether the control is enabled. Disabled controls are skipped by
  /// [validate] and excluded from [FormGroup.values].
  @override
  bool get enabled => _enabled;

  /// Whether the control is disabled.
  @override
  bool get disabled => !_enabled;

  /// The validation status of the form control.
  ///
  /// A form control is valid if there is no validation error.
  /// Disabled controls are always considered valid.
  @override
  bool get valid => !_enabled || error == null;

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
  ///
  /// No-op when the control is [disabled] — the error is cleared and
  /// listeners are notified so the UI can update.
  @override
  void validate() {
    if (!_enabled) {
      error = null;
      notifyListeners();
      return;
    }
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

  /// Validates the control: runs synchronous validators first, then
  /// asynchronous validators (if sync passes and [asyncValidators] is
  /// non-empty).
  ///
  /// No-op when the control is [disabled].
  ///
  /// While async validators are running, [pending] is `true`. If the
  /// value changes while async validation is in flight, the stale result
  /// is discarded.
  Future<void> validateAsync() async {
    // Run sync validators first.
    validate();
    if (!_enabled || error != null || asyncValidators.isEmpty) return;

    // Snapshot the value so we can detect stale results.
    final snapshot = _value;

    _pending = true;
    notifyListeners();

    for (final asyncValidator in asyncValidators) {
      final e = await asyncValidator(_value);
      // Value changed while we were awaiting — discard result.
      if (_value != snapshot) {
        _pending = false;
        notifyListeners();
        return;
      }
      if (e != null) {
        error = e;
        break;
      }
    }

    _pending = false;
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
    _pending = false;
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
    _pending = false;
    _onReset?.call();
    notifyListeners();
  }

  /// Disables the control. Clears any existing error and notifies
  /// listeners so the UI can grey out the field.
  @override
  void markAsDisabled() {
    _enabled = false;
    error = null;
    notifyListeners();
  }

  /// Re-enables a previously disabled control.
  @override
  void markAsEnabled() {
    _enabled = true;
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
