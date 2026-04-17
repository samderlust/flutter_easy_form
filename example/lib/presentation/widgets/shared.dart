import 'package:ezy_form/ezy_form.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

Widget styledTextField({
  required String label,
  required FormControl<String> control,
  required TextEditingController controller,
  required FocusNode focusNode,
}) {
  return TextField(
    controller: controller,
    focusNode: focusNode,
    decoration: InputDecoration(
      labelText: label,
      errorText: control.valid ? null : control.error,
      helperText: control.isDirty
          ? 'dirty'
          : control.isTouched
              ? 'touched'
              : null,
    ),
  );
}

String formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

extension IndexedIterable<E> on Iterable<E> {
  Iterable<R> mapIndexed<R>(R Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}
