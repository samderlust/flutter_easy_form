import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

import 'shared.dart';

class AddressesSection extends StatelessWidget {
  const AddressesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return EzyFormGroupArrayControl(
      formControlName: 'addresses',
      builder: (context, groupArray) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionHeader('Addresses (FormGroupArray)')),
              TextButton.icon(
                onPressed: () => groupArray.addGroup(),
                icon: const Icon(Icons.add),
                label: const Text('Add address'),
              ),
            ],
          ),
          if (groupArray.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                groupArray.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ...groupArray.controls.mapIndexed((group, i) => EzyFormWidget(
                formGroup: group,
                builder: (context, _) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Address ${i + 1}',
                                style: Theme.of(context).textTheme.labelLarge),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => groupArray.removeGroup(i),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        EzyFormControl<String>(
                          formControlName: 'street',
                          builder: (context, control, controller, focusNode) =>
                              styledTextField(
                            label: 'Street',
                            control: control,
                            controller: controller,
                            focusNode: focusNode,
                          ),
                        ),
                        const SizedBox(height: 8),
                        EzyFormControl<String>(
                          formControlName: 'city',
                          builder: (context, control, controller, focusNode) =>
                              styledTextField(
                            label: 'City',
                            control: control,
                            controller: controller,
                            focusNode: focusNode,
                          ),
                        ),
                        const SizedBox(height: 8),
                        EzyFormControl<String>(
                          formControlName: 'zip',
                          builder: (context, control, controller, focusNode) =>
                              TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(labelText: 'Zip'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
