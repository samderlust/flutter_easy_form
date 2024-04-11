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

    test('Invalid type should throw', () {
      final f = FormGroup(
        {
          "a": {
            "b": FormControl<String>(null, validators: [requiredValidator]),
            "c": {
              "d": FormControl<String>(null, validators: [requiredValidator]),
            }
          }
        },
      );

      expect(() => f.groupControl('a'), throwsArgumentError);
      expect(() => f.groupControl('a.c'), throwsArgumentError);
      expect(() => f.control('a.b'), throwsArgumentError);
      expect(() => f.control('a'), throwsArgumentError);
    });
  });

  group("nested validate", () {
    test("nested group should be in FormGroup", () {});
  });
}
