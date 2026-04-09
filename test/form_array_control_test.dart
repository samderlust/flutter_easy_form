import 'package:ezy_form/ezy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
