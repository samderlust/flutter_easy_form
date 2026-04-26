/// [FormControlBase] is an abstract interface class that represents a
/// form control.
///
/// A form control can be validated, reset, or cleared, and can be marked
/// as dirty or touched.
abstract interface class FormControlBase<T> {
  /// Validates the form control.
  void validate();

  /// Resets the form control back to its **initial** state — the value
  /// (or shape, for arrays) it was constructed with.
  void reset();

  /// Clears the form control to an **empty** state — values become `null`
  /// and `dirty` / `touched` / `error` are cleared. For arrays, the
  /// existing children are kept and each child's value is nulled.
  void clear();

  /// Marks the form control as dirty.
  void markAsDirty();

  /// Marks the form control as touched.
  void markAsTouched();

  /// Disables the control. Disabled controls are skipped by [validate]
  /// and excluded from [FormGroup.values].
  void markAsDisabled();

  /// Re-enables a previously disabled control.
  void markAsEnabled();

  /// Indicates if the form control is valid.
  bool get valid;

  /// Indicates if the form control is dirty.
  bool get isDirty;

  /// Indicates if the form control is touched.
  bool get isTouched;

  /// Whether the control is enabled. Disabled controls are skipped by
  /// validation and excluded from [FormGroup.values].
  bool get enabled;

  /// Whether the control is disabled.
  bool get disabled;
}
