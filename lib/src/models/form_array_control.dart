import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

import 'form_control_base.dart';

/// A FormArrayControl is a collection of FormControl.
///
/// It provides methods to manipulate the list of FormControl,
/// validate and reset the state.
class FormArrayControl<T>
    with ChangeNotifier
    implements FormControlBase, FormNode {
  /// Flag indicating if the control has been modified.
  bool dirty;

  /// Flag indicating if the control has been touched.
  bool touched;

  /// Error message if validation fails.
  String? error;

  /// List of FormControls.
  List<FormControl<T>>? controls;

  /// Validators applied to **each child** [FormControl] in this array.
  ///
  /// These are propagated to every existing child at construction and to
  /// new children created via [add]. For array-level rules that need the
  /// aggregated list (e.g. min length), use [arrayValidators] instead.
  List<ValidatorFn<T>> validators;

  /// Validators applied to the array as a whole, receiving the current
  /// [values] list.
  ///
  /// Use these for rules that depend on the collection (min/max length,
  /// uniqueness, etc.), as opposed to per-item rules in [validators].
  List<ArrayValidatorFn<T>> arrayValidators;

  /// Snapshot of the values from the [controls] passed to the constructor,
  /// used by [reset] to restore the array to its initial shape and values.
  /// `null` when the array was constructed with `null` controls.
  final List<T?>? _initialValues;

  /// Whether the array control is enabled.
  bool _enabled;

  /// Construct a FormArrayControl.
  ///
  /// If [controls] is not null, [validators] are propagated to each child.
  /// [arrayValidators] are run against the aggregated list during [validate].
  FormArrayControl(
    this.controls, {
    this.dirty = false,
    this.touched = false,
    this.validators = const [],
    this.arrayValidators = const [],
    bool enabled = true,
  }) : _enabled = enabled,
       _initialValues =
            controls?.map((c) => c.value).toList(growable: false) {
    if (controls != null && controls!.isNotEmpty) {
      for (var c in controls!) {
        c.validators = validators;
      }
    }
  }

  /// Appends a new [FormControl] with the given [value].
  ///
  /// The array's [validators] are propagated to the new child. To add a
  /// pre-built control with custom validators, use [addControl] instead.
  void add([T? value]) {
    controls ??= [];
    var control = FormControl<T>(value, validators: validators);
    controls!.add(control);
    notifyListeners();
  }

  /// Appends a pre-built [FormControl] to the array.
  ///
  /// Unlike [add], this does **not** overwrite the control's validators,
  /// so you can attach custom per-item validation:
  ///
  /// ```dart
  /// array.addControl(FormControl<String>('x', validators: [myValidator]));
  /// ```
  void addControl(FormControl<T> control) {
    controls ??= [];
    controls!.add(control);
    notifyListeners();
  }

  /// Inserts a new [FormControl] with the given [value] at [index].
  ///
  /// The array's [validators] are propagated to the new child. Clamps
  /// [index] to `[0, length]` so out-of-range values insert at the
  /// beginning or end rather than throwing.
  void insert(int index, [T? value]) {
    controls ??= [];
    final clamped = index.clamp(0, controls!.length);
    var control = FormControl<T>(value, validators: validators);
    controls!.insert(clamped, control);
    notifyListeners();
  }

  /// Moves the child at [from] to [to], shifting other children as
  /// needed. Useful for drag-reorder UX.
  ///
  /// No-op when [controls] is null/empty or either index is out of range.
  void move(int from, int to) {
    final list = controls;
    if (list == null || list.isEmpty) return;
    if (from < 0 || from >= list.length) return;
    if (to < 0 || to >= list.length) return;
    if (from == to) return;
    final control = list.removeAt(from);
    list.insert(to, control);
    notifyListeners();
  }

  /// Removes the [FormControl] at [index].
  ///
  /// No-op when [controls] is null/empty or [index] is out of range.
  void remove(int index) {
    final list = controls;
    if (list == null || index < 0 || index >= list.length) {
      return;
    }
    list.removeAt(index);
    notifyListeners();
  }

  @override
  bool get enabled => _enabled;

  @override
  bool get disabled => !_enabled;

  @override
  bool get isDirty => dirty || (controls?.any((c) => c.isDirty) ?? false);

  @override
  bool get isTouched => touched || (controls?.any((c) => c.isTouched) ?? false);

  @override
  bool get valid => !_enabled || error == null;

  /// Values of every child [FormControl], including `null` for empty slots.
  ///
  /// Returns `null` when [controls] is itself `null`. An array with three
  /// empty items yields `[null, null, null]` rather than `[]`, so the
  /// length matches [controls].
  List<T?>? get values => controls?.map((e) => e.value).toList();

  @override
  void validate() {
    if (!_enabled) {
      error = null;
      notifyListeners();
      return;
    }
    error = null;

    // Array-level rules run first against the aggregated list.
    for (var v in arrayValidators) {
      final e = v(values);
      if (e != null) {
        error = e;
        break;
      }
    }

    if (error == null) {
      if (controls == null || controls!.isEmpty) {
        // Fallback: run per-item validators against null so the README
        // pattern of `FormArrayControl<String>(null, validators: [required])`
        // still flags an empty array as invalid when no arrayValidators
        // are supplied.
        for (var validator in validators) {
          final e = validator(null);
          if (e != null) {
            error = e;
            break;
          }
        }
      } else {
        for (var c in controls!) {
          c.validate();
          if (c.error != null) {
            error = c.error;
          }
        }
      }
    }

    notifyListeners();
  }

  /// Resets the array to the shape and values it had at construction time.
  ///
  /// Any items added via [add] after construction are discarded, and the
  /// original [FormControl]s are rebuilt from the initial value snapshot.
  /// If the array was constructed with `null` controls, [controls] is set
  /// back to `null`.
  ///
  /// Use [clear] to keep the current children but null out their values,
  /// or [removeAll] to drop every child outright.
  @override
  void reset() {
    dirty = false;
    touched = false;
    error = null;

    if (_initialValues == null) {
      controls = null;
    } else {
      controls = _initialValues
          .map((v) => FormControl<T>(v, validators: validators))
          .toList();
    }

    notifyListeners();
  }

  /// Clears every child's value to `null` while keeping the current
  /// number of children, and clears `dirty` / `touched` / `error` on the
  /// array itself.
  @override
  void clear() {
    dirty = false;
    touched = false;
    error = null;

    if (controls != null) {
      for (var c in controls!) {
        c.clear();
      }
    }

    notifyListeners();
  }

  /// Removes every child from the array, leaving an empty list.
  ///
  /// Use this when you want to start over from scratch (e.g. a
  /// "Remove all tags" button). [reset] restores the original shape;
  /// [clear] keeps the current shape but nulls values; [removeAll] drops
  /// the children entirely.
  void removeAll() {
    dirty = false;
    touched = false;
    error = null;
    controls = [];
    notifyListeners();
  }

  /// Replaces the array's values with [values], resizing the children
  /// list to match. Marks the array and its children as dirty/touched.
  ///
  /// Existing [FormControl] instances are reused where possible (so
  /// widgets that hold direct references stay valid); excess children
  /// are removed and missing ones are appended.
  void setValue(List values) => _applyValues(values, markDirty: true);

  /// Same as [setValue] but does not mark the array or its children as
  /// `dirty` / `touched`. Use this to load values from a server response
  /// without triggering "user has edited the form" UI state.
  void patchValue(List values) => _applyValues(values, markDirty: false);

  void _applyValues(List values, {required bool markDirty}) {
    final list = controls ??= <FormControl<T>>[];

    // Resize down.
    while (list.length > values.length) {
      list.removeLast();
    }
    // Resize up.
    while (list.length < values.length) {
      list.add(FormControl<T>(null, validators: validators));
    }
    // Update each child in place. FormControl.setValue short-circuits
    // on no-op, so this only notifies children whose value actually
    // changed.
    for (var i = 0; i < values.length; i++) {
      list[i].setValue(values[i] as T?, markDirty: markDirty);
    }
    if (markDirty) {
      dirty = true;
      touched = true;
    }
    notifyListeners();
  }

  @override
  void markAsDisabled() {
    _enabled = false;
    error = null;
    notifyListeners();
  }

  @override
  void markAsEnabled() {
    _enabled = true;
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
}
