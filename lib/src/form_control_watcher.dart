import 'package:flutter/widgets.dart';

import '../ezy_form.dart';
import 'providers/ezy_form_provider.dart';

/// Watches a single [FormControl] and rebuilds whenever its value changes.
///
/// Use this when you need to react to one control's value from a **different**
/// part of the widget tree — for example, conditionally showing a field
/// when a checkbox is checked, or displaying a live character count for a
/// text input.
///
/// The [builder] receives only the control's current **value** (not the
/// full [FormControl]), keeping the API minimal. If you need the full
/// control (to read `error`, `dirty`, `touched`, or to wire a
/// `TextEditingController`), use [EzyFormControl] instead.
///
/// `EzyFormControlWatcher` must be placed inside an [EzyFormWidget].
///
/// Example — show a field only when a checkbox is checked:
/// ```dart
/// EzyFormControlWatcher<bool>(
///   formControlName: 'agreed',
///   builder: (context, agreed) {
///     if (agreed != true) return const SizedBox.shrink();
///     return EzyFormControl<String>(
///       formControlName: 'licenseNumber',
///       builder: (context, control, controller, focusNode) => TextField(
///         controller: controller,
///         focusNode: focusNode,
///       ),
///     );
///   },
/// )
/// ```
class EzyFormControlWatcher<T> extends StatelessWidget {
  const EzyFormControlWatcher({
    super.key,
    required this.formControlName,
    required this.builder,
  });

  /// Dotted-path name of the [FormControl] to watch. Resolved from the
  /// nearest ancestor [EzyFormWidget].
  final String formControlName;

  /// Called whenever the watched control notifies. Receives the
  /// control's current value.
  final Widget Function(BuildContext context, T? value) builder;

  @override
  Widget build(BuildContext context) {
    final control = EzyFormProvider.of(context).control<T>(formControlName);
    return ListenableBuilder(
      listenable: control,
      builder: (context, _) => builder(context, control.value),
    );
  }
}
