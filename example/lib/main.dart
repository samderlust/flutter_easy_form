import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
//   * FormControl<String> / <bool> / <int> with initial values
//     (so reset is visible)
//   * FormArrayControl with BOTH per-item validators AND arrayValidators
//   * requiredValidator / requiredTrueValidator
// ---------------------------------------------------------------------------
final form = FormGroup({
  // String field with initial value + minLength validator.
  'name': FormControl<String>('Sam', validators: [
    requiredValidator,
    minLength(2),
  ]),

  // Email field — uses the built-in emailValidator.
  'email': FormControl<String>(null, validators: [
    requiredValidator,
    emailValidator,
  ]),

  // Numeric field — uses built-in min/max validators.
  'age': FormControl<int>(
    25,
    validators: [
      requiredValidator,
      minValue(18),
      maxValue(120),
    ],
  ),

  // Dropdown.
  'gender': FormControl<String>(null, validators: [requiredValidator]),

  // Bool checkbox with `requiredTrueValidator`.
  'agreed': FormControl<bool>(false, validators: [requiredTrueValidator]),

  // Only shown when 'agreed' is true — demonstrates EzyFormControlWatcher.
  'licenseNumber': FormControl<String>(null),

  // Array with BOTH per-item rules (each child must be non-empty)
  // AND an array-level rule (must have at least 2 entries).
  'tags': FormArrayControl<String>(
    null,
    validators: [requiredValidator],
    arrayValidators: [minTwoTags],
  ),

  // Nested FormGroup with initial values — `reset()` restores them.
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
              SizedBox(height: 16),
              _GreetingBanner(),
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
// The controller + focusNode are wired to the TextField, so reset /
// clear / patchValue all reflect into the text field automatically.
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
          builder: (context, control, controller, focusNode) =>
              _styledTextField(
            label: 'First name',
            control: control,
            controller: controller,
            focusNode: focusNode,
          ),
        ),
        EzyFormControl<String>(
          formControlName: 'info.lastName',
          builder: (context, control, controller, focusNode) =>
              _styledTextField(
            label: 'Last name',
            control: control,
            controller: controller,
            focusNode: focusNode,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Top-level controls: text + typed text + dropdown.
// Demonstrates all three EzyFormControl patterns in one section:
//   1. String — controller auto-syncs, no parse/format needed
//   2. int — provide parse + format for typed text binding
//   3. Dropdown — ignore controller/focusNode, use onChanged directly
// ---------------------------------------------------------------------------
class _TopLevelSection extends StatelessWidget {
  const _TopLevelSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Top-level controls'),
        // Pattern 1: String text field — controller auto-syncs.
        EzyFormControl<String>(
          formControlName: 'name',
          builder: (context, control, controller, focusNode) =>
              _styledTextField(
            label: 'Display name',
            control: control,
            controller: controller,
            focusNode: focusNode,
          ),
        ),
        EzyFormControl<String>(
          formControlName: 'email',
          builder: (context, control, controller, focusNode) =>
              _styledTextField(
            label: 'Email',
            control: control,
            controller: controller,
            focusNode: focusNode,
          ),
        ),
        // Pattern 2: Typed text field — provide parse + format.
        EzyFormControl<int>(
          formControlName: 'age',
          parse: int.tryParse,
          format: (value) => value?.toString() ?? '',
          builder: (context, control, controller, focusNode) => TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Age (FormControl<int>)',
              errorText: control.valid ? null : control.error,
              helperText: control.isDirty
                  ? 'dirty'
                  : control.isTouched
                      ? 'touched'
                      : null,
            ),
          ),
        ),
        // Pattern 3: Dropdown — ignore controller/focusNode.
        EzyFormControl<String>(
          formControlName: 'gender',
          builder: (context, control, _, __) => DropdownButtonFormField<String>(
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
// FormArrayControl section.
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
// Bool field + conditional field via EzyFormControlWatcher.
// The license number field only appears when 'agreed' is true.
// ---------------------------------------------------------------------------
class _AgreedSection extends StatelessWidget {
  const _AgreedSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EzyFormControl<bool>(
          formControlName: 'agreed',
          builder: (context, control, _, __) => Column(
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
        ),
        // EzyFormControlWatcher: watches 'agreed' and conditionally
        // shows the license number field without nesting inside the
        // checkbox builder.
        EzyFormControlWatcher<bool>(
          formControlName: 'agreed',
          builder: (context, agreed) {
            if (agreed != true) return const SizedBox.shrink();
            return EzyFormControl<String>(
              formControlName: 'licenseNumber',
              builder: (context, control, controller, focusNode) => TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'License number (shown when agreed)',
                  errorText: control.valid ? null : control.error,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// EzyFormWatcher demo: watches multiple controls via a selector function.
// Uses a Dart record for type-safe multi-value watching.
// ---------------------------------------------------------------------------
class _GreetingBanner extends StatelessWidget {
  const _GreetingBanner();

  @override
  Widget build(BuildContext context) {
    return EzyFormWatcher(
      selector: (form) => (
        form.control<String>('info.firstName').value,
        form.control<String>('info.lastName').value,
        form.control<bool>('agreed').value,
      ),
      builder: (context, values) {
        final (firstName, lastName, agreed) = values;
        if (agreed != true) return const SizedBox.shrink();
        return Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Welcome, ${firstName ?? ''} ${lastName ?? ''}!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Pretend "server response" used by the "Load from server" button below.
// ---------------------------------------------------------------------------
const _serverResponse = <String, dynamic>{
  'name': 'Loaded Name',
  'email': 'loaded@example.com',
  'age': 42,
  'gender': 'other',
  'agreed': true,
  'tags': ['flutter', 'dart', 'mobile'],
  'info': {
    'firstName': 'Loaded',
    'lastName': 'Server',
  },
};

// ---------------------------------------------------------------------------
// Actions row via `EzyFormConsumer`.
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
                  form.patchValue(_serverResponse);
                  debugPrint('after patchValue: ${form.values}');
                },
                icon: const Icon(Icons.cloud_download),
                label: const Text('Load from server'),
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
// Live state panel via `EzyFormConsumer`.
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
// Tiny presentation helper for text fields. All binding logic (controller
// sync, touched-on-blur) is handled by EzyFormControl itself.
// ---------------------------------------------------------------------------
Widget _styledTextField({
  required String label,
  required FormControl<String> control,
  required TextEditingController controller,
  required FocusNode focusNode,
}) {
  return TextField(
    controller: controller,
    focusNode: focusNode,
    decoration: InputDecoration(
      labelText: label,
      errorText: control.valid ? null : control.error,
      helperText: control.isDirty
          ? 'dirty'
          : control.isTouched
              ? 'touched'
              : null,
    ),
  );
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<R> mapIndexed<R>(R Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}
