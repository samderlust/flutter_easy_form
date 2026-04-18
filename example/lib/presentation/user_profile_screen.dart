import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

import '../data/user_profile_repository.dart';
import 'widgets/actions_section.dart';
import 'widgets/addresses_section.dart';
import 'widgets/agreed_section.dart';
import 'widgets/dynamic_fields_section.dart';
import 'widgets/greeting_banner.dart';
import 'widgets/live_state_panel.dart';
import 'widgets/profile_section.dart';
import 'widgets/tags_section.dart';
import 'widgets/top_level_section.dart';

/// Custom array-level validator.
String? minTwoTags(List<String?>? values) {
  if (values == null || values.length < 2) return 'Add at least 2 tags';
  return null;
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.repo});

  final UserProfileRepository repo;

  @override
  Widget build(BuildContext context) {
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
      'addresses': FormGroupArray(
        [
          FormGroup({
            'street': FormControl<String>('123 Main St',
                validators: [requiredValidator]),
            'city': FormControl<String>('New York',
                validators: [requiredValidator]),
            'zip': FormControl<String>('10001'),
          }),
        ],
        templateFactory: () => FormGroup({
          'street':
              FormControl<String>(null, validators: [requiredValidator]),
          'city':
              FormControl<String>(null, validators: [requiredValidator]),
          'zip': FormControl<String>(null),
        }),
      ),
      'info': FormGroup({
        'firstName':
            FormControl<String>('Tonny', validators: [requiredValidator]),
        'lastName':
            FormControl<String>('Alex', validators: [requiredValidator]),
      }),
    });

    return Scaffold(
      appBar: AppBar(title: const Text('ezy_form example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EzyFormWidget(
          formGroup: form,
          builder: (context, model) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileSection(),
              const SizedBox(height: 16),
              const TopLevelSection(),
              const SizedBox(height: 16),
              const TagsSection(),
              const SizedBox(height: 16),
              const AddressesSection(),
              const SizedBox(height: 16),
              const DynamicFieldsSection(),
              const SizedBox(height: 16),
              const AgreedSection(),
              const SizedBox(height: 16),
              const GreetingBanner(),
              const SizedBox(height: 24),
              ActionsSection(repo: repo),
              const SizedBox(height: 24),
              const LiveStatePanel(),
            ],
          ),
        ),
      ),
    );
  }
}
