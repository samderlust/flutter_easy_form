import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EzyFormWatcher', () {
    testWidgets('rebuilds with selector result when any control changes',
        (tester) async {
      final form = FormGroup({
        'name': FormControl<String>('Sam'),
        'age': FormControl<int>(25),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => EzyFormWatcher<String>(
                selector: (f) =>
                    '${f.control<String>('name').value} is ${f.control<int>('age').value}',
                builder: (context, value) => Text(value),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sam is 25'), findsOneWidget);

      form.control<String>('name').setValue('Alex');
      await tester.pumpAndSettle();

      expect(find.text('Alex is 25'), findsOneWidget);

      form.control<int>('age').setValue(30);
      await tester.pumpAndSettle();

      expect(find.text('Alex is 30'), findsOneWidget);
    });

    testWidgets('works with Dart records for type-safe multi-value watching',
        (tester) async {
      final form = FormGroup({
        'agreed': FormControl<bool>(false),
        'name': FormControl<String>('Sam'),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) =>
                  EzyFormWatcher<(bool?, String?)>(
                selector: (f) => (
                  f.control<bool>('agreed').value,
                  f.control<String>('name').value,
                ),
                builder: (context, values) {
                  final (agreed, name) = values;
                  if (agreed != true) return const Text('Not agreed');
                  return Text('Welcome, $name!');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Not agreed'), findsOneWidget);

      form.control<bool>('agreed').setValue(true);
      await tester.pumpAndSettle();

      expect(find.text('Welcome, Sam!'), findsOneWidget);

      form.control<String>('name').setValue('Alex');
      await tester.pumpAndSettle();

      expect(find.text('Welcome, Alex!'), findsOneWidget);
    });

    testWidgets('works with nested group controls', (tester) async {
      final form = FormGroup({
        'info': FormGroup({
          'firstName': FormControl<String>('Sam'),
          'lastName': FormControl<String>('D'),
        }),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => EzyFormWatcher<String>(
                selector: (f) =>
                    '${f.control<String>('info.firstName').value} ${f.control<String>('info.lastName').value}',
                builder: (context, fullName) => Text(fullName),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sam D'), findsOneWidget);

      form.control<String>('info.lastName').setValue('Nguyen');
      await tester.pumpAndSettle();

      expect(find.text('Sam Nguyen'), findsOneWidget);
    });

    testWidgets('can derive computed values like form validity',
        (tester) async {
      final form = FormGroup({
        'email': FormControl<String>(null, validators: [requiredValidator]),
        'name': FormControl<String>(null, validators: [requiredValidator]),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => Column(
                children: [
                  EzyFormWatcher<bool>(
                    selector: (f) => f.isValid,
                    builder: (context, isValid) => ElevatedButton(
                      onPressed: isValid ? () {} : null,
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Validate first to populate errors — both fields are null so invalid
      form.validate();
      await tester.pumpAndSettle();

      final button1 =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button1.onPressed, isNull);

      form.control<String>('email').setValue('test@test.com');
      form.control<String>('name').setValue('Sam');
      form.validate();
      await tester.pumpAndSettle();

      final button2 =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button2.onPressed, isNotNull);
    });
  });
}
