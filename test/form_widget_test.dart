import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final form = FormGroup({
  'email': FormControl<String>(null, validators: [requiredValidator]),
  'password': FormControl<String>(null, validators: [requiredValidator]),
  'agreed': FormControl<bool>(false, validators: [requiredTrueValidator]),
  'tags': FormArrayControl<String>(null, validators: [requiredValidator]),
  'profile': FormGroup({
    'firstName': FormControl<String>(null, validators: [requiredValidator]),
    'birthDate': FormControl<DateTime>(null, validators: [requiredValidator]),
    'hobbies': FormArrayControl<String>(null, validators: [requiredValidator]),
  }),
});
void main() {
  late Widget app;

  setUp(() {
    app = const MaterialApp(
      home: Scaffold(
        body: TestingFormApp(),
      ),
    );
  });

  testWidgets('form should render', (widgetTester) async {
    await widgetTester.pumpWidget(app);
    await widgetTester.pumpAndSettle();

    expect(find.text('Email'), findsOneWidget);
    expect(find.byType(EzyFormWidget), findsOneWidget);
    expect(find.byType(EzyFormControl<String>), findsOneWidget);
  });

  testWidgets('enter text should update formcontrol', (widgetTester) async {
    await widgetTester.pumpWidget(app);
    await widgetTester.pumpAndSettle();

    final email = find.byKey(const ValueKey('email'));
    await widgetTester.enterText(email, 'test');
    await widgetTester.pumpAndSettle();

    final submitBtn = find.byKey(const ValueKey('submit'));
    await widgetTester.tap(submitBtn);
    await widgetTester.pumpAndSettle();

    final _TestingFormAppState state =
        widgetTester.state<_TestingFormAppState>(find.byType(TestingFormApp));

    expect(state._formValues['email'], 'test');
  });

  testWidgets('reset form should clear form values', (widgetTester) async {
    await widgetTester.pumpWidget(app);
    await widgetTester.pumpAndSettle();

    final email = find.byKey(const ValueKey('email'));
    await widgetTester.enterText(email, 'test');
    await widgetTester.pumpAndSettle();

    final submitBtn = find.byKey(const ValueKey('submit'));
    await widgetTester.tap(submitBtn);
    await widgetTester.pumpAndSettle();

    final _TestingFormAppState state =
        widgetTester.state<_TestingFormAppState>(find.byType(TestingFormApp));

    expect(state._formValues['email'], 'test');

    final resetBtn = find.byKey(const ValueKey('reset'));
    await widgetTester.tap(resetBtn);
    await widgetTester.pumpAndSettle();

    expect(state._formValues['email'], null);
  });

  testWidgets('validate from consumer should validate form',
      (widgetTester) async {
    await widgetTester.pumpWidget(app);
    await widgetTester.pumpAndSettle();

    final validateBtn = find.byKey(const ValueKey('validate'));

    await widgetTester.tap(validateBtn);
    await widgetTester.pumpAndSettle();

    final state =
        widgetTester.state<_TestingFormAppState>(find.byType(TestingFormApp));

    final emailField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.key == const ValueKey('email') &&
          widget.decoration!.errorText == 'required',
    );

    expect(emailField, findsOneWidget);
    expect(state._formValues['email'], null);
    expect(state._form.isValid, false);
  });
}

class TestingFormApp extends StatefulWidget {
  const TestingFormApp({super.key});

  @override
  State<TestingFormApp> createState() => _TestingFormAppState();
}

class _TestingFormAppState extends State<TestingFormApp> {
  late Map<String, dynamic> _formValues;
  late FormGroup _form;

  @override
  Widget build(BuildContext context) {
    return EzyFormWidget(
      formGroup: form,
      builder: (context, form) {
        return Column(
          children: [
            EzyFormControl<String>(
              formControlName: 'email',
              builder: (context, control) => TextField(
                key: const ValueKey('email'),
                onChanged: (value) => control.setValue(value),
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: control.valid ? null : control.error,
                ),
              ),
            ),
            EzyFormConsumer(builder: (context, form) {
              return Row(
                children: [
                  ElevatedButton(
                    key: const ValueKey('submit'),
                    onPressed: () {
                      setState(() {
                        _formValues = form.values;
                      });
                    },
                    child: const Text('Submit'),
                  ),
                  ElevatedButton(
                    key: const ValueKey('reset'),
                    onPressed: () {
                      form.reset();
                      setState(() {
                        _formValues = form.values;
                      });
                    },
                    child: const Text('reset'),
                  ),
                  ElevatedButton(
                    key: const ValueKey('validate'),
                    onPressed: () {
                      form.validate();
                      setState(() {
                        _form = form;
                        _formValues = form.values;
                      });
                    },
                    child: const Text('validate'),
                  ),
                ],
              );
            })
          ],
        );
      },
    );
  }
}
