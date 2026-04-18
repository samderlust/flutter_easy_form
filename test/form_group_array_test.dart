import 'package:ezy_form/ezy_form.dart';
import 'package:flutter_test/flutter_test.dart';

FormGroup _addressGroup({String street = '', String city = ''}) {
  return FormGroup({
    'street': FormControl<String>(street, validators: [requiredValidator]),
    'city': FormControl<String>(city),
  });
}

FormGroup Function() _addressFactory = () => _addressGroup();

void main() {
  group('FormGroupArray', () {
    test('constructs with initial groups', () {
      final array = FormGroupArray([
        _addressGroup(street: '123 Main'),
        _addressGroup(street: '456 Oak'),
      ]);

      expect(array.length, 2);
      expect(array.values, [
        {'street': '123 Main', 'city': ''},
        {'street': '456 Oak', 'city': ''},
      ]);
    });

    test('constructs with null as empty list', () {
      final array = FormGroupArray(null);
      expect(array.length, 0);
      expect(array.values, []);
    });

    test('addGroup with explicit group', () {
      final array = FormGroupArray([]);
      array.addGroup(_addressGroup(street: 'New St'));

      expect(array.length, 1);
      expect(array.values[0]['street'], 'New St');
    });

    test('addGroup with templateFactory', () {
      final array = FormGroupArray([], templateFactory: _addressFactory);
      array.addGroup();

      expect(array.length, 1);
      expect(array.values[0], {'street': '', 'city': ''});
    });

    test('addGroup throws without argument or factory', () {
      final array = FormGroupArray([]);
      expect(() => array.addGroup(), throwsStateError);
    });

    test('removeGroup removes at index', () {
      final array = FormGroupArray([
        _addressGroup(street: 'A'),
        _addressGroup(street: 'B'),
        _addressGroup(street: 'C'),
      ]);

      array.removeGroup(1);

      expect(array.length, 2);
      expect(array.values[0]['street'], 'A');
      expect(array.values[1]['street'], 'C');
    });

    test('removeGroup no-op for out of range', () {
      final array = FormGroupArray([_addressGroup()]);
      array.removeGroup(5);
      array.removeGroup(-1);
      expect(array.length, 1);
    });

    test('removeAll clears everything', () {
      final array = FormGroupArray([
        _addressGroup(),
        _addressGroup(),
      ]);

      array.removeAll();

      expect(array.length, 0);
      expect(array.dirty, false);
      expect(array.touched, false);
    });

    test('validate runs array validators', () {
      String? minTwo(List<FormGroup>? groups) {
        if (groups == null || groups.length < 2) return 'Need at least 2';
        return null;
      }

      final array = FormGroupArray(
        [_addressGroup()],
        arrayValidators: [minTwo],
      );

      array.validate();

      expect(array.error, 'Need at least 2');
      expect(array.valid, false);
    });

    test('validate runs child group validators', () {
      final array = FormGroupArray([
        _addressGroup(street: ''), // street is required
      ]);

      array.validate();

      // Array-level error is null, but valid is false because child is invalid.
      expect(array.error, null);
      expect(array.valid, false);
    });

    test('validate passes when all valid', () {
      final array = FormGroupArray([
        _addressGroup(street: 'Main St'),
      ]);

      array.validate();

      expect(array.valid, true);
    });

    test('isDirty reflects child state', () {
      final array = FormGroupArray([_addressGroup()]);
      expect(array.isDirty, false);

      array.controls[0].control<String>('street').setValue('changed');
      expect(array.isDirty, true);
    });

    test('isTouched reflects child state', () {
      final array = FormGroupArray([_addressGroup()]);
      expect(array.isTouched, false);

      array.controls[0].control<String>('street').markAsTouched();
      expect(array.isTouched, true);
    });

    test('reset restores initial state with factory', () {
      final array = FormGroupArray(
        [_addressGroup(street: 'Initial')],
        templateFactory: _addressFactory,
      );

      array.addGroup(_addressGroup(street: 'Added'));
      expect(array.length, 2);

      array.reset();

      expect(array.length, 1);
      expect(array.values[0]['street'], 'Initial');
    });

    test('reset restores initial state without factory', () {
      final g = _addressGroup(street: 'Start');
      final array = FormGroupArray([g]);

      g.control<String>('street').setValue('Modified');
      array.addGroup(_addressGroup(street: 'Extra'));
      expect(array.length, 2);

      array.reset();

      expect(array.length, 1);
      // Without factory, it resets existing groups in place.
      expect(array.values[0]['street'], 'Start');
    });

    test('clear nulls all child values but keeps structure', () {
      final array = FormGroupArray([
        _addressGroup(street: 'A', city: 'B'),
        _addressGroup(street: 'C', city: 'D'),
      ]);

      array.clear();

      expect(array.length, 2);
      expect(array.values[0], {'street': null, 'city': null});
      expect(array.values[1], {'street': null, 'city': null});
    });

    test('setValue replaces content and marks dirty', () {
      final array = FormGroupArray(
        [_addressGroup()],
        templateFactory: _addressFactory,
      );

      array.setValue([
        {'street': 'X', 'city': 'Y'},
        {'street': 'A', 'city': 'B'},
      ]);

      expect(array.length, 2);
      expect(array.dirty, true);
      expect(array.values[0], {'street': 'X', 'city': 'Y'});
      expect(array.values[1], {'street': 'A', 'city': 'B'});
    });

    test('patchValue replaces content without marking dirty', () {
      final array = FormGroupArray(
        [_addressGroup()],
        templateFactory: _addressFactory,
      );

      array.patchValue([
        {'street': 'Patched', 'city': 'Town'},
      ]);

      expect(array.length, 1);
      expect(array.dirty, false);
      expect(array.values[0], {'street': 'Patched', 'city': 'Town'});
    });

    test('setValue throws when resizing without factory', () {
      final array = FormGroupArray([_addressGroup()]);

      expect(
        () => array.setValue([
          {'street': 'A', 'city': 'B'},
          {'street': 'C', 'city': 'D'},
        ]),
        throwsStateError,
      );
    });

    test('notifies listeners on mutations', () {
      final array = FormGroupArray([], templateFactory: _addressFactory);
      var count = 0;
      array.addListener(() => count++);

      array.addGroup();
      expect(count, 1);

      array.removeGroup(0);
      expect(count, 2);

      array.addGroup();
      array.validate();
      expect(count, 4);
    });

    test('markAsDirty and markAsTouched', () {
      final array = FormGroupArray([]);

      array.markAsDirty();
      expect(array.dirty, true);
      expect(array.touched, true);

      final array2 = FormGroupArray([]);
      array2.markAsTouched();
      expect(array2.touched, true);
      expect(array2.dirty, false);
    });
  });

  group('FormGroup integration with FormGroupArray', () {
    test('FormGroup.values includes FormGroupArray', () {
      final form = FormGroup({
        'name': FormControl<String>('Sam'),
        'addresses': FormGroupArray([
          _addressGroup(street: '123 Main', city: 'NYC'),
        ]),
      });

      expect(form.values, {
        'name': 'Sam',
        'addresses': [
          {'street': '123 Main', 'city': 'NYC'},
        ],
      });
    });

    test('FormGroup.groupArrayControl lookup', () {
      final form = FormGroup({
        'addresses': FormGroupArray([_addressGroup()]),
      });

      final array = form.groupArrayControl('addresses');
      expect(array, isA<FormGroupArray>());
      expect(array.length, 1);
    });

    test('FormGroup.validate walks into FormGroupArray children', () {
      final form = FormGroup({
        'addresses': FormGroupArray([
          _addressGroup(street: ''), // required street is empty
        ]),
      });

      final valid = form.validate();
      expect(valid, false);
    });

    test('FormGroup.isValid reflects FormGroupArray child validity', () {
      final form = FormGroup({
        'addresses': FormGroupArray([
          _addressGroup(street: 'Valid'),
        ]),
      });

      form.validate();
      expect(form.isValid, true);
    });

    test('FormGroup.isDirty reflects FormGroupArray child changes', () {
      final form = FormGroup({
        'addresses': FormGroupArray([_addressGroup(street: 'A')]),
      });

      expect(form.isDirty, false);

      form.groupArrayControl('addresses').controls[0]
          .control<String>('street')
          .setValue('B');

      expect(form.isDirty, true);
    });

    test('FormGroup.patchValue patches into FormGroupArray', () {
      final form = FormGroup({
        'name': FormControl<String>(''),
        'addresses': FormGroupArray(
          [_addressGroup()],
          templateFactory: _addressFactory,
        ),
      });

      form.patchValue({
        'name': 'Sam',
        'addresses': [
          {'street': 'Patched St', 'city': 'Town'},
        ],
      });

      expect(form.values, {
        'name': 'Sam',
        'addresses': [
          {'street': 'Patched St', 'city': 'Town'},
        ],
      });
    });

    test('FormGroup.reset resets FormGroupArray children', () {
      final form = FormGroup({
        'addresses': FormGroupArray(
          [_addressGroup(street: 'Initial')],
          templateFactory: _addressFactory,
        ),
      });

      form.groupArrayControl('addresses').addGroup(
            _addressGroup(street: 'Added'),
          );
      expect(form.groupArrayControl('addresses').length, 2);

      form.reset();

      expect(form.groupArrayControl('addresses').length, 1);
      expect(form.values['addresses'], [
        {'street': 'Initial', 'city': ''},
      ]);
    });

    test('FormGroup.clear clears FormGroupArray children', () {
      final form = FormGroup({
        'addresses': FormGroupArray([
          _addressGroup(street: 'A', city: 'B'),
        ]),
      });

      form.clear();

      expect(form.values['addresses'], [
        {'street': null, 'city': null},
      ]);
    });
  });
}
