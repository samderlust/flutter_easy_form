import 'dart:convert';

import 'package:ezy_form/ezy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toJson / fromJson', () {
    FormGroup buildForm() => FormGroup({
          'name': FormControl<String>('Sam'),
          'birthDate': FormControl<DateTime>(
            DateTime(1990, 1, 15),
            toJson: (v) => v?.toIso8601String(),
            fromJson: (v) => v != null ? DateTime.tryParse(v) : null,
          ),
          'score': FormControl<double>(9.5),
          'profile': FormGroup({
            'createdAt': FormControl<DateTime>(
              DateTime(2024, 6, 1),
              toJson: (v) => v?.toIso8601String(),
              fromJson: (v) => v != null ? DateTime.tryParse(v) : null,
            ),
          }),
          'timestamps': FormArrayControl<DateTime>(
            [
              FormControl<DateTime>(DateTime(2025, 1, 1)),
              FormControl<DateTime>(DateTime(2025, 6, 1)),
            ],
            toJson: (v) => v?.toIso8601String(),
            fromJson: (v) => v != null ? DateTime.tryParse(v) : null,
          ),
        });

    test('toJsonMap converts non-primitive types via toJson callbacks', () {
      final f = buildForm();
      final json = f.toJsonMap();

      expect(json['name'], 'Sam');
      expect(json['score'], 9.5);
      expect(json['birthDate'], '1990-01-15T00:00:00.000');
      expect(json['profile']['createdAt'], '2024-06-01T00:00:00.000');
      expect(json['timestamps'], [
        '2025-01-01T00:00:00.000',
        '2025-06-01T00:00:00.000',
      ]);
    });

    test('toJsonMap result survives jsonEncode', () {
      final f = buildForm();
      final jsonStr = jsonEncode(f.toJsonMap());
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded['name'], 'Sam');
      expect(decoded['birthDate'], '1990-01-15T00:00:00.000');
      expect(decoded['score'], 9.5);
    });

    test('toJsonMap falls back to raw value when toJson is null', () {
      final f = FormGroup({
        'age': FormControl<int>(25),
        'active': FormControl<bool>(true),
      });

      final json = f.toJsonMap();
      expect(json['age'], 25);
      expect(json['active'], true);
      expect(jsonEncode(json), '{"age":25,"active":true}');
    });

    test('patchValue uses fromJson to parse incoming JSON values', () {
      final f = buildForm();

      f.patchValue({
        'name': 'Alex',
        'birthDate': '2000-03-20T00:00:00.000',
        'profile': {'createdAt': '2025-01-01T00:00:00.000'},
      });

      expect(f.control<String>('name').value, 'Alex');
      expect(
        f.control<DateTime>('birthDate').value,
        DateTime(2000, 3, 20),
      );
      expect(
        f.control<DateTime>('profile.createdAt').value,
        DateTime(2025, 1, 1),
      );
      expect(f.isDirty, false);
    });

    test('setValue uses fromJson to parse incoming JSON values', () {
      final f = buildForm();

      f.setValue({
        'name': 'Alex',
        'birthDate': '2000-03-20T00:00:00.000',
        'score': 8.0,
        'profile': {'createdAt': '2025-01-01T00:00:00.000'},
        'timestamps': ['2026-01-01T00:00:00.000'],
      });

      expect(f.control<DateTime>('birthDate').value, DateTime(2000, 3, 20));
      expect(f.isDirty, true);
    });

    test('fromJson works on FormArrayControl via patchValue', () {
      final f = buildForm();

      f.patchValue({
        'timestamps': [
          '2026-06-01T00:00:00.000',
          '2026-12-25T00:00:00.000',
          '2027-01-01T00:00:00.000',
        ],
      });

      final values = f.arrayControl<DateTime>('timestamps').values;
      expect(values, [
        DateTime(2026, 6, 1),
        DateTime(2026, 12, 25),
        DateTime(2027, 1, 1),
      ]);
    });

    test('controls without fromJson pass values through as-is', () {
      final f = FormGroup({
        'name': FormControl<String>(null),
        'count': FormControl<int>(null),
      });

      f.patchValue({'name': 'Sam', 'count': 42});

      expect(f.control<String>('name').value, 'Sam');
      expect(f.control<int>('count').value, 42);
    });

    test('round-trip: toJsonMap → jsonEncode → jsonDecode → patchValue', () {
      final f = buildForm();

      // Serialize
      final jsonStr = jsonEncode(f.toJsonMap());

      // Create a fresh form and deserialize
      final f2 = buildForm();
      f2.patchValue(jsonDecode(jsonStr) as Map<String, dynamic>);

      expect(f2.control<String>('name').value, 'Sam');
      expect(f2.control<DateTime>('birthDate').value, DateTime(1990, 1, 15));
      expect(f2.control<double>('score').value, 9.5);
      expect(
        f2.control<DateTime>('profile.createdAt').value,
        DateTime(2024, 6, 1),
      );
      expect(f2.arrayControl<DateTime>('timestamps').values, [
        DateTime(2025, 1, 1),
        DateTime(2025, 6, 1),
      ]);
    });

    test('toJsonMap handles null values and null arrays', () {
      final f = FormGroup({
        'date': FormControl<DateTime>(
          null,
          toJson: (v) => v?.toIso8601String(),
          fromJson: (v) => v != null ? DateTime.tryParse(v) : null,
        ),
        'items': FormArrayControl<DateTime>(
          null,
          toJson: (v) => v?.toIso8601String(),
          fromJson: (v) => v != null ? DateTime.tryParse(v) : null,
        ),
      });

      final json = f.toJsonMap();
      expect(json['date'], isNull);
      expect(json['items'], isNull);
      expect(jsonEncode(json), '{"date":null,"items":null}');
    });

    test('add() on array propagates fromJson/toJson to new children', () {
      final f = FormGroup({
        'dates': FormArrayControl<DateTime>(
          null,
          toJson: (v) => v?.toIso8601String(),
          fromJson: (v) => v != null ? DateTime.tryParse(v) : null,
        ),
      });

      f.arrayControl<DateTime>('dates').add(DateTime(2025, 3, 15));
      final json = f.toJsonMap();
      expect(json['dates'], ['2025-03-15T00:00:00.000']);
    });
  });
}
