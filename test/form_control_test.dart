import 'package:ezy_form/ezy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('form control', () {
    test('value should be null', () {
      final ctrl = FormControl<String>(null);
      expect(ctrl.value, null);
    });

    test('value should be set', () {
      final ctrl = FormControl<String>('value');
      expect(ctrl.value, 'value');
    });

    test('reset restores the constructor-time initial value', () {
      final ctrl = FormControl<String>('value');
      ctrl.setValue('edited');
      ctrl.reset();
      expect(ctrl.value, 'value');
      expect(ctrl.dirty, false);
      expect(ctrl.touched, false);
      expect(ctrl.error, isNull);
    });

    test('reset on a control built from null restores null', () {
      final ctrl = FormControl<String>(null);
      ctrl.setValue('edited');
      ctrl.reset();
      expect(ctrl.value, isNull);
    });

    test('setValue should set value', () {
      final ctrl = FormControl<String>('value');
      ctrl.setValue('newValue');
      expect(ctrl.value, 'newValue');
    });

    test('clear wipes the value to null regardless of initial value', () {
      final ctrl = FormControl<String>('value');
      ctrl.setValue('edited');
      ctrl.clear();
      expect(ctrl.value, isNull);
      expect(ctrl.dirty, false);
      expect(ctrl.touched, false);
      expect(ctrl.error, isNull);
    });

    test('clear notifies listeners', () {
      final ctrl = FormControl<String>('value');
      var notified = 0;
      ctrl.addListener(() => notified++);
      ctrl.clear();
      expect(notified, 1);
    });

    test('setValue should be dirty', () {
      final ctrl = FormControl<String>('value');
      ctrl.setValue('newValue');
      expect(ctrl.dirty, true);
    });

    test('setValue should be touched', () {
      final ctrl = FormControl<String>('value');
      ctrl.setValue('newValue');
      expect(ctrl.touched, true);
    });

    test('setValue should be valid', () {
      final ctrl =
          FormControl<String>('value', validators: [requiredValidator]);
      ctrl.setValue('newValue');
      expect(ctrl.valid, true);
    });

    test('setValue should be invalid', () {
      final ctrl =
          FormControl<String>('value', validators: [requiredValidator]);
      ctrl.setValue(null);
      ctrl.validate();
      expect(ctrl.valid, false);
    });

    test('markAsDirty should be dirty and touched', () {
      final ctrl = FormControl<String>('value');
      ctrl.markAsDirty();
      expect(ctrl.touched, true);
      expect(ctrl.dirty, true);
    });

    test('markAsTouched should be touched and not dirty', () {
      final ctrl = FormControl<String>('value');
      ctrl.markAsTouched();
      expect(ctrl.touched, true);
      expect(ctrl.dirty, false);
    });

    test('equality is identity-based', () {
      final a = FormControl<String>('same');
      final b = FormControl<String>('same');

      // Distinct instances with equal state should NOT compare equal —
      // otherwise putting two controls in a Set would collapse them.
      expect(a == b, false);
      expect(identical(a, a), true);
      expect(a == a, true);

      final set = <FormControl<String>>{a, b};
      expect(set.length, 2);
    });
  });
}
