typedef ValidatorFn<T> = String? Function(T? value);

/// Signature for validators applied to a [FormArrayControl] as a whole.
///
/// The validator receives the array's aggregated values (which may include
/// `null` entries for empty slots) or `null` if the array has no children.
typedef ArrayValidatorFn<T> = String? Function(List<T?>? value);

String? requiredTrueValidator(bool? value) {
  if (value == true) {
    return null;
  }
  return 'required';
}

String? requiredValidator(dynamic value) {
  if (value == null) {
    return 'required';
  }
  if ((value is String) && value.isEmpty) {
    return 'required';
  }

  if (value is Iterable && value.isEmpty) {
    return 'required';
  }

  if (value is Map && value.isEmpty) {
    return 'required';
  }

  if (value is List && value.isEmpty) {
    return 'required';
  }

  if (value is Set && value.isEmpty) {
    return 'required';
  }

  if (value is String && value.trim().isEmpty) {
    return 'required';
  }

  return null;
}
