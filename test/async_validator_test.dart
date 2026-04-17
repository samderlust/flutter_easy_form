import 'package:ezy_form/ezy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormControl async validators', () {
    test('validateAsync runs async validator after sync passes', () async {
      final control = FormControl<String>(
        'taken@email.com',
        validators: [requiredValidator],
        asyncValidators: [
          (value) async => value == 'taken@email.com' ? 'email taken' : null,
        ],
      );

      await control.validateAsync();

      expect(control.error, 'email taken');
      expect(control.valid, false);
      expect(control.pending, false);
    });

    test('async validator is skipped when sync validator fails', () async {
      var asyncRan = false;
      final control = FormControl<String>(
        null,
        validators: [requiredValidator],
        asyncValidators: [
          (value) async {
            asyncRan = true;
            return null;
          },
        ],
      );

      await control.validateAsync();

      expect(asyncRan, false);
      expect(control.error, 'required');
    });

    test('pending is true while async validator runs', () async {
      final pendingStates = <bool>[];
      final control = FormControl<String>(
        'test',
        asyncValidators: [
          (value) => Future.delayed(
                const Duration(milliseconds: 50),
                () => null,
              ),
        ],
      );

      control.addListener(() {
        pendingStates.add(control.pending);
      });

      await control.validateAsync();

      // Should have seen: true (started), false (finished)
      expect(pendingStates, contains(true));
      expect(pendingStates.last, false);
    });

    test('stale async result is discarded when value changes mid-flight',
        () async {
      final control = FormControl<String>(
        'check-this',
        asyncValidators: [
          (value) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return 'error for $value';
          },
        ],
      );

      // Start async validation, then change the value before it completes.
      final future = control.validateAsync();
      control.setValue('changed');
      await future;

      // The stale result should be discarded — no error set.
      expect(control.error, isNull);
      expect(control.pending, false);
    });

    test('async validator returns null on success', () async {
      final control = FormControl<String>(
        'available@email.com',
        asyncValidators: [
          (value) async => value == 'taken@email.com' ? 'email taken' : null,
        ],
      );

      await control.validateAsync();

      expect(control.error, isNull);
      expect(control.valid, true);
    });

    test('reset clears pending state', () async {
      final control = FormControl<String>(
        'test',
        asyncValidators: [
          (value) => Future.delayed(
                const Duration(milliseconds: 100),
                () => 'error',
              ),
        ],
      );

      // Start validation, then reset before it completes.
      final future = control.validateAsync();
      control.reset();

      expect(control.pending, false);
      expect(control.error, isNull);

      await future; // let it finish to avoid dangling futures
    });
  });

  group('FormGroup async validation', () {
    test('validateAsync runs all async validators in the group', () async {
      final form = FormGroup({
        'email': FormControl<String>(
          'taken@email.com',
          validators: [requiredValidator],
          asyncValidators: [
            (value) async =>
                value == 'taken@email.com' ? 'email taken' : null,
          ],
        ),
        'name': FormControl<String>('Sam', validators: [requiredValidator]),
      });

      final valid = await form.validateAsync();

      expect(valid, false);
      expect(form.control<String>('email').error, 'email taken');
      expect(form.control<String>('name').valid, true);
    });

    test('validateAsync returns true when all pass', () async {
      final form = FormGroup({
        'email': FormControl<String>(
          'available@email.com',
          asyncValidators: [
            (value) async =>
                value == 'taken@email.com' ? 'email taken' : null,
          ],
        ),
      });

      final valid = await form.validateAsync();
      expect(valid, true);
    });

    test('isPending reflects async validation state', () async {
      final form = FormGroup({
        'email': FormControl<String>(
          'test',
          asyncValidators: [
            (value) => Future.delayed(
                  const Duration(milliseconds: 50),
                  () => null,
                ),
          ],
        ),
      });

      final future = form.validateAsync();
      // isPending should be true while validators are running.
      expect(form.isPending, true);

      await future;
      expect(form.isPending, false);
    });
  });
}
