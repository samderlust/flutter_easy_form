# ezy_form — UX & Feature Improvement Plan

A prioritized backlog of UX and feature improvements identified during the
0.0.2 review. Items are grouped by impact, then a suggested ship order is
listed at the end.

---

## High impact — fixes real friction in the current example/README

### 1. `FormControl.reset()` should restore the initial value
`reset()` currently clears `_value` to `null`, even when the control was
constructed with `FormControl<String>('hello')`. Any pre-filled form (e.g.
the example's "First Name") loses its initial state on reset.

**Fix:** apply the same snapshot pattern used in `FormArrayControl.reset()`
in 0.0.2 — store the initial value in the constructor and restore it.

```dart
final T? _initialValue;
FormControl(this._value, {...}) : _initialValue = _value;

@override
void reset() {
  _value = _initialValue;
  ...
}
```

### 2. `setValue` always marks dirty/touched and always notifies
Loading values from a server response is currently impossible without
flipping `dirty`/`touched` manually afterwards. `setValue` also notifies
on no-op writes, causing redundant rebuilds.

**Fix:**
```dart
void setValue(T? v, {bool markDirty = true}) {
  if (v == _value) return;
  _value = v;
  if (markDirty) {
    dirty = true;
    touched = true;
  }
  notifyListeners();
}
```
Plus a sibling `patchValue(T? v)` that never marks dirty.

### 3. No `FormGroup.patchValue(Map)` / `setValue(Map)`
Loading an API response into a form is the #1 form-library use case and
currently requires walking the group manually and calling `setValue` per
leaf. A recursive `patchValue` keyed off the group structure would change
the example from ~15 lines to one call.

**API sketch:**
```dart
void patchValue(Map<String, dynamic> values);
void setValueFromMap(Map<String, dynamic> values); // strict variant
```

### 4. No built-in field widgets
The example's `ControlledTextField` (44 lines of `HookWidget` with focus and
text-controller wiring) reveals the biggest UX gap. Every consumer rewrites
the same boilerplate to:

- create a `TextEditingController`
- mark touched on focus loss
- mark dirty on change
- hook `onReset` to clear the controller

**Fix:** ship first-party `EzyTextField`, `EzyCheckbox`, `EzyDropdown`
widgets that take a `formControlName` and handle all of the above
internally. This is what makes `flutter_form_builder` / `reactive_forms`
feel ergonomic.

### 5. `FormControl.onReset` is a single callback — second registrant overwrites the first
If two widgets observe the same control (e.g. a text field and a counter
badge), only one of them gets reset. Should be a list of callbacks, or
replaced by a `valueChanges` stream/listener mechanism that any number of
consumers can subscribe to.

---

## Medium impact — missing standard features

### 6. Limited validator library
Only `requiredValidator` and `requiredTrueValidator` ship today. The bare
minimum extras every form library provides:

- `emailValidator`
- `minLength(n)` / `maxLength(n)`
- `min(n)` / `max(n)` (numeric)
- `pattern(RegExp)`
- `equalTo(otherControl)` (password confirm)
- `compose([...])` / `composeOr([...])`

### 7. Single-string `error` field — no multi-error support
When a field fails both `required` and `minLength`, the user only sees one
error. Reactive-forms style:

```dart
Map<String, Object>? errors;   // {'required': true, 'minLength': 3}
String? get firstError;        // convenience
```

### 8. No async validators
Server-side checks (username availability, email uniqueness) need:

```dart
typedef AsyncValidatorFn<T> = Future<String?> Function(T? value);
```

…plus a `pending` state on the control and a debounce mechanism.

### 9. No `disabled` state on `FormControl`
Conditional fields ("shipping address same as billing") are a daily form
requirement. Disabled controls should be skipped by `validate()` and
excluded from `FormGroup.values`.

### 10. `FormGroup` can't add/remove controls dynamically
No `addControl(name, control)` / `removeControl(name)`. Required for
stepwise / wizard / dynamic forms.

### 11. `FormArrayControl` is missing standard list ops
- `insert(index, value)`
- `clear()`
- `move(from, to)` for drag-reorder UX
- An `add` overload that accepts a fully-built `FormControl<T>` so users
  can attach custom validators to a single item.

### 12. Validators return raw English strings (`'required'`)
Hard to localize. Either accept a message function:

```dart
requiredValidator(message: (loc) => loc.required)
```

…or return an error *key* that consumers map to localized strings.

---

## Lower impact — polish

### 13. `FormGroup.flatControls` and `values` recompute on every access
They walk the whole tree and are called from getters used inside builders.
Worth memoizing — invalidate the cache when any descendant notifies.

### 14. No selector widget that rebuilds on a single field's value change
`EzyFormConsumer` rebuilds whenever **any** control in the group changes.

```dart
EzyFormSelector<R>(
  selector: (form) => form.control('email').value,
  builder: (context, value) => ...,
)
```

…would reduce rebuild churn in big forms.

### 15. No "submit" helper
Every consumer writes the same pattern:

```dart
if (form.validate()) { onSubmit(form.values); }
```

A `form.submit(onValid: ..., onInvalid: ...)` or an `EzyFormSubmitButton`
widget would standardize it and let the lib also handle "focus first
invalid field".

### 16. No `validateOnChange` mode
Validation only fires when the consumer calls `validate()`. Reactive forms
typically support `onChange` / `onBlur` / `onSubmit` modes per control.

### 17. No dotted-path write helpers on `FormGroup`
You can `form.control('profile.firstName').setValue(x)`, but a
`form.setValueAt('profile.firstName', x)` would be friendlier and would
power the `patchValue` from #3.

### 18. `FormControl<DateTime>` won't survive `jsonEncode(form.values)`
Either document this clearly or add an opt-in `toJson()` on `FormGroup`
that serializes known non-JSON types.

### 19. README doesn't show: nested groups, array validators, async, dynamic add/remove, or `EzyFormConsumer`
The package has features the docs hide.

### 20. Type-safety: `FormGroup` map accepts `Object`
`FormGroup({'email': 42})` compiles and only fails on first lookup. A
sealed `FormControlBase` (or new `FormGroupNode`) interface used as the
map's value type would catch this at compile time.

---

## Suggested ship order

1. **`FormControl.reset()` restores the initial value** — bug parity with
   `FormArrayControl`, ~5 lines. (#1)
2. **`setValue` short-circuits on no-op + optional `markDirty: false`,
   plus `FormGroup.patchValue`** — unlocks "load from API". (#2, #3)
3. **First-party `EzyTextField` / `EzyCheckbox` / `EzyDropdown`** — biggest
   example/README cleanup. (#4)
4. **Built-in validator library** (`email`, `minLength`, `maxLength`, `min`,
   `max`, `pattern`, `compose`). (#6)
5. **`disabled` state on `FormControl`.** (#9)
6. **Async validators + `pending` / debounce.** (#8)
7. **Multi-error map + i18n-friendly validator messages.** (#7, #12)
8. **Dynamic `addControl` / `removeControl` on `FormGroup`, plus `insert`
   / `clear` / `move` on `FormArrayControl`.** (#10, #11)
9. **Memoize `flatControls` / `values`** with notifier-based cache
   invalidation. (#13)
10. **`EzyFormSelector` + `EzyFormSubmitButton`** for fewer rebuilds and a
    standard submit flow. (#14, #15)

Items #5, #16–#20 are smaller polish tasks that can land alongside any of
the above as they touch the same files.
