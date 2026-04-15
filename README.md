[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)

# Ezy Form - handle forms in Flutter with ease

A lightweight, headless form-state library for Flutter. No third-party state management — just `ChangeNotifier` + `InheritedNotifier`. You bring any widget (`TextField`, `CupertinoTextField`, `Checkbox`, `DropdownButtonFormField`, third-party inputs, etc.) and `ezy_form` handles the state, validation, and lifecycle.

## Installing

```yaml
dependencies:
  ezy_form: <latest_version>
```

```dart
import 'package:ezy_form/ezy_form.dart';
```

## Quick start

### 1. Declare a form

```dart
final form = FormGroup({
  'name': FormControl<String>('Sam', validators: [requiredValidator, minLength(2)]),
  'email': FormControl<String>(null, validators: [requiredValidator, emailValidator]),
  'age': FormControl<int>(25, validators: [requiredValidator, minValue(18)]),
  'gender': FormControl<String>(null, validators: [requiredValidator]),
  'agreed': FormControl<bool>(false, validators: [requiredTrueValidator]),
  'tags': FormArrayControl<String>(null, validators: [requiredValidator]),
  'info': FormGroup({
    'firstName': FormControl<String>(null, validators: [requiredValidator]),
    'lastName': FormControl<String>(null, validators: [requiredValidator]),
  }),
});
```

All `FormControl` and `FormArrayControl` instances must live inside a `FormGroup`.

### 2. Wrap with `EzyFormWidget`

```dart
EzyFormWidget(
  formGroup: form,
  builder: (context, model) {
    // add form fields below
  },
)
```

### 3. Render fields with `EzyFormControl`

`EzyFormControl` provides a `TextEditingController` and `FocusNode` in its builder. For text inputs, wire them up — reset / clear / patchValue will reflect into the field automatically. For non-text inputs, just ignore them.

**String text field** — controller auto-syncs:

```dart
EzyFormControl<String>(
  formControlName: 'email',
  builder: (context, control, controller, focusNode) => TextField(
    controller: controller,
    focusNode: focusNode,
    decoration: InputDecoration(
      labelText: 'Email',
      errorText: control.valid ? null : control.error,
    ),
  ),
)
```

**Typed text field** (int, double, DateTime, etc.) — supply `parse` + `format`:

```dart
EzyFormControl<int>(
  formControlName: 'age',
  parse: int.tryParse,
  format: (v) => v?.toString() ?? '',
  builder: (context, control, controller, focusNode) => TextField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: 'Age',
      errorText: control.valid ? null : control.error,
    ),
  ),
)
```

**Non-text input** (checkbox, dropdown, etc.) — ignore `controller` / `focusNode`:

```dart
EzyFormControl<bool>(
  formControlName: 'agreed',
  builder: (context, control, _, __) => CheckboxListTile(
    value: control.value ?? false,
    onChanged: (v) => control.setValue(v),
    title: const Text('I agree'),
  ),
)
```

### 4. Form arrays

```dart
EzyFormArrayControl<String>(
  formControlName: 'tags',
  builder: (context, arrayControl) => Column(
    children: [
      TextButton(
        onPressed: () => arrayControl.add(),
        child: const Text('Add tag'),
      ),
      for (var i = 0; i < (arrayControl.controls?.length ?? 0); i++)
        TextField(
          onChanged: (v) => arrayControl.controls![i].setValue(v),
        ),
    ],
  ),
)
```

`FormArrayControl` supports both per-item `validators` (propagated to each child) and `arrayValidators` that run against the whole list:

```dart
'tags': FormArrayControl<String>(
  null,
  validators: [requiredValidator],          // each tag must be non-empty
  arrayValidators: [
    (values) => (values == null || values.length < 2)
        ? 'Add at least 2 tags'
        : null,
  ],
),
```

### 5. Access the form from anywhere below `EzyFormWidget`

```dart
EzyFormConsumer(
  builder: (context, form) {
    return ElevatedButton(
      onPressed: () {
        if (form.validate()) {
          print(form.values);
        }
      },
      child: const Text('Submit'),
    );
  },
)
```

## Reactive value watching

Use `EzyFormControlWatcher` to rebuild part of the UI when a control's value changes — for example, conditionally showing a field:

```dart
EzyFormControlWatcher<bool>(
  formControlName: 'agreed',
  builder: (context, agreed) {
    if (agreed != true) return const SizedBox.shrink();
    return EzyFormControl<String>(
      formControlName: 'licenseNumber',
      builder: (context, control, controller, focusNode) => TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: const InputDecoration(labelText: 'License number'),
      ),
    );
  },
)
```

The watcher receives only the value (`T?`), keeping it minimal. It supports dotted paths (`'info.age'`) for nested controls.

### Watching multiple controls

Use `EzyFormWatcher` with a selector function when you need to react to **multiple controls** or compute a derived value. Dart records give you full type safety:

```dart
EzyFormWatcher(
  selector: (form) => (
    form.control<bool>('agreed').value,
    form.control<String>('name').value,
  ),
  builder: (context, values) {
    final (agreed, name) = values;
    if (agreed != true) return const SizedBox.shrink();
    return Text('Welcome, $name!');
  },
)
```

You can also derive computed values like form validity:

```dart
EzyFormWatcher<bool>(
  selector: (form) => form.isValid,
  builder: (context, isValid) => ElevatedButton(
    onPressed: isValid ? () => submit() : null,
    child: const Text('Submit'),
  ),
)
```

## Nested groups

`FormGroup` can be nested. Use dot-separated paths to look up controls:

```dart
final form = FormGroup({
  'info': FormGroup({
    'firstName': FormControl<String>(null),
  }),
});

// In the widget:
EzyFormControl<String>(
  formControlName: 'info.firstName',
  builder: (context, control, controller, focusNode) => TextField(
    controller: controller,
    focusNode: focusNode,
  ),
)
```

## Validators

Built-in validators that compose with each other. All factory validators return `null` on `null`/empty input so they pair cleanly with `requiredValidator`:

```dart
// Presence
requiredValidator          // non-null, non-empty (String, Iterable, Map)
requiredTrueValidator      // bool must be true

// String
emailValidator             // basic email pattern
minLength(n)               // length >= n
maxLength(n)               // length <= n
pattern(RegExp, {message}) // regex match

// Numeric (int / double)
minValue(n)                // value >= n
maxValue(n)                // value <= n

// Cross-control
equalTo(otherControl, {message})  // values must match (e.g. confirm password)

// Compositors
compose([v1, v2, ...])    // AND — first error wins
composeOr([v1, v2, ...])  // OR  — null if any passes
```

**Custom validators** follow the same `String? Function(T? value)` contract — return an error message or `null`:

```dart
ValidatorFn<String> noSpaces = (value) {
  if (value != null && value.contains(' ')) return 'no spaces allowed';
  return null;
};
```

## Form operations

### Validate

```dart
final isValid = form.validate();  // runs all validators, returns bool
```

### Reset (restore initial values)

```dart
form.reset();  // every control returns to its constructor-time value
```

### Clear (wipe to empty)

```dart
form.clear();  // every control value → null, dirty/touched/error cleared
```

### Load from server (`patchValue`)

```dart
// Partial, lenient, doesn't mark dirty. Unknown keys ignored.
form.patchValue({
  'name': 'Loaded Name',
  'email': 'loaded@example.com',
  'age': 42,
  'info': {'firstName': 'Sam', 'lastName': 'D'},
  'tags': ['flutter', 'dart'],
});
```

### Strict set (`setValue`)

```dart
// Requires all keys, marks dirty, throws on unknown/missing keys.
form.setValue({ ... });
```

### Read values

```dart
final map = form.values;  // nested Map<String, dynamic> mirroring the group shape
```

### State getters

```dart
form.isValid    // true if all controls are valid (after validate)
form.isDirty    // true if any control has been edited
form.isTouched  // true if any control has been focused
```

### Array operations

```dart
arrayControl.add('value');     // append a new child
arrayControl.remove(index);    // remove at index (no-op if out of range)
arrayControl.removeAll();      // drop every child
arrayControl.clear();          // keep children, null every value
arrayControl.reset();          // restore initial shape from constructor
arrayControl.setValue([...]);   // resize + update, marks dirty
arrayControl.patchValue([...]); // resize + update, no dirty
```

## Architecture

- **`FormControl<T>`** — single typed value, validators, dirty/touched/error state.
- **`FormArrayControl<T>`** — list of `FormControl<T>`. Per-item validators propagated to children. Array-level `arrayValidators` run against the aggregated list.
- **`FormGroup`** — `Map<String, Object>` of controls. Root aggregator for `isValid`, `isDirty`, `isTouched`, `validate()`, `reset()`, `clear()`.

All three are `ChangeNotifier` subclasses. The widget layer (`EzyFormWidget`, `EzyFormControl`, `EzyFormArrayControl`, `EzyFormConsumer`) uses `InheritedNotifier` so only the subtree that depends on a specific notifier rebuilds.
