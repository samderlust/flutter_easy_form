import 'package:flutter/foundation.dart';

import '../../ezy_form.dart';
import 'form_control_base.dart';

/// A [FormGroup] represents a group of [FormControl]s.
///
/// It can be used to group together a set of [FormControl]s to create a
/// hierarchy of [FormControl]s.
///
/// A [FormGroup] can be validated and reset, and can be marked as dirty or
/// touched.
class FormGroup with ChangeNotifier implements FormNode {
  final Map<String, FormNode> group;
  FormGroup(this.group);

  get isDirty => flatControls.any((ctrl) => ctrl.isDirty);
  get isTouched => flatControls.any((ctrl) => ctrl.isTouched);
  get isValid => flatControls.every((ctrl) => ctrl.valid);

  /// Retrieves a nested FormControl based on the provided control name.
  FormControl<T> control<T>(String ctrlName) {
    final kList = ctrlName.split('.');
    return _travelNested<FormControl<T>>(group, kList);
  }

  /// Get a FormGroup based on the control name.
  FormGroup groupControl(String ctrlName) {
    final kList = ctrlName.split('.');
    return _travelNested<FormGroup>(group, kList);
  }

  /// Get a FormArrayControl for the provided control name.
  FormArrayControl<T> arrayControl<T>(String ctrlName) {
    final kList = ctrlName.split('.');
    return _travelNested<FormArrayControl<T>>(group, kList);
  }

  List<FormGroup> get flatGroups {
    return _flattenMapValues<FormGroup>(group);
  }

  List<FormControlBase> get flatControls {
    return _flattenMapValues<FormControlBase>(group);
  }

  List<T> _flattenMapValues<T>(Map<String, FormNode> nestedMap) {
    List<T> flattenedValues = [];
    for (var value in nestedMap.values) {
      // Check `is T` first so that when T is FormGroup we collect the
      // nested group itself (flatGroups) rather than descending into it.
      if (value is T) {
        flattenedValues.add(value as T);
      } else if (value is FormGroup) {
        flattenedValues.addAll(_flattenMapValues(value.group));
      }
    }
    return flattenedValues;
  }

  T _travelNested<T>(Map<String, FormNode> map, List<String> kList) {
    var curMap = map;
    for (var i = 0; i < kList.length; i++) {
      var val = curMap[kList[i]];
      if (val == null) {
        throw ArgumentError('Control ${kList.join('.')} not found');
      }

      if (val is FormGroup) {
        curMap = val.group;
      }

      if (i == kList.length - 1) {
        if (val is T) {
          return val as T;
        } else {
          throw ArgumentError('Control ${kList.join('.')} not found');
        }
      }
    }

    throw ArgumentError('Control ${kList.join('.')} not found');
  }

  /// Get Map values of the form group.
  Map<String, dynamic> get values {
    final map = <String, dynamic>{};
    for (var key in group.keys) {
      final v = group[key];

      if (v is FormGroup) {
        map[key] = v.values;
      } else if (v is FormControl) {
        map[key] = v.value;
      } else if (v is FormArrayControl) {
        map[key] = v.values;
      }
    }
    return map;
  }

  /// Returns a JSON-compatible `Map<String, dynamic>` mirroring the
  /// group shape.
  ///
  /// For each [FormControl] that has a [FormControl.toJson] callback,
  /// the callback is used to convert the value. Otherwise the raw value
  /// is included (same as [values]).
  ///
  /// Nested [FormGroup]s recurse into [toJson], and
  /// [FormArrayControl]s map each child through its own `toJson`
  /// callback (if present).
  ///
  /// Use this instead of [values] when you need to feed the result
  /// into `jsonEncode`.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    for (var key in group.keys) {
      final v = group[key];

      if (v is FormGroup) {
        map[key] = v.toJson();
      } else if (v is FormControl) {
        map[key] = v.jsonValue;
      } else if (v is FormArrayControl) {
        map[key] = v.jsonValues;
      }
    }
    return map;
  }

  /// Patches the form group with values from [values].
  ///
  /// Unknown keys are ignored. Nested maps are dispatched into matching
  /// nested [FormGroup]s, and lists are dispatched into matching
  /// [FormArrayControl]s. Controls **are not** marked as `dirty` /
  /// `touched`, so this is the right primitive for loading a server
  /// response into a form without flipping its "user has edited" state.
  ///
  /// See [setValue] for the strict variant that requires every key to
  /// be present and marks edits as dirty.
  void patchValue(Map<String, dynamic> values) {
    _applyMap(values, markDirty: false, strict: false);
  }

  /// Sets every value in the form group from [values], marking each
  /// affected control as `dirty` / `touched`.
  ///
  /// Strict: throws [ArgumentError] if [values] is missing any key
  /// declared in the group, contains an unknown key, or has a value of
  /// the wrong shape (e.g. a `List` for a [FormGroup] slot). Use
  /// [patchValue] for the lenient variant.
  void setValue(Map<String, dynamic> values) {
    _applyMap(values, markDirty: true, strict: true);
  }

  void _applyMap(
    Map<String, dynamic> values, {
    required bool markDirty,
    required bool strict,
  }) {
    if (strict) {
      for (final key in group.keys) {
        if (!values.containsKey(key)) {
          throw ArgumentError(
            'FormGroup.setValue is missing key "$key". Use patchValue '
            'for partial updates.',
          );
        }
      }
      for (final key in values.keys) {
        if (!group.containsKey(key)) {
          throw ArgumentError(
            'FormGroup.setValue received unknown key "$key".',
          );
        }
      }
    }

    for (final entry in values.entries) {
      final key = entry.key;
      final value = entry.value;
      final node = group[key];
      if (node == null) continue; // unknown key in lenient mode

      if (node is FormGroup) {
        if (value is! Map<String, dynamic>) {
          if (strict) {
            throw ArgumentError(
              'Expected Map for nested FormGroup "$key", got '
              '${value.runtimeType}.',
            );
          }
          continue;
        }
        if (markDirty) {
          node.setValue(value);
        } else {
          node.patchValue(value);
        }
      } else if (node is FormArrayControl) {
        if (value is! List) {
          if (strict) {
            throw ArgumentError(
              'Expected List for FormArrayControl "$key", got '
              '${value.runtimeType}.',
            );
          }
          continue;
        }
        if (markDirty) {
          node.setValue(value);
        } else {
          node.patchValue(value);
        }
      } else if (node is FormControl) {
        final parsed =
            node.fromJson != null ? node.fromJson!(value) : value;
        node.setValue(parsed, markDirty: markDirty);
      }
    }
    notifyListeners();
  }

  /// Validates all flat controls and notifies listeners.
  /// Returns a boolean value indicating validity.
  bool validate() {
    for (var ctrl in flatControls) {
      ctrl.validate();
    }
    notifyListeners();
    return isValid;
  }

  /// Resets every descendant control back to its initial value.
  ///
  /// See [clear] for the "wipe to empty" variant.
  void reset() {
    for (var ctrl in flatControls) {
      ctrl.reset();
    }
    notifyListeners();
  }

  /// Clears every descendant control to an empty state — values become
  /// `null` and `dirty` / `touched` / `error` are cleared. The structure
  /// of the group (and any nested arrays) is preserved.
  void clear() {
    for (var ctrl in flatControls) {
      ctrl.clear();
    }
    notifyListeners();
  }

  // void setArrayItem(String key, int index, dynamic value) {
  //   final ctrl = arrayControl(key).controls;
  //   if (ctrl == null) {
  //     return;
  //   }
  //   ctrl[index].setValue(value);
  //   notifyListeners();
  // }

  @override
  String toString() => 'FormGroup(group: $group)';

  @override
  bool operator ==(covariant FormGroup other) {
    if (identical(this, other)) return true;

    return mapEquals(other.group, group);
  }

  @override
  int get hashCode => group.hashCode;
}
