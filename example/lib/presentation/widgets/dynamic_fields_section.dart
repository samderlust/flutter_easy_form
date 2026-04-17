import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

import 'shared.dart';

class DynamicFieldsSection extends StatelessWidget {
  const DynamicFieldsSection({super.key});

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
          const SectionHeader('Dynamic fields (addControl / removeControl)'),
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
                      FormControl<String>(
                          null, validators: [requiredValidator]),
                    );
                  } else {
                    form.removeControl(entry.key);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
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
