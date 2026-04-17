import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'user_profile.dart';

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
// Simulates a server response — in a real app, the repository layer would
// parse JSON into UserProfile and then you'd patch the form with typed values.
// ---------------------------------------------------------------------------
UserProfile get _serverProfile => UserProfile(
      name: 'Loaded Name',
      email: 'loaded@example.com',
      age: 42,
      birthDate: DateTime(1985, 6, 15),
      gender: 'other',
      agreed: true,
      tags: ['flutter', 'dart', 'mobile'],
      firstName: 'Loaded',
      lastName: 'Server',
    );

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
//   * FormControl<String> / <bool> / <int> / <DateTime> with initial values
//   * FormArrayControl with BOTH per-item validators AND arrayValidators
//   * requiredValidator / requiredTrueValidator
// ---------------------------------------------------------------------------
final form = FormGroup({
  'name': FormControl<String>('Sam', validators: [
    requiredValidator,
    minLength(2),
  ]),
  'email': FormControl<String>(null, validators: [
    requiredValidator,
    emailValidator,
  ]),
  'age': FormControl<int>(
    25,
    validators: [requiredValidator, minValue(18), maxValue(120)],
  ),
  'birthDate': FormControl<DateTime>(DateTime(1990, 1, 15)),
  'gender': FormControl<String>(null, validators: [requiredValidator]),
  'agreed': FormControl<bool>(false, validators: [requiredTrueValidator]),
  'licenseNumber': FormControl<String>(null),
  'tags': FormArrayControl<String>(
    null,
    validators: [requiredValidator],
    arrayValidators: [minTwoTags],
  ),
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
// Top-level controls: text + typed text + date picker + dropdown.
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
        // Pattern 3: DateTime — date picker, ignores controller/focusNode.
        EzyFormControl<DateTime>(
          formControlName: 'birthDate',
          builder: (context, control, _, __) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              control.value != null
                  ? 'Birth date: ${_formatDate(control.value!)}'
                  : 'Birth date: not set',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: control.value ?? DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) control.setValue(picked);
            },
          ),
        ),
        // Pattern 4: Dropdown — ignore controller/focusNode.
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
// Actions row via `EzyFormConsumer`.
// Demonstrates:
//   * Submit → convert form.values to a UserProfile model
//   * Load from server → repo gives us a UserProfile, we patch it in
//   * Reset / Clear
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
                  if (ok) {
                    // form.values → typed model → send to API
                    final profile = UserProfile.fromMap(form.values);
                    debugPrint('submit: $profile');
                  } else {
                    debugPrint('form is invalid');
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text('Submit'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  // In a real app: repo fetches JSON → parses to model.
                  // Then model.toMap() patches the form with typed values.
                  final profile = _serverProfile;
                  form.patchValue(profile.toMap());
                  debugPrint('loaded from server: $profile');
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

String _formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

extension IndexedIterable<E> on Iterable<E> {
  Iterable<R> mapIndexed<R>(R Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}
