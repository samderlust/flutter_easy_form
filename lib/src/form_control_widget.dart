import 'package:flutter/widgets.dart';

import '../ezy_form.dart';
import 'providers/ezy_form_provider.dart';
import 'providers/form_control_provider.dart';

/// A widget to consume a [FormControl].
///
/// [EzyFormControl] must be placed within an [EzyFormWidget].
///
/// The [builder] receives a [FormControl], a [TextEditingController], and a
/// [FocusNode]. For text inputs, wire the controller and focus node to your
/// widget — the binding keeps them in sync with the model automatically,
/// including external writes from [FormGroup.reset], [FormGroup.clear],
/// [FormGroup.patchValue], etc. For non-text inputs (checkbox, dropdown,
/// slider, etc.) simply ignore the controller and focus node (`_, __`) and
/// use `control.setValue(...)` / `control.value` directly.
///
/// For `FormControl<String>` the controller auto-syncs with no extra
/// configuration. For other types (e.g. `int`, `double`, `DateTime`),
/// supply [parse] and [format] to translate between the
/// [TextEditingController]'s text and the model value.
///
/// Example — text field:
/// ```dart
/// EzyFormControl<String>(
///   formControlName: 'email',
///   builder: (context, control, controller, focusNode) => TextField(
///     controller: controller,
///     focusNode: focusNode,
///     decoration: InputDecoration(
///       labelText: 'Email',
///       errorText: control.valid ? null : control.error,
///     ),
///   ),
/// )
/// ```
///
/// Example — checkbox (ignore controller/focusNode):
/// ```dart
/// EzyFormControl<bool>(
///   formControlName: 'agreed',
///   builder: (context, control, _, __) => Checkbox(
///     value: control.value ?? false,
///     onChanged: (v) => control.setValue(v),
///   ),
/// )
/// ```
///
/// Example — typed text field:
/// ```dart
/// EzyFormControl<int>(
///   formControlName: 'age',
///   parse: int.tryParse,
///   format: (v) => v?.toString() ?? '',
///   builder: (context, control, controller, focusNode) => TextField(
///     controller: controller,
///     focusNode: focusNode,
///     keyboardType: TextInputType.number,
///   ),
/// )
/// ```
///
/// Example — direct control reference (e.g. inside a [FormArrayControl]):
/// ```dart
/// EzyFormControl<String>(
///   formControl: arrayControl.controls![i],
///   builder: (context, control, controller, focusNode) => TextField(
///     controller: controller,
///     focusNode: focusNode,
///   ),
/// )
/// ```
class EzyFormControl<T> extends StatefulWidget {
  const EzyFormControl({
    super.key,
    this.formControlName,
    this.formControl,
    required this.builder,
    this.parse,
    this.format,
    this.controller,
    this.focusNode,
  }) : assert(
          formControlName != null || formControl != null,
          'Either formControlName or formControl must be provided.',
        );

  /// Dotted-path name of the [FormControl] to bind to. Resolved from the
  /// nearest ancestor [EzyFormWidget].
  ///
  /// Either [formControlName] or [formControl] must be provided, but not
  /// both.
  final String? formControlName;

  /// A direct [FormControl] reference to bind to. Use this when the
  /// control is not registered in a [FormGroup] (e.g. children of a
  /// [FormArrayControl]).
  ///
  /// Either [formControlName] or [formControl] must be provided.
  final FormControl<T>? formControl;

  /// Renders the bound widget. Receives the current [FormControl] (so you
  /// can read `valid` / `error` / `dirty` / `touched`), a
  /// [TextEditingController] for text inputs, and a [FocusNode] that
  /// marks the control as touched on blur. Ignore the last two for
  /// non-text inputs.
  final Widget Function(
    BuildContext context,
    FormControl<T> control,
    TextEditingController controller,
    FocusNode focusNode,
  ) builder;

  /// Translates the user's typed text into a `T?` value for the
  /// [FormControl]. Only needed when `T` is not `String`. Return `null`
  /// for unparseable input — the binding will write `null` to the control
  /// without overwriting the user's raw text in the field.
  final T? Function(String text)? parse;

  /// Translates a `T?` model value into text for the field. Only needed
  /// when `T` is not `String`. Called on external writes (e.g.
  /// `patchValue`, `reset`, `clear`).
  final String Function(T? value)? format;

  /// Optional externally-owned [TextEditingController]. When omitted, the
  /// widget creates and disposes one internally.
  final TextEditingController? controller;

  /// Optional externally-owned [FocusNode]. When omitted, the widget
  /// creates and disposes one internally.
  final FocusNode? focusNode;

  @override
  State<EzyFormControl<T>> createState() => _EzyFormControlState<T>();
}

class _EzyFormControlState<T> extends State<EzyFormControl<T>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late bool _ownsController;
  late bool _ownsFocusNode;
  FormControl<T>? _control;

  /// Whether the controller sync should be active. True when `T` is
  /// `String` (identity sync) or when [parse]/[format] are provided.
  bool get _shouldSync => T == String || widget.parse != null;

  /// True while writing to the controller from a control-side change —
  /// suppresses [_onControllerChanged].
  bool _syncing = false;

  /// True while writing to the control from a controller-side change —
  /// suppresses [_syncFromControl] so the binding never rewrites the
  /// user's raw text mid-keystroke when `format(parse(x)) != x`.
  bool _userEditing = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onControllerChanged);
  }

  // -- Parse / format hooks ------------------------------------------------

  T? _parseText(String text) {
    if (widget.parse != null) return widget.parse!(text);
    // T is String — identity.
    return text as T;
  }

  String _formatValue(T? value) {
    if (widget.format != null) return widget.format!(value);
    // T is String — identity.
    return (value as String?) ?? '';
  }

  // -- Bind to a FormControl -----------------------------------------------

  void _bindControl(FormControl<T> control) {
    if (identical(_control, control)) return;
    _control?.removeListener(_onControlChanged);
    _control = control;
    control.addListener(_onControlChanged);
    _syncFromControl();
  }

  // -- Two-way sync --------------------------------------------------------

  void _onControlChanged() => _syncFromControl();

  void _syncFromControl() {
    if (!_shouldSync || _userEditing) return;
    final next = _formatValue(_control?.value);
    if (_controller.text == next) return;
    _syncing = true;
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    _syncing = false;
  }

  void _onControllerChanged() {
    if (!_shouldSync || _syncing) return;
    final control = _control;
    if (control == null) return;
    _userEditing = true;
    try {
      control.setValue(_parseText(_controller.text));
    } finally {
      _userEditing = false;
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _control?.markAsTouched();
    }
  }

  // -- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final control = widget.formControl ??
        EzyFormProvider.of(context).control<T>(widget.formControlName!);
    _bindControl(control);

    return EzyFormControlProvider<T>(
      notifier: control,
      child: ListenableBuilder(
        listenable: control,
        builder: (context, _) =>
            widget.builder(context, control, _controller, _focusNode),
      ),
    );
  }

  // -- Dispose -------------------------------------------------------------

  @override
  void dispose() {
    _control?.removeListener(_onControlChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onControllerChanged);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }
}
