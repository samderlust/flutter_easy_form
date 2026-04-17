import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shared.dart';

class TopLevelSection extends StatelessWidget {
  const TopLevelSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Top-level controls'),
        // Pattern 1: String text field — controller auto-syncs.
        EzyFormControl<String>(
          formControlName: 'name',
          builder: (context, control, controller, focusNode) =>
              styledTextField(
            label: 'Display name',
            control: control,
            controller: controller,
            focusNode: focusNode,
          ),
        ),
        // Pattern 2: Email with async validator — shows a spinner while checking.
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
        // Pattern 3: Typed text field — provide parse + format.
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
        // Pattern 4: DateTime — date picker, ignores controller/focusNode.
        EzyFormControl<DateTime>(
          formControlName: 'birthDate',
          builder: (context, control, _, __) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              control.value != null
                  ? 'Birth date: ${formatDate(control.value!)}'
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
        // Pattern 5: Dropdown — ignore controller/focusNode.
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
