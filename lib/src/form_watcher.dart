import 'package:flutter/widgets.dart';

import 'providers/ezy_form_provider.dart';
import 'models/form_group.dart';

/// Watches the entire [FormGroup] and rebuilds when any control changes,
/// but only passes the result of a [selector] function to the [builder].
///
/// Use this when you need to react to **multiple controls** or compute a
/// derived value — for example, enabling a submit button only when two
/// fields match, or building a summary from several inputs.
///
/// The [selector] extracts the data you care about from the [FormGroup].
/// Use a Dart record to combine multiple values with full type safety:
///
/// ```dart
/// EzyFormWatcher(
///   selector: (form) => (
///     form.control<bool>('agreed').value,
///     form.control<String>('name').value,
///   ),
///   builder: (context, values) {
///     final (agreed, name) = values;
///     if (agreed != true) return const SizedBox.shrink();
///     return Text('Welcome, $name!');
///   },
/// )
/// ```
///
/// Unlike [EzyFormControlWatcher], which listens to a single control,
/// `EzyFormWatcher` listens to **all** controls in the [FormGroup]
/// (via `Listenable.merge`). This means it rebuilds whenever *any*
/// control notifies — use [selector] to keep rebuilds cheap by returning
/// only the slice you need.
///
/// `EzyFormWatcher` must be placed inside an [EzyFormWidget].
class EzyFormWatcher<R> extends StatefulWidget {
  const EzyFormWatcher({
    super.key,
    required this.selector,
    required this.builder,
  });

  /// Extracts the value(s) to watch from the [FormGroup].
  /// Called on every rebuild — keep it fast.
  final R Function(FormGroup form) selector;

  /// Called whenever any control in the group notifies.
  /// Receives the result of [selector].
  final Widget Function(BuildContext context, R value) builder;

  @override
  State<EzyFormWatcher<R>> createState() => _EzyFormWatcherState<R>();
}

class _EzyFormWatcherState<R> extends State<EzyFormWatcher<R>> {
  late FormGroup _form;
  late Listenable _merged;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _form = EzyFormProvider.of(context);
    _merged = Listenable.merge([
      _form,
      ..._form.flatControls.whereType<Listenable>(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _merged,
      builder: (context, _) => widget.builder(context, widget.selector(_form)),
    );
  }
}
