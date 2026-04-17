import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

class GreetingBanner extends StatelessWidget {
  const GreetingBanner({super.key});

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
