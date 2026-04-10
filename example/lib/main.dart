import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ezy_form example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DynamicFormExample(),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom array-level validator demonstrating `arrayValidators` (added in
// 0.0.2). It receives the aggregated values list and runs once per array.
// ---------------------------------------------------------------------------
String? minTwoTags(List<String?>? values) {
  if (values == null || values.length < 2) return 'Add at least 2 tags';
  return null;
}

// ---------------------------------------------------------------------------
// The form definition. Demonstrates:
//   * FormGroup at the top
//   * Nested FormGroup (`info`)
//   * FormControl<String> / <bool> with initial values (so reset is visible)
//   * FormArrayControl with BOTH per-item validators AND arrayValidators
//   * requiredValidator / requiredTrueValidator
// ---------------------------------------------------------------------------
final form = FormGroup({
  // String field WITH an initial value — `reset()` will restore it.
  'name': FormControl<String>('Sam', validators: [requiredValidator]),

  // String field starting empty.
  'email': FormControl<String>(null, validators: [requiredValidator]),

  // Dropdown.
  'gender': FormControl<String>(null, validators: [requiredValidator]),

  // Bool checkbox with `requiredTrueValidator`.
  'agreed': FormControl<bool>(false, validators: [requiredTrueValidator]),

  // Array with BOTH per-item rules (each child must be non-empty)
  // AND an array-level rule (must have at least 2 entries).
  'tags': FormArrayControl<String>(
    null,
    validators: [requiredValidator],
    arrayValidators: [minTwoTags],
  ),

  // Nested FormGroup with initial values — `reset()` restores 'Sam' / 'Derlust'.
  'info': FormGroup({
    'firstName': FormControl<String>('Tonny', validators: [requiredValidator]),
    'lastName': FormControl<String>('Alex', validators: [requiredValidator]),
  }),
});

class DynamicFormExample extends StatelessWidget {
  const DynamicFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ezy_form example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EzyFormWidget(
          formGroup: form,
          builder: (context, model) => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileSection(),
              SizedBox(height: 16),
              _TopLevelSection(),
              SizedBox(height: 16),
              _TagsSection(),
              SizedBox(height: 16),
              _AgreedSection(),
              SizedBox(height: 24),
              _ActionsSection(),
              SizedBox(height: 24),
              _LiveStatePanel(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nested FormGroup section: `info.firstName`, `info.lastName`.
// Demonstrates dotted-path lookup via formControlName: 'info.firstName'.
// ---------------------------------------------------------------------------
class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Profile (nested FormGroup)'),
        EzyFormControl<String>(
          formControlName: 'info.firstName',
          builder: (context, control) => ControlledTextField(
            control: control,
            decoration: const InputDecoration(labelText: 'First name'),
          ),
        ),
        EzyFormControl<String>(
          formControlName: 'info.lastName',
          builder: (context, control) => ControlledTextField(
            control: control,
            decoration: const InputDecoration(labelText: 'Last name'),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Top-level controls: text + dropdown.
// ---------------------------------------------------------------------------
class _TopLevelSection extends StatelessWidget {
  const _TopLevelSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Top-level controls'),
        EzyFormControl<String>(
          formControlName: 'name',
          builder: (context, control) => ControlledTextField(
            control: control,
            decoration: const InputDecoration(labelText: 'Display name'),
          ),
        ),
        EzyFormControl<String>(
          formControlName: 'email',
          builder: (context, control) => ControlledTextField(
            control: control,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
        ),
        EzyFormControl<String>(
          formControlName: 'gender',
          builder: (context, control) => DropdownButtonFormField<String>(
            initialValue: control.value,
            onChanged: (value) => control.setValue(value),
            decoration: InputDecoration(
              labelText: 'Gender',
              errorText: control.valid ? null : control.error,
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// FormArrayControl section. Demonstrates:
//   * arrayControl.add()
//   * arrayControl.remove(index)
//   * arrayControl.removeAll()        (NEW in 1.0.0)
//   * arrayValidators showing an array-level error (NEW in 0.0.2)
//   * per-item validators showing a child-level error
// ---------------------------------------------------------------------------
class _TagsSection extends StatelessWidget {
  const _TagsSection();

  @override
  Widget build(BuildContext context) {
    return EzyFormArrayControl<String>(
      formControlName: 'tags',
      builder: (context, arrayControl) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Tags (FormArrayControl + arrayValidators)'),
          Row(
            children: [
              const Text('Tags:'),
              const Spacer(),
              TextButton.icon(
                onPressed: () => arrayControl.add(),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
              TextButton.icon(
                onPressed: () => arrayControl.removeAll(),
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Remove all'),
              ),
            ],
          ),
          if (!arrayControl.valid && arrayControl.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                arrayControl.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ...(arrayControl.controls ?? []).mapIndexed(
            (control, index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextFormField(
                key: ValueKey(control.hashCode),
                initialValue: control.value,
                decoration: InputDecoration(
                  labelText: 'Tag ${index + 1}',
                  errorText: control.valid ? null : control.error,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => arrayControl.remove(index),
                  ),
                ),
                onChanged: (value) => control.setValue(value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bool field with `requiredTrueValidator`.
// ---------------------------------------------------------------------------
class _AgreedSection extends StatelessWidget {
  const _AgreedSection();

  @override
  Widget build(BuildContext context) {
    return EzyFormControl<bool>(
      formControlName: 'agreed',
      builder: (context, control) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: control.value ?? false,
            onChanged: (value) => control.setValue(value),
            title: const Text('I agree to the terms'),
            contentPadding: EdgeInsets.zero,
          ),
          if (!control.valid)
            Text(
              'You must agree to continue',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Actions row, rendered through `EzyFormConsumer` so it has access to the
// surrounding FormGroup without lifting state. Demonstrates:
//   * form.validate()
//   * form.reset()      (NEW semantic in 1.0.0 — restores initial values)
//   * form.clear()      (NEW in 1.0.0 — wipes everything to null)
// ---------------------------------------------------------------------------
class _ActionsSection extends StatelessWidget {
  const _ActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Actions (EzyFormConsumer)'),
        EzyFormConsumer(
          builder: (context, form) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () {
                  final ok = form.validate();
                  debugPrint('submit valid=$ok values=${form.values}');
                },
                icon: const Icon(Icons.send),
                label: const Text('Submit (validate)'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  form.reset();
                  debugPrint('after reset: ${form.values}');
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset to initial'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  form.clear();
                  debugPrint('after clear: ${form.values}');
                },
                icon: const Icon(Icons.cleaning_services),
                label: const Text('Clear all'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Live state panel — also via `EzyFormConsumer`, so it rebuilds whenever
// any control in the group notifies. Surfaces:
//   * form.isValid / isDirty / isTouched
//   * form.values  (note: array values now include nulls — 0.0.2)
// ---------------------------------------------------------------------------
class _LiveStatePanel extends StatelessWidget {
  const _LiveStatePanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Live state'),
        EzyFormConsumer(
          builder: (context, form) => Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('isValid:   ${form.isValid}'),
                  Text('isDirty:   ${form.isDirty}'),
                  Text('isTouched: ${form.isTouched}'),
                  const SizedBox(height: 8),
                  const Text('values:'),
                  Text(form.values.toString()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable bridge from `FormControl<String>` to a Material `TextField`.
//
// Handles:
//   * keeping the TextEditingController in sync when the FormControl is
//     `reset()` / `clear()` / `setValue()` from elsewhere
//   * marking the control as touched on blur (focus loss)
//   * surfacing `error` and `dirty` / `touched` in the InputDecoration
//
// This boilerplate would go away if `ezy_form` shipped a first-party
// `EzyTextField` — see `plan/improvement_plan.md` #4.
// ---------------------------------------------------------------------------
class ControlledTextField extends HookWidget {
  const ControlledTextField({
    super.key,
    required this.control,
    this.decoration,
  });

  final FormControl<String> control;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final textCtrl = useTextEditingController(text: control.value ?? '');
    final focusNode = useFocusNode();

    // Sync TextEditingController text whenever the FormControl's value
    // changes from the outside (reset/clear/setValue from elsewhere).
    useEffect(() {
      void listener() {
        final next = control.value ?? '';
        if (textCtrl.text != next) {
          textCtrl.text = next;
        }
      }

      control.addListener(listener);
      return () => control.removeListener(listener);
    }, [control]);

    // Mark the control as touched when focus leaves the field.
    useEffect(() {
      void onFocus() {
        if (!focusNode.hasFocus) control.markAsTouched();
      }

      focusNode.addListener(onFocus);
      return () => focusNode.removeListener(onFocus);
    }, [focusNode]);

    return TextField(
      controller: textCtrl,
      focusNode: focusNode,
      onChanged: control.setValue,
      decoration: (decoration ?? const InputDecoration()).copyWith(
        errorText: control.valid ? null : control.error,
        helperText: control.isDirty
            ? 'dirty'
            : control.isTouched
                ? 'touched'
                : null,
      ),
    );
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<R> mapIndexed<R>(R Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}
