import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

import '../../data/user_profile.dart';
import '../../data/user_profile_repository.dart';
import 'shared.dart';

class ActionsSection extends StatefulWidget {
  const ActionsSection({super.key, required this.repo});

  final UserProfileRepository repo;

  @override
  State<ActionsSection> createState() => _ActionsSectionState();
}

class _ActionsSectionState extends State<ActionsSection> {
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
        const SectionHeader('Actions (EzyFormConsumer)'),
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
                            await widget.repo.saveProfile(profile);
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
                          final profile =
                              await widget.repo.fetchProfile();
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
