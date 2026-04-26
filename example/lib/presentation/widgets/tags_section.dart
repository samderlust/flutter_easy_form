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
          const SectionHeader(
              'Tags (FormArrayControl + insert/move/addControl)'),
          Wrap(
            spacing: 4,
            children: [
              TextButton.icon(
                onPressed: () => arrayControl.add(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
              TextButton.icon(
                onPressed: () => arrayControl.insert(0, 'new-first'),
                icon: const Icon(Icons.vertical_align_top, size: 18),
                label: const Text('Insert at top'),
              ),
              TextButton.icon(
                onPressed: () => arrayControl.addControl(
                  FormControl<String>('custom',
                      validators: [minLength(3)]),
                ),
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Add custom'),
              ),
              TextButton.icon(
                onPressed: () => arrayControl.removeAll(),
                icon: const Icon(Icons.delete_sweep, size: 18),
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
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (index > 0)
                          IconButton(
                            icon: const Icon(Icons.arrow_upward, size: 18),
                            onPressed: () =>
                                arrayControl.move(index, index - 1),
                            tooltip: 'Move up',
                          ),
                        if (index <
                            (arrayControl.controls?.length ?? 0) - 1)
                          IconButton(
                            icon: const Icon(Icons.arrow_downward, size: 18),
                            onPressed: () =>
                                arrayControl.move(index, index + 1),
                            tooltip: 'Move down',
                          ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => arrayControl.remove(index),
                        ),
                      ],
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
