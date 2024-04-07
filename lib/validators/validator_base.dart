typedef ValidatorFn<T> = String? Function(T? value);

abstract class AbstractValidator<T> {
  final String errorKey;
  final ValidatorFn<T> validate;
  AbstractValidator(this.errorKey, this.validate);
}

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
