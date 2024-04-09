abstract interface class FormControlBase<T> {
  void validate();
  void reset();
  void markAsDirty();
  void markAsTouched();

  bool get valid;
  bool get isDirty;
  bool get isTouched;
}
