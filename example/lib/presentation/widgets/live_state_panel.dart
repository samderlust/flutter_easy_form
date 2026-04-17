import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

import 'shared.dart';

class LiveStatePanel extends StatelessWidget {
  const LiveStatePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Live state'),
        EzyFormConsumer(
          builder: (context, form) => Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('isValid:   ${form.isValid}'),
                  Text('isDirty:   ${form.isDirty}'),
                  Text('isTouched: ${form.isTouched}'),
                  Text('isPending: ${form.isPending}'),
                  const SizedBox(height: 8),
                  const Text('values:'),
                  Text(form.values.toString()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
