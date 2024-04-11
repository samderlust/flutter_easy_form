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
class FormGroup with ChangeNotifier {
  final Map<String, Object> group;
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

  List<T> _flattenMapValues<T>(Map<String, dynamic> nestedMap) {
    List<T> flattenedValues = [];
    for (var value in nestedMap.values) {
      if (value is Map<String, dynamic>) {
        flattenedValues.addAll(_flattenMapValues(value));
      } else if (value is List<T>) {
        flattenedValues.addAll(value);
      } else if (value is T) {
        flattenedValues.add(value);
      } else if (value is FormGroup) {
        flattenedValues.addAll(_flattenMapValues(value.group));
      } else {
        continue;
      }
    }
    return flattenedValues;
  }

  T _travelNested<T>(Map<String, dynamic> map, List<String> kList) {
    var curMap = {...map};
    for (var i = 0; i < kList.length; i++) {
      var val = curMap[kList[i]];
      if (val == null) {
        throw ArgumentError('Control ${kList.join('.')} not found');
      }
      if (val is Map<String, dynamic> &&
          val is! FormGroup &&
          val is! FormArrayControl &&
          val is! FormControl) {
        throw ArgumentError('Control ${kList.join('.')} not is invalid type');
      }

      if (val is FormGroup) {
        curMap = val.group;
      }

      if (i == kList.length - 1) {
        if (val is T) {
          return val;
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

  /// Validates all flat controls and notifies listeners.
  /// Returns a boolean value indicating validity.
  bool validate() {
    for (var ctrl in flatControls) {
      ctrl.validate();
    }
    notifyListeners();
    return isValid;
  }

  // Reset all form controls in this form group.
  void reset() {
    for (var ctrl in flatControls) {
      ctrl.reset();
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
