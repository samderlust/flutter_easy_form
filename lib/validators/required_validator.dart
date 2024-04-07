import 'validator_base.dart';

class RequiredValidator<T> extends AbstractValidator<T> {
  RequiredValidator()
      : super(
          'required',
          (value) {
            if (value == null) {
              return 'required';
            }
            if ((value is String) && value.isEmpty) {
              return 'required';
            }

            return null;
          },
        );
}
