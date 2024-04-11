import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

import 'form_control_base.dart';

/// A FormArrayControl is a collection of FormControl.
///
/// It provides methods to manipulate the list of FormControl,
/// validate and reset the state.
class FormArrayControl<T> with ChangeNotifier implements FormControlBase {
  /// Flag indicating if the control has been modified.
  bool dirty;

  /// Flag indicating if the control has been touched.
  bool touched;

  /// Error message if validation fails.
  String? error;

  /// List of FormControls.
  List<FormControl<T>>? controls;

  /// List of validators to apply to all FormControls in this FormArrayControl.
  List<ValidatorFn<T>> validators;

  /// Construct a FormArrayControl.
  ///
  /// If `controls` is not null, apply the `validators` to each FormControl.
  FormArrayControl(
    this.controls, {
    this.dirty = false,
    this.touched = false,
    this.validators = const [],
  }) {
    if (controls != null && controls!.isNotEmpty) {
      for (var c in controls!) {
        c.validators = validators;
      }
    }
  }

  /// Add a FormControl to the list of FormControls.
  ///
  /// If `value` is provided, add it to the list of FormControls.
  void add([T? value]) {
    controls ??= [];
    var control = FormControl<T>(value, validators: validators);
    controls!.add(control);
    notifyListeners();
  }

  /// Remove a FormControl at `index` from the list of FormControls.
  void remove(int index) {
    controls?.removeAt(index);
    notifyListeners();
  }

  @override
  bool get isDirty => dirty;

  @override
  bool get isTouched => touched;

  @override
  bool get valid => error == null;

  /// Get the values of all FormControls in the list.
  List<T>? get values =>
      controls?.where((e) => e.value != null).map((e) => e.value!).toList();

  @override
  void validate() {
    if (controls == null) return;
    error = null;
    for (var c in controls!) {
      c.validate();
      if (c.error != null) {
        error = c.error;
      }
    }
  }

  @override
  void reset() {
    dirty = false;
    touched = false;
    error = null;

    if (controls == null) return;
    for (var c in controls!) {
      c.reset();
    }

    notifyListeners();
  }

  @override
  void markAsDirty() {
    dirty = true;
    touched = true;
  }

  @override
  void markAsTouched() {
    touched = true;
  }
}
