import 'package:ezy_form/easy_form.dart';
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

    test('value should be reset', () {
      final ctrl = FormControl<String>('value');
      ctrl.reset();
      expect(ctrl.value, null);
    });

    test('setValue should set value', () {
      final ctrl = FormControl<String>('value');
      ctrl.setValue('newValue');
      expect(ctrl.value, 'newValue');
    });

    test('setValue should be reset', () {
      final ctrl = FormControl<String>('value');
      ctrl.setValue('newValue');
      ctrl.reset();
      expect(ctrl.value, null);
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
  });
}
