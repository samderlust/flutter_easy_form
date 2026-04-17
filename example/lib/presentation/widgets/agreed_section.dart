import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

class AgreedSection extends StatelessWidget {
  const AgreedSection({super.key});

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
        // EzyFormControlWatcher: conditionally shows the license number
        // field when 'agreed' is true.
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
