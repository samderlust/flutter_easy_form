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

  group('FormArrayControl.setValue / patchValue', () {
    test('patchValue resizes up and writes values without marking dirty',
        () {
      final arr = FormArrayControl<String>(null);

      arr.patchValue(['a', 'b', 'c']);

      expect(arr.controls!.length, 3);
      expect(arr.values, ['a', 'b', 'c']);
      expect(arr.isDirty, false);
      expect(arr.isTouched, false);
    });

    test('patchValue resizes down', () {
      final arr = FormArrayControl<String>(null)
        ..add('a')
        ..add('b')
        ..add('c')
        ..add('d');

      arr.patchValue(['x', 'y']);

      expect(arr.controls!.length, 2);
      expect(arr.values, ['x', 'y']);
    });

    test('patchValue reuses existing FormControl instances in place', () {
      final arr = FormArrayControl<String>([
        FormControl<String>('a'),
        FormControl<String>('b'),
      ]);
      final firstRef = arr.controls![0];
      final secondRef = arr.controls![1];

      arr.patchValue(['A', 'B']);

      expect(identical(arr.controls![0], firstRef), true);
      expect(identical(arr.controls![1], secondRef), true);
      expect(arr.values, ['A', 'B']);
    });

    test('setValue marks the array and its children as dirty', () {
      final arr = FormArrayControl<String>(null);

      arr.setValue(['a', 'b']);

      expect(arr.values, ['a', 'b']);
      expect(arr.isDirty, true);
      expect(arr.isTouched, true);
      expect(arr.controls!.every((c) => c.dirty), true);
    });

    test('setValue clears dirty after a subsequent reset', () {
      final arr = FormArrayControl<String>([FormControl<String>('initial')]);
      arr.setValue(['edited']);
      expect(arr.isDirty, true);

      arr.reset();
      expect(arr.values, ['initial']);
      expect(arr.isDirty, false);
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

  group('FormArrayControl.insert', () {
    test('inserts at the given index', () {
      final arr = FormArrayControl<String>(null)
        ..add('a')
        ..add('c');

      arr.insert(1, 'b');

      expect(arr.values, ['a', 'b', 'c']);
    });

    test('inserts at 0 prepends', () {
      final arr = FormArrayControl<String>(null)..add('b');

      arr.insert(0, 'a');

      expect(arr.values, ['a', 'b']);
    });

    test('clamps out-of-range index to end', () {
      final arr = FormArrayControl<String>(null)..add('a');

      arr.insert(100, 'z');

      expect(arr.values, ['a', 'z']);
    });

    test('clamps negative index to 0', () {
      final arr = FormArrayControl<String>(null)..add('b');

      arr.insert(-5, 'a');

      expect(arr.values, ['a', 'b']);
    });

    test('works on null controls list', () {
      final arr = FormArrayControl<String>(null);

      arr.insert(0, 'first');

      expect(arr.values, ['first']);
    });

    test('propagates validators to the new child', () {
      final arr = FormArrayControl<String>(
        null,
        validators: [requiredValidator],
      );

      arr.insert(0, null);
      arr.controls![0].validate();

      expect(arr.controls![0].valid, false);
    });

    test('notifies listeners', () {
      final arr = FormArrayControl<String>(null)..add('a');
      var notified = 0;
      arr.addListener(() => notified++);

      arr.insert(0, 'b');

      expect(notified, 1);
    });
  });

  group('FormArrayControl.move', () {
    test('moves a control forward', () {
      final arr = FormArrayControl<String>(null)
        ..add('a')
        ..add('b')
        ..add('c');

      arr.move(0, 2);

      expect(arr.values, ['b', 'c', 'a']);
    });

    test('moves a control backward', () {
      final arr = FormArrayControl<String>(null)
        ..add('a')
        ..add('b')
        ..add('c');

      arr.move(2, 0);

      expect(arr.values, ['c', 'a', 'b']);
    });

    test('same index is a no-op and does not notify', () {
      final arr = FormArrayControl<String>(null)
        ..add('a')
        ..add('b');
      var notified = 0;
      arr.addListener(() => notified++);

      arr.move(1, 1);

      expect(notified, 0);
      expect(arr.values, ['a', 'b']);
    });

    test('out-of-range from is a no-op', () {
      final arr = FormArrayControl<String>(null)..add('a');

      arr.move(5, 0);

      expect(arr.values, ['a']);
    });

    test('out-of-range to is a no-op', () {
      final arr = FormArrayControl<String>(null)..add('a');

      arr.move(0, 5);

      expect(arr.values, ['a']);
    });

    test('null controls is a no-op', () {
      final arr = FormArrayControl<String>(null);
      expect(() => arr.move(0, 1), returnsNormally);
    });

    test('preserves FormControl identity', () {
      final arr = FormArrayControl<String>(null)
        ..add('a')
        ..add('b')
        ..add('c');
      final ref = arr.controls![0];

      arr.move(0, 2);

      expect(identical(arr.controls![2], ref), true);
    });

    test('notifies listeners on successful move', () {
      final arr = FormArrayControl<String>(null)
        ..add('a')
        ..add('b');
      var notified = 0;
      arr.addListener(() => notified++);

      arr.move(0, 1);

      expect(notified, 1);
    });
  });

  group('FormArrayControl.addControl', () {
    test('appends a pre-built control', () {
      final arr = FormArrayControl<String>(null)..add('a');
      final custom = FormControl<String>('b');

      arr.addControl(custom);

      expect(arr.values, ['a', 'b']);
      expect(identical(arr.controls![1], custom), true);
    });

    test('does not overwrite the control validators', () {
      String? myValidator(String? v) => v == 'bad' ? 'custom error' : null;
      final arr = FormArrayControl<String>(
        null,
        validators: [requiredValidator],
      );
      final custom = FormControl<String>('bad', validators: [myValidator]);

      arr.addControl(custom);
      custom.validate();

      expect(custom.error, 'custom error');
      // Validators should be the custom one, not the array's requiredValidator
      expect(custom.validators.length, 1);
      expect(identical(custom.validators[0], myValidator), true);
    });

    test('works on null controls list', () {
      final arr = FormArrayControl<String>(null);
      arr.addControl(FormControl<String>('x'));

      expect(arr.values, ['x']);
    });

    test('notifies listeners', () {
      final arr = FormArrayControl<String>(null);
      var notified = 0;
      arr.addListener(() => notified++);

      arr.addControl(FormControl<String>('x'));

      expect(notified, 1);
    });
  });
}
