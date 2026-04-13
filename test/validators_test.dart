import 'package:ezy_form/ezy_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('emailValidator', () {
    test('null and empty pass (defer to requiredValidator)', () {
      expect(emailValidator(null), isNull);
      expect(emailValidator(''), isNull);
    });

    test('valid emails pass', () {
      expect(emailValidator('a@b.c'), isNull);
      expect(emailValidator('user@example.com'), isNull);
      expect(emailValidator('user+tag@sub.domain.co'), isNull);
    });

    test('invalid emails fail', () {
      expect(emailValidator('not-an-email'), isNotNull);
      expect(emailValidator('@missing.local'), isNotNull);
      expect(emailValidator('missing@domain'), isNotNull);
      expect(emailValidator('spa ces@example.com'), isNotNull);
    });
  });

  group('minLength', () {
    final v = minLength(3);

    test('null and empty pass (defer to requiredValidator)', () {
      expect(v(null), isNull);
      expect(v(''), isNull);
    });

    test('strings shorter than min fail', () {
      expect(v('ab'), isNotNull);
    });

    test('strings at or above min pass', () {
      expect(v('abc'), isNull);
      expect(v('abcd'), isNull);
    });
  });

  group('maxLength', () {
    final v = maxLength(5);

    test('null passes', () {
      expect(v(null), isNull);
    });

    test('strings longer than max fail', () {
      expect(v('123456'), isNotNull);
    });

    test('strings at or below max pass', () {
      expect(v('12345'), isNull);
      expect(v('1234'), isNull);
      expect(v(''), isNull);
    });
  });

  group('minValue', () {
    final v = minValue(10);

    test('null passes', () {
      expect(v(null), isNull);
    });

    test('values below min fail', () {
      expect(v(9), isNotNull);
      expect(v(-1), isNotNull);
    });

    test('values at or above min pass', () {
      expect(v(10), isNull);
      expect(v(100), isNull);
    });
  });

  group('maxValue', () {
    final v = maxValue(100);

    test('null passes', () {
      expect(v(null), isNull);
    });

    test('values above max fail', () {
      expect(v(101), isNotNull);
    });

    test('values at or below max pass', () {
      expect(v(100), isNull);
      expect(v(0), isNull);
    });
  });

  group('min/max with double', () {
    test('double minValue', () {
      final v = minValue(1.5);
      expect(v(1.4), isNotNull);
      expect(v(1.5), isNull);
      expect(v(2.0), isNull);
    });

    test('double maxValue', () {
      final v = maxValue(9.9);
      expect(v(10.0), isNotNull);
      expect(v(9.9), isNull);
    });
  });

  group('pattern', () {
    final v = pattern(RegExp(r'^\d{3}-\d{4}$'));

    test('null and empty pass', () {
      expect(v(null), isNull);
      expect(v(''), isNull);
    });

    test('matching strings pass', () {
      expect(v('123-4567'), isNull);
    });

    test('non-matching strings fail', () {
      expect(v('12-4567'), isNotNull);
      expect(v('abc'), isNotNull);
    });

    test('custom message', () {
      final vMsg =
          pattern(RegExp(r'^\d+$'), message: 'digits only');
      expect(vMsg('abc'), 'digits only');
    });
  });

  group('equalTo', () {
    test('matching values pass', () {
      final other = FormControl<String>('secret');
      final v = equalTo(other);
      expect(v('secret'), isNull);
    });

    test('mismatched values fail', () {
      final other = FormControl<String>('secret');
      final v = equalTo(other);
      expect(v('wrong'), isNotNull);
    });

    test('custom message', () {
      final other = FormControl<String>('a');
      final v = equalTo(other, message: 'passwords must match');
      expect(v('b'), 'passwords must match');
    });

    test('tracks the other control live', () {
      final other = FormControl<String>('a');
      final v = equalTo(other);
      expect(v('a'), isNull);
      other.setValue('b');
      expect(v('a'), isNotNull);
      expect(v('b'), isNull);
    });
  });

  group('compose', () {
    test('returns first error', () {
      final v = compose<String>([
        requiredValidator,
        minLength(5),
      ]);
      expect(v(null), 'required');
      expect(v('ab'), contains('at least 5'));
      expect(v('abcde'), isNull);
    });

    test('returns null when all pass', () {
      final v = compose<String>([
        requiredValidator,
        maxLength(10),
      ]);
      expect(v('hello'), isNull);
    });
  });

  group('composeOr', () {
    test('returns null if any validator passes', () {
      final v = composeOr<String>([
        (value) => value == 'admin' ? null : 'not admin',
        emailValidator,
      ]);
      // 'admin' passes the first validator
      expect(v('admin'), isNull);
      // valid email passes the second validator
      expect(v('user@example.com'), isNull);
    });

    test('returns last error if all fail', () {
      final v = composeOr<String>([
        (value) => 'first-error',
        (value) => 'last-error',
      ]);
      expect(v('anything'), 'last-error');
    });
  });
}
