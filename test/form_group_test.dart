import 'package:ezy_form/ezy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final form = FormGroup({
    'email': FormControl<String>(null, validators: [requiredValidator]),
    'password': FormControl<String>(null, validators: [requiredValidator]),
    'agreed': FormControl<bool>(false, validators: [requiredTrueValidator]),
    'tags': FormArrayControl<String>(null, validators: [requiredValidator]),
    'profile': FormGroup({
      'firstName': FormControl<String>(null, validators: [requiredValidator]),
      'lastName': FormControl<String>(null, validators: [requiredValidator]),
      'address': FormControl<String>(null, validators: [requiredValidator]),
      'birthDate': FormControl<DateTime>(null, validators: [requiredValidator]),
      'gender': FormControl<String>(null, validators: [requiredValidator]),
      'hobbies':
          FormArrayControl<String>(null, validators: [requiredValidator]),
    }),
    // "1": {
    //   "a": FormControl<String>(null, validators: [requiredValidator]),
    // }
  });

  group("functional", () {
    test('flatControls should return all nested controls', () {
      final flatControls = form.flatControls;
      expect(flatControls.length, 10);
    });

    test('flatGroups should return all nested groups', () {
      final flatGroups = form.flatGroups;
      expect(flatGroups.length, 1);
    });

    test('get control should return control', () {
      final ctrl = form.control('email');
      expect(ctrl, isNotNull);
      expect(ctrl.value, isNull);
    });

    test('get nested control should return', () {
      final ctrl = form.control('profile.firstName');
      expect(ctrl, isNotNull);
      expect(ctrl.value, isNull);
    });

    test('get array control should return', () {
      final ctrl = form.arrayControl('tags');
      expect(ctrl, isNotNull);
      expect(ctrl.values, isNull);
    });

    test('get nested array control should return', () {
      final ctrl = form.arrayControl('profile.hobbies');
      expect(ctrl, isNotNull);
      expect(ctrl.values, isNull);
    });

    test('invalid control name should failed', () {
      expect(() => form.control('invalid'), throwsArgumentError);
      expect(() => form.control('tags'), throwsArgumentError);
      expect(() => form.arrayControl('profile'), throwsArgumentError);
    });

    test('values should return same structure', () {
      final values = form.values;

      final struct = <String, dynamic>{
        'email': null,
        'password': null,
        'agreed': false,
        'tags': null,
        'profile': {
          'firstName': null,
          'lastName': null,
          'address': null,
          'birthDate': null,
          'gender': null,
          'hobbies': null,
        }
      };

      expect(struct.keys.toSet(), values.keys.toSet());
      expect(struct, values);
    });

    test('groupControl should return group', () {
      final groupCtrl = form.groupControl('profile');
      expect(groupCtrl, isNotNull);
      expect(groupCtrl, isA<FormGroup>());
      expect(groupCtrl.values.keys, contains(anyOf('firstName', 'lastName')));
    });

    // The old "invalid type" tests (passing raw Map literals into FormGroup)
    // are no longer needed — FormNode typing now catches those at compile
    // time, which is the whole point of #20.
  });

  group("nested validate", () {
    test("nested group should be in FormGroup", () {});
  });

  group('patchValue / setValue', () {
    FormGroup buildForm() => FormGroup({
          'name': FormControl<String>(null),
          'tags': FormArrayControl<String>(null),
          'profile': FormGroup({
            'first': FormControl<String>(null),
            'last': FormControl<String>(null),
          }),
        });

    test('patchValue applies leaves recursively without marking dirty', () {
      final f = buildForm();

      f.patchValue({
        'name': 'Sam',
        'tags': ['flutter', 'dart'],
        'profile': {'first': 'S', 'last': 'D'},
      });

      expect(f.control<String>('name').value, 'Sam');
      expect(f.arrayControl<String>('tags').values, ['flutter', 'dart']);
      expect(f.control<String>('profile.first').value, 'S');
      expect(f.control<String>('profile.last').value, 'D');
      expect(f.isDirty, false);
    });

    test('patchValue tolerates partial maps and unknown keys', () {
      final f = buildForm();

      f.patchValue({
        'name': 'Sam',
        'unknown': 'ignored',
        'profile': {'first': 'S'}, // missing `last`
      });

      expect(f.control<String>('name').value, 'Sam');
      expect(f.control<String>('profile.first').value, 'S');
      expect(f.control<String>('profile.last').value, isNull);
    });

    test('setValue marks affected controls as dirty', () {
      final f = buildForm();

      f.setValue({
        'name': 'Sam',
        'tags': ['a'],
        'profile': {'first': 'S', 'last': 'D'},
      });

      expect(f.isDirty, true);
      expect(f.control<String>('name').dirty, true);
    });

    test('setValue throws on a missing key', () {
      final f = buildForm();
      expect(
        () => f.setValue({'name': 'Sam'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('setValue throws on an unknown key', () {
      final f = buildForm();
      expect(
        () => f.setValue({
          'name': 'Sam',
          'tags': <String>[],
          'profile': {'first': 'a', 'last': 'b'},
          'extra': 'nope',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('setValue throws when a nested group slot is not a Map', () {
      final f = buildForm();
      expect(
        () => f.setValue({
          'name': 'Sam',
          'tags': <String>[],
          'profile': 'not-a-map',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('reset vs clear semantics', () {
    test('reset restores initial values across nested groups and arrays', () {
      final f = FormGroup({
        'name': FormControl<String>('initial-name'),
        'tags': FormArrayControl<String>([
          FormControl<String>('tag-a'),
          FormControl<String>('tag-b'),
        ]),
        'profile': FormGroup({
          'age': FormControl<int>(30),
        }),
      });

      f.control<String>('name').setValue('edited');
      f.arrayControl<String>('tags').add('tag-c');
      f.control<int>('profile.age').setValue(99);

      f.reset();

      expect(f.control<String>('name').value, 'initial-name');
      expect(f.arrayControl<String>('tags').controls!.length, 2);
      expect(f.arrayControl<String>('tags').values, ['tag-a', 'tag-b']);
      expect(f.control<int>('profile.age').value, 30);
      expect(f.isDirty, false);
    });

    test('clear nulls every leaf but keeps the structure', () {
      final f = FormGroup({
        'name': FormControl<String>('initial-name'),
        'tags': FormArrayControl<String>([
          FormControl<String>('tag-a'),
          FormControl<String>('tag-b'),
        ]),
        'profile': FormGroup({
          'age': FormControl<int>(30),
        }),
      });

      f.clear();

      expect(f.control<String>('name').value, isNull);
      expect(f.arrayControl<String>('tags').controls!.length, 2);
      expect(f.arrayControl<String>('tags').values, [null, null]);
      expect(f.control<int>('profile.age').value, isNull);
      expect(f.isDirty, false);
      expect(f.isTouched, false);
    });
  });
}
