import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

import 'shared.dart';

class TagsSection extends StatelessWidget {
  const TagsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return EzyFormArrayControl<String>(
      formControlName: 'tags',
      builder: (context, arrayControl) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Tags (FormArrayControl + arrayValidators)'),
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
              child: EzyFormControl<String>(
                formControl: control,
                builder: (context, ctrl, controller, focusNode) => TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Tag ${index + 1}',
                    errorText: ctrl.valid ? null : ctrl.error,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => arrayControl.remove(index),
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
