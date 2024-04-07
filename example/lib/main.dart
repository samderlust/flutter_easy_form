import 'package:dynamic_form/dynamic_form.dart';
import 'package:dynamic_form/form_control.dart';
import 'package:dynamic_form/validators/required_validator.dart';
import 'package:dynamic_form/validators/validator_base.dart';
import 'package:flutter/material.dart';

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
  'password': FormControl<String>(null),
});

class DynamicFormExample extends StatelessWidget {
  const DynamicFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dynamic Form Example')),
      body: DynamicFormWidget(
        formGroup: form,
        builder: (context, model) => Column(
          children: [
            DynamicFormControl<String>(
              formControlName: 'name',
              builder: (context, control) => TextField(
                onChanged: (value) => control.setValue(value),
                decoration: InputDecoration(
                  labelText: 'Name',
                  errorText: control.valid ? null : 'Name is required',
                ),
              ),
            ),
            DynamicFormControl<String>(
              formControlName: 'email',
              builder: (context, control) => TextField(
                onChanged: (value) => control.setValue(value),
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: control.valid ? null : 'Email is required',
                ),
              ),
            ),
            DynamicFormControl<String>(
              formControlName: 'password',
              builder: (context, control) => TextField(
                onChanged: (value) => control.setValue(value),
                decoration: const InputDecoration(labelText: 'Password'),
              ),
            ),
            DynamicFormControl<String>(
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
            DynamicFormControl<bool>(
              formControlName: 'agreed',
              builder: (context, control) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    value: control.value,
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
              onPressed: () {
                // model.control('name').setValue('Sam');
                model.control('agreed').setValue(true);
              },
              child: const Text('change name'),
            ),
            const SizedBox(height: 20),
            DynamicFormConsumer(builder: (context, form) {
              return ElevatedButton(
                onPressed: () {
                  form.validate();
                  print(form);
                },
                child: const Text('Submit'),
              );
            })
          ],
        ),
      ),
    );
  }
}
