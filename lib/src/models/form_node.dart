/// Marker interface for types that can appear as values in a
/// [FormGroup]'s control map.
///
/// Only [FormControl], [FormArrayControl], [FormGroupArray], and
/// [FormGroup] implement this interface. Using `Map<String, FormNode>` instead of
/// `Map<String, Object>` catches invalid entries at compile time:
///
/// ```dart
/// // Compile error — int is not a FormNode:
/// FormGroup({'email': 42});
///
/// // OK:
/// FormGroup({'email': FormControl<String>(null)});
/// ```
abstract interface class FormNode {}
