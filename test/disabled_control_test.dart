import 'package:ezy_form/ezy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormControl disabled/enabled', () {
    test('defaults to enabled', () {
      final control = FormControl<String>('hello');
      expect(control.enabled, true);
      expect(control.disabled, false);
    });

    test('can be constructed as disabled', () {
      final control = FormControl<String>('hello', enabled: false);
      expect(control.enabled, false);
      expect(control.disabled, true);
    });

    test('markAsDisabled disables and clears error', () {
      final control = FormControl<String>(
        null,
        validators: [requiredValidator],
      );
      control.validate();
      expect(control.error, isNotNull);

      control.markAsDisabled();
      expect(control.disabled, true);
      expect(control.error, isNull);
    });

    test('markAsEnabled re-enables', () {
      final control = FormControl<String>('hello');
      control.markAsDisabled();
      expect(control.disabled, true);

      control.markAsEnabled();
      expect(control.enabled, true);
    });

    test('disabled control is always valid', () {
      final control = FormControl<String>(
        null,
        validators: [requiredValidator],
      );
      control.validate();
      expect(control.valid, false);

      control.markAsDisabled();
      expect(control.valid, true);
    });

    test('validate() is a no-op when disabled', () {
      final control = FormControl<String>(
        null,
        validators: [requiredValidator],
        enabled: false,
      );
      control.validate();
      expect(control.error, isNull);
      expect(control.valid, true);
    });

    test('validateAsync() is a no-op when disabled', () async {
      var called = false;
      final control = FormControl<String>(
        null,
        validators: [requiredValidator],
        asyncValidators: [
          (value) async {
            called = true;
            return 'error';
          },
        ],
        enabled: false,
      );
      await control.validateAsync();
      expect(called, false);
      expect(control.error, isNull);
    });

    test('notifies listeners on disable/enable', () {
      final control = FormControl<String>('hello');
      var count = 0;
      control.addListener(() => count++);

      control.markAsDisabled();
      expect(count, 1);

      control.markAsEnabled();
      expect(count, 2);
    });
  });

  group('FormArrayControl disabled/enabled', () {
    test('defaults to enabled', () {
      final array = FormArrayControl<String>(null);
      expect(array.enabled, true);
      expect(array.disabled, false);
    });

    test('can be constructed as disabled', () {
      final array = FormArrayControl<String>(null, enabled: false);
      expect(array.disabled, true);
    });

    test('disabled array is always valid', () {
      final array = FormArrayControl<String>(
        null,
        validators: [requiredValidator],
      );
      array.validate();
      expect(array.valid, false);

      array.markAsDisabled();
      expect(array.valid, true);
    });

    test('validate() is a no-op when disabled', () {
      final array = FormArrayControl<String>(
        null,
        validators: [requiredValidator],
        enabled: false,
      );
      array.validate();
      expect(array.error, isNull);
    });
  });

  group('FormGroupArray disabled/enabled', () {
    test('defaults to enabled', () {
      final ga = FormGroupArray([]);
      expect(ga.enabled, true);
      expect(ga.disabled, false);
    });

    test('can be constructed as disabled', () {
      final ga = FormGroupArray([], enabled: false);
      expect(ga.disabled, true);
    });

    test('disabled array is always valid', () {
      final ga = FormGroupArray(
        [],
        arrayValidators: [
          (groups) => (groups == null || groups.isEmpty)
              ? 'need at least one'
              : null,
        ],
      );
      ga.validate();
      expect(ga.valid, false);

      ga.markAsDisabled();
      expect(ga.valid, true);
    });

    test('validate() is a no-op when disabled', () {
      final ga = FormGroupArray(
        [],
        arrayValidators: [
          (groups) => (groups == null || groups.isEmpty)
              ? 'need at least one'
              : null,
        ],
        enabled: false,
      );
      ga.validate();
      expect(ga.error, isNull);
    });
  });

  group('FormGroup integration with disabled controls', () {
    test('disabled control excluded from values', () {
      final form = FormGroup({
        'name': FormControl<String>('Sam'),
        'email': FormControl<String>('sam@test.com'),
      });
      form.control<String>('email').markAsDisabled();
      expect(form.values, {'name': 'Sam'});
    });

    test('disabled FormArrayControl excluded from values', () {
      final form = FormGroup({
        'name': FormControl<String>('Sam'),
        'tags': FormArrayControl<String>([
          FormControl<String>('a'),
        ]),
      });
      form.arrayControl<String>('tags').markAsDisabled();
      expect(form.values, {'name': 'Sam'});
    });

    test('disabled FormGroupArray excluded from values', () {
      final form = FormGroup({
        'name': FormControl<String>('Sam'),
        'addresses': FormGroupArray([
          FormGroup({
            'street': FormControl<String>('123 Main'),
          }),
        ]),
      });
      form.groupArrayControl('addresses').markAsDisabled();
      expect(form.values, {'name': 'Sam'});
    });

    test('isValid ignores disabled controls', () {
      final form = FormGroup({
        'name': FormControl<String>('Sam', validators: [requiredValidator]),
        'email': FormControl<String>(null, validators: [requiredValidator]),
      });
      form.validate();
      expect(form.isValid, false);

      form.control<String>('email').markAsDisabled();
      form.validate();
      expect(form.isValid, true);
    });

    test('validate() skips disabled controls', () {
      final form = FormGroup({
        'name': FormControl<String>('Sam'),
        'email': FormControl<String>(null, validators: [requiredValidator]),
      });
      form.control<String>('email').markAsDisabled();
      form.validate();
      expect(form.isValid, true);
      expect(form.control<String>('email').error, isNull);
    });

    test('re-enabling includes control in values and validation again', () {
      final form = FormGroup({
        'name': FormControl<String>('Sam'),
        'email': FormControl<String>(null, validators: [requiredValidator]),
      });
      form.control<String>('email').markAsDisabled();
      expect(form.values.containsKey('email'), false);

      form.control<String>('email').markAsEnabled();
      expect(form.values.containsKey('email'), true);

      form.validate();
      expect(form.isValid, false);
    });

    test('nested group values still exclude disabled controls', () {
      final form = FormGroup({
        'info': FormGroup({
          'first': FormControl<String>('Sam'),
          'last': FormControl<String>('D'),
        }),
      });
      form.control<String>('info.first').markAsDisabled();
      expect(form.values, {
        'info': {'last': 'D'},
      });
    });
  });
}
