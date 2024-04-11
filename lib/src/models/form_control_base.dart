/// [FormControlBase] is an abstract interface class that represents a
/// form control.
///
/// A form control can be validated and reset, and can be marked as dirty
/// or touched.
abstract interface class FormControlBase<T> {
  /// Validates the form control.
  void validate();

  /// Resets the form control to its initial state.
  void reset();

  /// Marks the form control as dirty.
  void markAsDirty();

  /// Marks the form control as touched.
  void markAsTouched();

  /// Indicates if the form control is valid.
  bool get valid;

  /// Indicates if the form control is dirty.
  bool get isDirty;

  /// Indicates if the form control is touched.
  bool get isTouched;
}
