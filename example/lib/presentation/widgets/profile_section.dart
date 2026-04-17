import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

import 'shared.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Profile (nested FormGroup)'),
        EzyFormControl<String>(
          formControlName: 'info.firstName',
          builder: (context, control, controller, focusNode) =>
              styledTextField(
            label: 'First name',
            control: control,
            controller: controller,
            focusNode: focusNode,
          ),
        ),
        EzyFormControl<String>(
          formControlName: 'info.lastName',
          builder: (context, control, controller, focusNode) =>
              styledTextField(
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
