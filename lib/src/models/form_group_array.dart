import 'package:flutter/material.dart';

import '../../ezy_form.dart';
import 'form_control_base.dart';

/// A validator function applied to the array of groups as a whole.
typedef GroupArrayValidatorFn = String? Function(List<FormGroup>? groups);

/// A [FormGroupArray] holds a list of [FormGroup]s — each child is a
/// full form group with its own named fields, types, and validators.
///
/// Use this for arrays of structured objects such as addresses, line items,
/// or work-history entries. For flat lists of scalar values, use
/// [FormArrayControl] instead.
///
/// ```dart
/// FormGroupArray(
///   [
///     FormGroup({
///       'street': FormControl<String>('', validators: [requiredValidator]),
///       'city': FormControl<String>(''),
///     }),
///   ],
///   templateFactory: () => FormGroup({
///     'street': FormControl<String>('', validators: [requiredValidator]),
///     'city': FormControl<String>(''),
///   }),
/// )
/// ```
class FormGroupArray
    with ChangeNotifier
    implements FormControlBase, FormNode {
  /// Flag indicating if the array has been modified.
  bool dirty;

  /// Flag indicating if the array has been touched.
  bool touched;

  /// Error message if validation fails.
  String? error;

  /// The list of child [FormGroup]s.
  List<FormGroup> controls;

  /// Validators applied to the array as a whole.
  List<GroupArrayValidatorFn> arrayValidators;

  /// Optional factory that produces a fresh [FormGroup] for [addGroup].
  ///
  /// When provided, calling [addGroup] without arguments creates a new
  /// group from this factory. When `null`, [addGroup] requires an explicit
  /// [FormGroup] argument.
  final FormGroup Function()? templateFactory;

  /// Snapshot of initial groups for [reset].
  final List<Map<String, dynamic>> _initialValues;

  /// The factory used to rebuild groups on [reset].
  final FormGroup Function()? _resetFactory;

  /// Number of initial groups so [reset] can restore the right count.
  final int _initialLength;

  /// Construct a [FormGroupArray].
  ///
  /// [controls] is the initial list of groups. Pass [templateFactory] to
  /// enable [addGroup] without arguments. [arrayValidators] run against
  /// the whole list during [validate].
  FormGroupArray(
    List<FormGroup>? controls, {
    this.dirty = false,
    this.touched = false,
    this.arrayValidators = const [],
    this.templateFactory,
  })  : controls = controls ?? [],
        _initialValues =
            (controls ?? []).map((g) => g.values).toList(growable: false),
        _initialLength = (controls ?? []).length,
        _resetFactory = templateFactory;

  /// The number of child groups.
  int get length => controls.length;

  /// Adds a [FormGroup] to the end of the array.
  ///
  /// If [group] is `null`, uses [templateFactory] to create one.
  /// Throws [StateError] if both are `null`.
  void addGroup([FormGroup? group]) {
    if (group == null && templateFactory == null) {
      throw StateError(
        'Cannot add a group without an argument when no templateFactory '
        'was provided.',
      );
    }
    controls.add(group ?? templateFactory!());
    notifyListeners();
  }

  /// Removes the [FormGroup] at [index].
  ///
  /// No-op when [index] is out of range.
  void removeGroup(int index) {
    if (index < 0 || index >= controls.length) return;
    controls.removeAt(index);
    notifyListeners();
  }

  /// Removes all child groups, leaving an empty list.
  void removeAll() {
    dirty = false;
    touched = false;
    error = null;
    controls = [];
    notifyListeners();
  }

  @override
  bool get isDirty => dirty || controls.any((g) => g.isDirty);

  @override
  bool get isTouched => touched || controls.any((g) => g.isTouched);

  @override
  bool get valid => error == null && controls.every((g) => g.isValid);

  /// Returns the values of all child groups as a list of maps.
  List<Map<String, dynamic>> get values =>
      controls.map((g) => g.values).toList();

  @override
  void validate() {
    error = null;

    // Array-level validators first.
    for (var v in arrayValidators) {
      final e = v(controls);
      if (e != null) {
        error = e;
        break;
      }
    }

    // Then validate each child group.
    for (var g in controls) {
      g.validate();
    }

    notifyListeners();
  }

  /// Resets the array to the shape and values it had at construction time.
  @override
  void reset() {
    dirty = false;
    touched = false;
    error = null;

    if (_resetFactory != null) {
      controls = List.generate(_initialLength, (_) => _resetFactory());
      for (var i = 0; i < _initialLength; i++) {
        controls[i].patchValue(_initialValues[i]);
      }
    } else {
      // Without a factory we can't rebuild groups, so just reset
      // existing ones up to the initial length.
      while (controls.length > _initialLength) {
        controls.removeLast();
      }
      for (var i = 0; i < controls.length; i++) {
        controls[i].reset();
      }
    }

    notifyListeners();
  }

  /// Clears every child group's values while keeping the current structure.
  @override
  void clear() {
    dirty = false;
    touched = false;
    error = null;

    for (var g in controls) {
      g.clear();
    }

    notifyListeners();
  }

  /// Replaces the array content from a list of maps, marking as dirty.
  void setValue(List<Map<String, dynamic>> values) =>
      _applyValues(values, markDirty: true);

  /// Patches the array content from a list of maps without marking dirty.
  void patchValue(List<Map<String, dynamic>> values) =>
      _applyValues(values, markDirty: false);

  void _applyValues(
    List<Map<String, dynamic>> values, {
    required bool markDirty,
  }) {
    // Resize down.
    while (controls.length > values.length) {
      controls.removeLast();
    }
    // Resize up — requires templateFactory.
    while (controls.length < values.length) {
      if (templateFactory == null) {
        throw StateError(
          'Cannot resize FormGroupArray without a templateFactory. '
          'Provide a templateFactory in the constructor to enable '
          'dynamic resizing via setValue/patchValue.',
        );
      }
      controls.add(templateFactory!());
    }
    // Apply values to each child group.
    for (var i = 0; i < values.length; i++) {
      if (markDirty) {
        controls[i].setValue(values[i]);
      } else {
        controls[i].patchValue(values[i]);
      }
    }
    if (markDirty) {
      dirty = true;
      touched = true;
    }
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
