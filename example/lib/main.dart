import 'package:easy_form/easy_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DynamicFormExample(),
    );
  }
}

final form = FormGroup({
  'name': FormControl<String>(null, validators: [requiredValidator]),
  'email': FormControl<String>(null, validators: [requiredValidator]),
  'gender': FormControl<String>(null, validators: [requiredValidator]),
  'agreed': FormControl<bool>(false, validators: [requiredTrueValidator]),
  'tags': FormArrayControl<String>([], validators: [requiredValidator]),
});

class DynamicFormExample extends StatelessWidget {
  const DynamicFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dynamic Form Example')),
      body: SingleChildScrollView(
        child: DynamicFormWidget(
          formGroup: form,
          builder: (context, model) => Column(
            children: [
              EasyFormControl<String>(
                formControlName: 'name',
                builder: (context, control) => ControlledTextField(
                  onTextChanged: (value) => control.setValue(value),
                  onFormControlReset: (fn) => control.onReset(fn),
                  onDirty: () => control.markAsDirty(),
                  onTouched: () => control.markAsTouched(),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: control.valid ? null : 'Name is required',
                    helperText: control.dirty
                        ? 'Name is dirty'
                        : control.touched
                            ? 'Name is touched'
                            : null,
                  ),
                ),
              ),
              EasyFormControl<String>(
                formControlName: 'email',
                builder: (context, control) => TextFormField(
                  initialValue: control.value,
                  onChanged: (value) => control.setValue(value),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: control.valid ? null : 'Email is required',
                  ),
                ),
              ),
              EasyFormControl<String>(
                formControlName: 'gender',
                builder: (context, control) => DropdownButtonFormField<String>(
                  value: control.value,
                  onChanged: (value) => control.setValue(value),
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    errorText: control.valid ? null : 'Gender is required',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                  ],
                ),
              ),
              EasyFormArrayControl<String>(
                formControlName: 'tags',
                builder: (context, arrayControl) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Tags:'),
                        TextButton.icon(
                            onPressed: () => arrayControl.add(),
                            icon: Icon(Icons.add),
                            label: Text('Add Tag')),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: (arrayControl.controls ?? [])
                          .mapIndexed((control, index) => TextFormField(
                                key: ValueKey(control.hashCode + index),
                                initialValue: control.value,
                                decoration: InputDecoration(
                                    labelText: 'Tag $index',
                                    errorText: control.valid
                                        ? null
                                        : 'Tag $index is required',
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () =>
                                          arrayControl.remove(index),
                                    )),
                                onChanged: (value) => control.setValue(value),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              EasyFormControl<bool>(
                formControlName: 'agreed',
                builder: (context, control) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      value: control.value ?? false,
                      onChanged: (value) => control.setValue(value),
                      title: const Text('I agree'),
                    ),
                    if (!control.valid)
                      const Text(
                        'You must agree to the terms and conditions',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              ElevatedButton(
                onPressed: () {},
                child: const Text('change name'),
              ),
              const SizedBox(height: 20),
              Text("FORM IS VALID: ${model.isValid}"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  model.validate();
                  print(model.values);
                },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  model.reset();
                  print(model.values);
                },
                child: const Text('reset'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ControlledTextField extends HookWidget {
  const ControlledTextField({
    super.key,
    this.decoration,
    this.onTextChanged,
    this.onFormControlReset,
    this.onTouched,
    this.onDirty,
  });

  final InputDecoration? decoration;
  final Function(String value)? onTextChanged;
  final Function(VoidCallback fn)? onFormControlReset;
  final VoidCallback? onTouched;
  final VoidCallback? onDirty;

  @override
  Widget build(BuildContext context) {
    return HookBuilder(builder: (context) {
      final textCtrl = useTextEditingController();

      final focusNode = useFocusNode();

      useEffect(() {
        onFormControlReset?.call(textCtrl.clear);

        focusNode.addListener(() {
          if (focusNode.hasFocus) {
            onTouched?.call();
          }
        });

        textCtrl.addListener(() {
          if (textCtrl.text != '') {
            onDirty?.call();
          }

          onTextChanged?.call(textCtrl.text);
        });
        return null;
      }, []);
      return TextField(
        focusNode: focusNode,
        controller: textCtrl,
        decoration: decoration,
      );
    });
  }
}
