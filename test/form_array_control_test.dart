import 'package:ezy_form/ezy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormArrayControl.values', () {
    test('returns null when controls is null', () {
      expect(FormArrayControl<String>(null).values, isNull);
    });

    test('preserves null slots instead of filtering them out', () {
      final arr = FormArrayControl<String>(null)
        ..add('a')
        ..add(null)
        ..add('c');

      expect(arr.values, ['a', null, 'c']);
      expect(arr.values!.length, arr.controls!.length);
    });
  });

  group('FormArrayControl.arrayValidators', () {
    test('runs against the aggregated list', () {
      String? minTwo(List<String?>? v) =>
          (v == null || v.length < 2) ? 'need at least 2' : null;

      final arr = FormArrayControl<String>(
        null,
        arrayValidators: [minTwo],
      )..add('only');

      arr.validate();
      expect(arr.valid, false);
      expect(arr.error, 'need at least 2');

      arr.add('second');
      arr.validate();
      expect(arr.valid, true);
      expect(arr.error, isNull);
    });

    test('takes precedence over per-item fallback on empty arrays', () {
      String? mustHaveOne(List<String?>? v) =>
          (v == null || v.isEmpty) ? 'pick one' : null;

      final arr = FormArrayControl<String>(
        null,
        validators: [requiredValidator],
        arrayValidators: [mustHaveOne],
      );

      arr.validate();
      // arrayValidators report first, not the per-item fallback.
      expect(arr.error, 'pick one');
    });
  });

  group('FormArrayControl.clear', () {
    test('nulls every child value but keeps the structure', () {
      final arr = FormArrayControl<String>([
        FormControl<String>('a'),
        FormControl<String>('b'),
        FormControl<String>('c'),
      ]);

      arr.clear();

      expect(arr.controls!.length, 3);
      expect(arr.values, [null, null, null]);
      expect(arr.isDirty, false);
      expect(arr.isTouched, false);
      expect(arr.error, isNull);
    });

    test('is a no-op on a null controls list (still notifies)', () {
      final arr = FormArrayControl<String>(null);
      var notified = 0;
      arr.addListener(() => notified++);

      arr.clear();
      expect(arr.controls, isNull);
      expect(notified, 1);
    });
  });

  group('FormArrayControl.removeAll', () {
    test('drops every child', () {
      final arr = FormArrayControl<String>(null)
        ..add('a')
        ..add('b');

      arr.removeAll();

      expect(arr.controls, isEmpty);
      expect(arr.values, isEmpty);
    });

    test('clears state and notifies', () {
      final arr = FormArrayControl<String>([FormControl<String>('a')]);
      arr.controls![0].setValue('edited');
      var notified = 0;
      arr.addListener(() => notified++);

      arr.removeAll();

      expect(arr.controls, isEmpty);
      expect(arr.isDirty, false);
      expect(notified, 1);
    });

    test('add() works after removeAll()', () {
      final arr = FormArrayControl<String>(null)
        ..add('a')
        ..removeAll()
        ..add('fresh');

      expect(arr.values, ['fresh']);
    });
  });

  group('FormArrayControl.reset', () {
    test('drops items added after construction when built from null', () {
      final arr = FormArrayControl<String>(null)
        ..add('a')
        ..add('b');
      expect(arr.controls!.length, 2);

      arr.reset();

      expect(arr.controls, isNull);
    });

    test('restores initial controls with initial values', () {
      final arr = FormArrayControl<String>([
        FormControl<String>('one'),
        FormControl<String>('two'),
      ]);

      arr.controls![0].setValue('edited');
      arr.add('extra');
      expect(arr.controls!.length, 3);
      expect(arr.controls![0].value, 'edited');

      arr.reset();

      expect(arr.controls!.length, 2);
      expect(arr.controls!.map((c) => c.value).toList(), ['one', 'two']);
      expect(arr.isDirty, false);
      expect(arr.isTouched, false);
      expect(arr.error, isNull);
    });

    test('notifies listeners', () {
      final arr = FormArrayControl<String>(null)..add('a');
      var notified = 0;
      arr.addListener(() => notified++);

      arr.reset();
      expect(notified, 1);
    });
  });

  group('FormArrayControl.remove', () {
    test('removes the control at the given index', () {
      final arr = FormArrayControl<String>(null)
        ..add('a')
        ..add('b')
        ..add('c');

      arr.remove(1);

      expect(arr.controls!.length, 2);
      expect(arr.values, ['a', 'c']);
    });

    test('is a no-op when controls is null', () {
      final arr = FormArrayControl<String>(null);
      expect(() => arr.remove(0), returnsNormally);
      expect(arr.controls, isNull);
    });

    test('is a no-op when index is out of range (too large)', () {
      final arr = FormArrayControl<String>(null)..add('a');
      expect(() => arr.remove(5), returnsNormally);
      expect(arr.controls!.length, 1);
      expect(arr.values, ['a']);
    });

    test('is a no-op when index is negative', () {
      final arr = FormArrayControl<String>(null)..add('a');
      expect(() => arr.remove(-1), returnsNormally);
      expect(arr.controls!.length, 1);
    });

    test('does not notify listeners on an out-of-range remove', () {
      final arr = FormArrayControl<String>(null)..add('a');
      var notified = 0;
      arr.addListener(() => notified++);

      arr.remove(10);
      expect(notified, 0);

      arr.remove(0);
      expect(notified, 1);
    });
  });
}
