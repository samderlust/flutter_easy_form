import 'package:easy_form/easy_form.dart';
import 'package:flutter/material.dart';

import 'form_base.dart';

class FormArrayControl<T> with ChangeNotifier implements FormControlBase {
  bool dirty;
  bool touched;
  String? error;
  List<FormControl<T>>? controls;
  List<ValidatorFn<T>> validators;

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
  void add([T? value]) {
    controls ??= [];
    var control = FormControl<T>(value, validators: validators);
    controls!.add(control);
    notifyListeners();
  }

  void remove(int index) {
    controls?.removeAt(index);
    notifyListeners();
  }

  @override
  bool get isDirty => dirty;

  @override
  bool get isTouched => touched;

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

  @override
  bool get valid => error == null;
}
