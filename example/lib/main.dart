import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'user_profile.dart';
import 'user_profile_repository.dart';

void main() => runApp(const MyApp());

final repo = UserProfileRepository();

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
// Custom array-level validator.
// ---------------------------------------------------------------------------
String? minTwoTags(List<String?>? values) {
  if (values == null || values.length < 2) return 'Add at least 2 tags';
  return null;
}

// ---------------------------------------------------------------------------
// Form definition.
// The email field uses an async validator that checks the repo for
// availability — demonstrating async validation with a simulated API call.
// ---------------------------------------------------------------------------
final form = FormGroup({
  'name': FormControl<String>('Sam', validators: [
    requiredValidator,
    minLength(2),
  ]),
  'email': FormControl<String>(null, validators: [
    requiredValidator,
    emailValidator,
  ], asyncValidators: [
    repo.checkEmailAvailability,
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
              _DynamicFieldsSection(),
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
// Nested FormGroup section.
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
// Top-level controls.
// The email field shows pending state while async validation runs.
// Try typing "taken@email.com" to see the async error.
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
          builder: (context, control, controller, focusNode) =>
              _styledTextField(
            label: 'Display name',
            control: control,
            controller: controller,
            focusNode: focusNode,
          ),
        ),
        // Email with async validator — shows a spinner while checking.
        EzyFormControl<String>(
          formControlName: 'email',
          builder: (context, control, controller, focusNode) => TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: 'Email (try "taken@email.com")',
              errorText: control.valid ? null : control.error,
              suffixIcon: control.pending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              helperText: control.pending
                  ? 'checking availability...'
                  : control.isDirty
                      ? 'dirty'
                      : control.isTouched
                          ? 'touched'
                          : null,
            ),
          ),
        ),
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
// Dynamic fields — demonstrates addControl / removeControl.
// Users can add optional fields (phone, website) at runtime.
// ---------------------------------------------------------------------------
class _DynamicFieldsSection extends StatelessWidget {
  const _DynamicFieldsSection();

  static const _optionalFields = {
    'phone': 'Phone number',
    'website': 'Website URL',
    'company': 'Company name',
  };

  @override
  Widget build(BuildContext context) {
    return EzyFormConsumer(
      builder: (context, form) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Dynamic fields (addControl / removeControl)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _optionalFields.entries.map((entry) {
              final exists = form.containsControl(entry.key);
              return FilterChip(
                label: Text(entry.value),
                selected: exists,
                onSelected: (selected) {
                  if (selected) {
                    form.addControl(
                      entry.key,
                      FormControl<String>(null, validators: [requiredValidator]),
                    );
                  } else {
                    form.removeControl(entry.key);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Render text fields for each active dynamic control.
          ..._optionalFields.entries
              .where((e) => form.containsControl(e.key))
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: EzyFormControl<String>(
                    formControlName: entry.key,
                    builder: (context, control, controller, focusNode) =>
                        TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: entry.value,
                        errorText: control.valid ? null : control.error,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => form.removeControl(entry.key),
                        ),
                      ),
                    ),
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
// EzyFormWatcher demo.
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
// Actions row.
// Submit uses validateAsync() to run both sync and async validators,
// then converts to a model and calls the repo.
// Load from server uses the repo to fetch a model, then patches the form.
// ---------------------------------------------------------------------------
class _ActionsSection extends StatefulWidget {
  const _ActionsSection();

  @override
  State<_ActionsSection> createState() => _ActionsSectionState();
}

class _ActionsSectionState extends State<_ActionsSection> {
  bool _loading = false;

  Future<void> _runAsync(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Actions (EzyFormConsumer)'),
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(),
          ),
        EzyFormConsumer(
          builder: (context, form) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _loading
                    ? null
                    : () => _runAsync(() async {
                          final ok = await form.validateAsync();
                          if (ok) {
                            final profile =
                                UserProfile.fromMap(form.values);
                            await repo.saveProfile(profile);
                            debugPrint('saved: $profile');
                          } else {
                            debugPrint('form is invalid');
                          }
                        }),
                icon: const Icon(Icons.send),
                label: const Text('Submit'),
              ),
              OutlinedButton.icon(
                onPressed: _loading
                    ? null
                    : () => _runAsync(() async {
                          final profile = await repo.fetchProfile();
                          form.patchValue(profile.toMap());
                          debugPrint('loaded: $profile');
                        }),
                icon: const Icon(Icons.cloud_download),
                label: const Text('Load from server'),
              ),
              OutlinedButton.icon(
                onPressed: _loading
                    ? null
                    : () {
                        form.reset();
                        debugPrint('after reset: ${form.values}');
                      },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset to initial'),
              ),
              OutlinedButton.icon(
                onPressed: _loading
                    ? null
                    : () {
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
// Live state panel.
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
                  Text('isPending: ${form.isPending}'),
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
