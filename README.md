[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)

# Ezy Form - handle form in flutter with ease

## Features

"Ezy Form" is a Flutter package designed to simplify the handling of forms within Flutter applications. It offers a streamlined and efficient approach to form management, including features such as form validation, data input handling, error reporting, and state management. This package allows developers to create interactive and dynamic forms easily and efficiently.

## Installing and import the library:

```
dependencies:
    ezy_form: <latest_version>
```

## Usage

### declare a form

```
final form = FormGroup({
  'name': FormControl<String>(null, validators: [requiredValidator]),
  'email': FormControl<String>(null, validators: [requiredValidator]),
  'gender': FormControl<String>(null, validators: [requiredValidator]),
  'agreed': FormControl<bool>(false, validators: [requiredTrueValidator]),
  'tags': FormArrayControl<String>(null, validators: [requiredValidator]),
  'info': FormGroup({
    'firstName': FormControl<String>(null, validators: [requiredValidator]),
    'lastName': FormControl<String>(null, validators: [requiredValidator]),
  }),
});
```

note that all [FormControl] or [FormArrayControl] must be placed within [FormGroup]

### render form widget

```
EzyFormWidget(
    formGroup: form, /// form that declared above
    builder: (context, model) {
        ///add form fields
    }
)
```

### render each field

```
EzyFormControl<String>(
formControlName: 'email',
builder: (context, control) => TextField(
    onChanged: (value) => control.setValue(value),
    decoration: InputDecoration(
    labelText: 'Email',
    errorText: control.valid ? null : 'Email is required',
    ),
    )
)
```

```
 EzyFormArrayControl<String>(
    formControlName: 'tags',
    builder: (context, arrayControl) => Column()
)
```

in form array you can call `arrayControl.add()` to add child [FormControl] into the array (more in example)

### consumer a form in other place

```
EzyFormConsumer(
    builder:(context, form){
        ///
    }
)
```

this allow you to access `EzyFormWidget` that surrounds
