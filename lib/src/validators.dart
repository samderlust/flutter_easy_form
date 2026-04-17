import 'models/form_control.dart';

typedef ValidatorFn<T> = String? Function(T? value);

/// Signature for **asynchronous** validators on a [FormControl].
///
/// Return a `Future` that resolves to an error message (validation failed)
/// or `null` (validation passed). Use these for server-side checks like
/// username availability or email uniqueness.
typedef AsyncValidatorFn<T> = Future<String?> Function(T? value);

/// Signature for validators applied to a [FormArrayControl] as a whole.
///
/// The validator receives the array's aggregated values (which may include
/// `null` entries for empty slots) or `null` if the array has no children.
typedef ArrayValidatorFn<T> = String? Function(List<T?>? value);

// ---------------------------------------------------------------------------
// Built-in validators
// ---------------------------------------------------------------------------

/// Validates that [value] is `true`. Typically used with
/// `FormControl<bool>` for "I agree" checkboxes.
String? requiredTrueValidator(bool? value) {
  if (value == true) {
    return null;
  }
  return 'required';
}

/// Validates that [value] is non-null and non-empty (for `String`,
/// `Iterable`, `List`, `Set`, and `Map`).
String? requiredValidator(dynamic value) {
  if (value == null) {
    return 'required';
  }
  if (value is String && value.trim().isEmpty) {
    return 'required';
  }
  if (value is Iterable && value.isEmpty) {
    return 'required';
  }
  if (value is Map && value.isEmpty) {
    return 'required';
  }
  return null;
}

/// Validates that a `String` value matches a basic email pattern.
///
/// Uses a permissive regex — it catches obviously wrong input but does
/// not attempt full RFC 5322 compliance.
String? emailValidator(String? value) {
  if (value == null || value.isEmpty) return null; // use with requiredValidator
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!regex.hasMatch(value)) {
    return 'invalid email';
  }
  return null;
}

// ---------------------------------------------------------------------------
// Factory validators (return a ValidatorFn so they can be parameterised)
// ---------------------------------------------------------------------------

/// Returns a validator that checks `String` length ≥ [length].
ValidatorFn<String> minLength(int length) {
  return (value) {
    if (value == null || value.isEmpty) return null; // defer to requiredValidator
    if (value.length < length) {
      return 'must be at least $length characters';
    }
    return null;
  };
}

/// Returns a validator that checks `String` length ≤ [length].
ValidatorFn<String> maxLength(int length) {
  return (value) {
    if (value == null) return null;
    if (value.length > length) {
      return 'must be at most $length characters';
    }
    return null;
  };
}

/// Returns a validator that checks a `num` value ≥ [minValue].
ValidatorFn<T> minValue<T extends num>(T minValue) {
  return (value) {
    if (value == null) return null;
    if (value < minValue) {
      return 'must be at least $minValue';
    }
    return null;
  };
}

/// Returns a validator that checks a `num` value ≤ [maxValue].
ValidatorFn<T> maxValue<T extends num>(T maxValue) {
  return (value) {
    if (value == null) return null;
    if (value > maxValue) {
      return 'must be at most $maxValue';
    }
    return null;
  };
}

/// Returns a validator that checks a `String` value against [regExp].
ValidatorFn<String> pattern(RegExp regExp, {String? message}) {
  return (value) {
    if (value == null || value.isEmpty) return null;
    if (!regExp.hasMatch(value)) {
      return message ?? 'invalid format';
    }
    return null;
  };
}

/// Returns a validator that checks this control's value equals
/// [other]'s value. Useful for "confirm password" fields.
///
/// The comparison runs every time the **current** control is validated.
/// To also re-validate when [other] changes, call
/// `other.addListener(() => thisControl.validate())`.
ValidatorFn<T> equalTo<T>(FormControl<T> other, {String? message}) {
  return (value) {
    if (value != other.value) {
      return message ?? 'values must match';
    }
    return null;
  };
}

// ---------------------------------------------------------------------------
// Compositors
// ---------------------------------------------------------------------------

/// Runs every validator in [validators] and returns the **first** error,
/// or `null` if all pass. This is the default behaviour of
/// `FormControl.validate()` — use `compose` when you want to build a
/// single `ValidatorFn` from multiple validators to pass into a
/// constructor or reuse across controls.
ValidatorFn<T> compose<T>(List<ValidatorFn<T>> validators) {
  return (value) {
    for (final v in validators) {
      final error = v(value);
      if (error != null) return error;
    }
    return null;
  };
}

/// Runs every validator in [validators] and returns `null` if **any**
/// passes (logical OR). Returns the **last** error if all fail.
ValidatorFn<T> composeOr<T>(List<ValidatorFn<T>> validators) {
  return (value) {
    String? lastError;
    for (final v in validators) {
      final error = v(value);
      if (error == null) return null;
      lastError = error;
    }
    return lastError;
  };
}
