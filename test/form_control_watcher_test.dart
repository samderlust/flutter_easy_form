import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EzyFormControlWatcher', () {
    testWidgets('rebuilds when the watched control changes', (tester) async {
      final form = FormGroup({
        'toggle': FormControl<bool>(false),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => EzyFormControlWatcher<bool>(
                formControlName: 'toggle',
                builder: (context, value) =>
                    Text(value == true ? 'ON' : 'OFF'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('OFF'), findsOneWidget);

      form.control<bool>('toggle').setValue(true);
      await tester.pumpAndSettle();

      expect(find.text('ON'), findsOneWidget);
    });

    testWidgets('conditionally shows a child widget', (tester) async {
      final form = FormGroup({
        'show': FormControl<bool>(false),
        'extra': FormControl<String>(null),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => Column(
                children: [
                  EzyFormControlWatcher<bool>(
                    formControlName: 'show',
                    builder: (context, show) {
                      if (show != true) return const SizedBox.shrink();
                      return EzyFormControl<String>(
                        formControlName: 'extra',
                        builder: (context, control, controller, focusNode) =>
                            TextField(
                          key: const ValueKey('extra'),
                          controller: controller,
                          focusNode: focusNode,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('extra')), findsNothing);

      form.control<bool>('show').setValue(true);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('extra')), findsOneWidget);

      form.control<bool>('show').setValue(false);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('extra')), findsNothing);
    });

    testWidgets('works with dotted paths', (tester) async {
      final form = FormGroup({
        'info': FormGroup({
          'age': FormControl<int>(20),
        }),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => EzyFormControlWatcher<int>(
                formControlName: 'info.age',
                builder: (context, age) => Text('Age: $age'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Age: 20'), findsOneWidget);

      form.control<int>('info.age').setValue(30);
      await tester.pumpAndSettle();

      expect(find.text('Age: 30'), findsOneWidget);
    });
  });
}
