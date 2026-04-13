import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness(FormGroup form) {
  return MaterialApp(
    home: Scaffold(
      body: EzyFormWidget(
        formGroup: form,
        builder: (context, _) => EzyFormControl<String>(
          formControlName: 'name',
          builder: (context, control, controller, focusNode) => TextField(
            key: const ValueKey('name'),
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: 'Name',
              errorText: control.valid ? null : control.error,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('EzyFormControl text binding (String)', () {
    testWidgets('seeds the TextField from the FormControl initial value',
        (tester) async {
      final form = FormGroup({
        'name': FormControl<String>('Sam'),
      });

      await tester.pumpWidget(_harness(form));
      await tester.pumpAndSettle();

      final field =
          tester.widget<TextField>(find.byKey(const ValueKey('name')));
      expect(field.controller!.text, 'Sam');
    });

    testWidgets('typing flows back into the FormControl', (tester) async {
      final form = FormGroup({
        'name': FormControl<String>(null),
      });

      await tester.pumpWidget(_harness(form));
      await tester.enterText(find.byKey(const ValueKey('name')), 'edited');
      await tester.pumpAndSettle();

      expect(form.control<String>('name').value, 'edited');
      expect(form.control<String>('name').dirty, true);
    });

    testWidgets('reset() restores the initial value in the TextField',
        (tester) async {
      final form = FormGroup({
        'name': FormControl<String>('initial'),
      });

      await tester.pumpWidget(_harness(form));
      await tester.enterText(find.byKey(const ValueKey('name')), 'edited');
      await tester.pumpAndSettle();
      expect(form.control<String>('name').value, 'edited');

      form.reset();
      await tester.pumpAndSettle();

      final field =
          tester.widget<TextField>(find.byKey(const ValueKey('name')));
      expect(field.controller!.text, 'initial');
      expect(form.control<String>('name').dirty, false);
    });

    testWidgets('clear() empties the TextField', (tester) async {
      final form = FormGroup({
        'name': FormControl<String>('initial'),
      });

      await tester.pumpWidget(_harness(form));
      form.clear();
      await tester.pumpAndSettle();

      final field =
          tester.widget<TextField>(find.byKey(const ValueKey('name')));
      expect(field.controller!.text, '');
      expect(form.control<String>('name').value, isNull);
    });

    testWidgets('patchValue updates the TextField without marking dirty',
        (tester) async {
      final form = FormGroup({
        'name': FormControl<String>(null),
      });

      await tester.pumpWidget(_harness(form));
      form.patchValue({'name': 'from-server'});
      await tester.pumpAndSettle();

      final field =
          tester.widget<TextField>(find.byKey(const ValueKey('name')));
      expect(field.controller!.text, 'from-server');
      expect(form.control<String>('name').dirty, false);
      expect(form.isDirty, false);
    });

    testWidgets('marks the control as touched on focus blur',
        (tester) async {
      final form = FormGroup({
        'name': FormControl<String>(null),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => Column(
                children: [
                  EzyFormControl<String>(
                    formControlName: 'name',
                    builder: (context, control, controller, focusNode) =>
                        TextField(
                      key: const ValueKey('name'),
                      controller: controller,
                      focusNode: focusNode,
                    ),
                  ),
                  const TextField(key: ValueKey('other')),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('name')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('other')));
      await tester.pumpAndSettle();

      expect(form.control<String>('name').isTouched, true);
    });

    testWidgets('rebuilds when the bound control notifies (errorText)',
        (tester) async {
      final form = FormGroup({
        'name': FormControl<String>(null, validators: [requiredValidator]),
      });

      await tester.pumpWidget(_harness(form));

      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('name')))
            .decoration!
            .errorText,
        isNull,
      );

      form.validate();
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('name')))
            .decoration!
            .errorText,
        'required',
      );
    });

    testWidgets('uses an externally-supplied controller and focus node',
        (tester) async {
      final externalController = TextEditingController();
      final externalFocus = FocusNode();
      addTearDown(externalController.dispose);
      addTearDown(externalFocus.dispose);

      final form = FormGroup({
        'name': FormControl<String>('initial'),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => EzyFormControl<String>(
                formControlName: 'name',
                controller: externalController,
                focusNode: externalFocus,
                builder: (context, control, controller, focusNode) =>
                    TextField(
                  key: const ValueKey('name'),
                  controller: controller,
                  focusNode: focusNode,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(externalController.text, 'initial');

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(() => externalController.text, returnsNormally);
    });
  });

  group('EzyFormControl typed text binding (parse/format)', () {
    testWidgets(
        'typing into an int field writes parsed values to the FormControl',
        (tester) async {
      final form = FormGroup({
        'age': FormControl<int>(null),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => EzyFormControl<int>(
                formControlName: 'age',
                parse: int.tryParse,
                format: (value) => value?.toString() ?? '',
                builder: (context, control, controller, focusNode) =>
                    TextField(
                  key: const ValueKey('age'),
                  controller: controller,
                  focusNode: focusNode,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byKey(const ValueKey('age')), '42');
      await tester.pumpAndSettle();

      expect(form.control<int>('age').value, 42);
      expect(form.control<int>('age').dirty, true);
    });

    testWidgets(
        'unparseable text writes null but keeps raw text in the field',
        (tester) async {
      final form = FormGroup({
        'age': FormControl<int>(null),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => EzyFormControl<int>(
                formControlName: 'age',
                parse: int.tryParse,
                format: (value) => value?.toString() ?? '',
                builder: (context, control, controller, focusNode) =>
                    TextField(
                  key: const ValueKey('age'),
                  controller: controller,
                  focusNode: focusNode,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byKey(const ValueKey('age')), 'abc');
      await tester.pumpAndSettle();

      expect(form.control<int>('age').value, isNull);
      final field =
          tester.widget<TextField>(find.byKey(const ValueKey('age')));
      expect(field.controller!.text, 'abc');
    });

    testWidgets('external patchValue formats the value into the field',
        (tester) async {
      final form = FormGroup({
        'age': FormControl<int>(null),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => EzyFormControl<int>(
                formControlName: 'age',
                parse: int.tryParse,
                format: (value) => value?.toString() ?? '',
                builder: (context, control, controller, focusNode) =>
                    TextField(
                  key: const ValueKey('age'),
                  controller: controller,
                  focusNode: focusNode,
                ),
              ),
            ),
          ),
        ),
      );

      form.patchValue({'age': 99});
      await tester.pumpAndSettle();

      final field =
          tester.widget<TextField>(find.byKey(const ValueKey('age')));
      expect(field.controller!.text, '99');
      expect(form.control<int>('age').dirty, false);
    });

    testWidgets('double field with custom format string', (tester) async {
      final form = FormGroup({
        'price': FormControl<double>(3.14159),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => EzyFormControl<double>(
                formControlName: 'price',
                parse: double.tryParse,
                format: (value) => value?.toStringAsFixed(2) ?? '',
                builder: (context, control, controller, focusNode) =>
                    TextField(
                  key: const ValueKey('price'),
                  controller: controller,
                  focusNode: focusNode,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final field =
          tester.widget<TextField>(find.byKey(const ValueKey('price')));
      expect(field.controller!.text, '3.14');
    });

    testWidgets('reset() restores the initial typed value through format',
        (tester) async {
      final form = FormGroup({
        'age': FormControl<int>(25),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => EzyFormControl<int>(
                formControlName: 'age',
                parse: int.tryParse,
                format: (value) => value?.toString() ?? '',
                builder: (context, control, controller, focusNode) =>
                    TextField(
                  key: const ValueKey('age'),
                  controller: controller,
                  focusNode: focusNode,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byKey(const ValueKey('age')), '99');
      await tester.pumpAndSettle();
      expect(form.control<int>('age').value, 99);

      form.reset();
      await tester.pumpAndSettle();

      final field =
          tester.widget<TextField>(find.byKey(const ValueKey('age')));
      expect(field.controller!.text, '25');
      expect(form.control<int>('age').value, 25);
    });
  });

  group('EzyFormControl non-text (no sync)', () {
    testWidgets('bool control works with onChanged pattern', (tester) async {
      final form = FormGroup({
        'agreed': FormControl<bool>(false),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EzyFormWidget(
              formGroup: form,
              builder: (context, _) => EzyFormControl<bool>(
                formControlName: 'agreed',
                builder: (context, control, _, __) => Checkbox(
                  key: const ValueKey('agreed'),
                  value: control.value ?? false,
                  onChanged: (v) => control.setValue(v),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('agreed')));
      await tester.pumpAndSettle();

      expect(form.control<bool>('agreed').value, true);
    });
  });
}
