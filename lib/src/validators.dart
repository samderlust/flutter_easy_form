typedef ValidatorFn<T> = String? Function(T? value);
typedef ArrayValidatorFn<T> = String? Function(List<T>? value);

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
