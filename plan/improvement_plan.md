# ezy_form — UX & Feature Improvement Plan

A prioritized backlog of UX and feature improvements identified during the
0.0.2 review. Items are grouped by impact, then a suggested ship order is
listed at the end.

---

## High impact — fixes real friction in the current example/README

### 1. Split `reset()` (restore initial) and `clear()` (wipe to empty) — DONE in 1.0.0
Previously `FormControl.reset()` cleared `_value` to `null`, even when the
control was constructed with `FormControl<String>('hello')`. Any pre-filled
form (e.g. the example's "First Name") lost its initial state on reset, and
there was no way to ask for "back to initial". This also disagreed with
the rest of the form-library ecosystem (Angular reactive forms, web's
`<form>.reset()`, react-hook-form), where `reset()` means *restore initial*.

**Resolution (shipped in 1.0.0):** introduce a clean three-verb API across
all three model types and add `clear()` to `FormControlBase`.

| | `reset()` | `clear()` | `removeAll()` |
|---|---|---|---|
| `FormControl<T>` | restore constructor's initial value | set value to `null` | — |
| `FormGroup` | call `reset()` on every descendant | call `clear()` on every descendant | — |
| `FormArrayControl<T>` | restore initial children + values from snapshot | keep children, null every value | drop every child (`controls = []`) |

All three operations clear `dirty` / `touched` / `error` and notify.

**Why three verbs and not a `reset(clearAll: true)` flag:**
- Boolean params are a code smell — `reset(clearAll: false)` reads ambiguously.
- `reset()` already has an established meaning across form libraries; changing it to "go to initial unless you pass a flag" is surprising.
- Three verbs compose cleanly with `FormGroup.clear()` walking the tree —
  every leaf goes to `null` regardless of whether it lives inside an array
  or a nested group.

**Why both `clear()` and `removeAll()` on arrays:** "clear" is ambiguous
on a list. `clear()` keeps the structure (3 empty slots stay 3 empty
slots, which composes with `FormGroup.clear()`); `removeAll()` is the
explicit "drop every item" verb for use cases like a "Remove all tags"
button or rebuilding a dynamic form from scratch.

### 2. `setValue` no-op short-circuit + `markDirty` + `patchValue` — DONE in 1.0.0
Previously `setValue` always flipped `dirty`/`touched` and always notified
listeners, even on no-op writes. This made "load from a server response"
impossible without manually unsetting the flags afterward, and caused
redundant widget rebuilds.

**Resolution (shipped in 1.0.0):**
```dart
void setValue(T? v, {bool markDirty = true}) {
  if (v == _value) return; // no-op short-circuit
  _value = v;
  if (markDirty) {
    dirty = true;
    touched = true;
  }
  notifyListeners();
}

void patchValue(T? v) => setValue(v, markDirty: false);
```

### 3. `FormGroup.setValue` / `patchValue` — DONE in 1.0.0
Loading an API response into a form is the #1 form-library use case.
Previously this required walking the group manually and calling
`setValue` per leaf — typically 10–20 lines that had to stay in sync
with the form structure.

**Resolution (shipped in 1.0.0):**

```dart
// Lenient: ignores unknown keys, doesn't mark anything dirty.
form.patchValue({
  'name': 'Sam',
  'tags': ['flutter', 'dart'],
  'profile': {'first': 'S', 'last': 'D'},
});

// Strict: throws on missing/unknown keys, marks edits as dirty.
form.setValue({...}); // requires every key in the group
```

Both methods recurse into nested `FormGroup`s and dispatch `List`s into
nested `FormArrayControl`s. `FormArrayControl` got matching
`setValue(List<T?>)` / `patchValue(List<T?>)` methods that resize the
children list in place — existing `FormControl` instances are reused
where possible, so widgets holding direct references stay valid.

### 4. Built-in text binding in `EzyFormControl` — DONE in 1.0.0
The example's `ControlledTextField` (44 lines of `HookWidget` with focus
and text-controller wiring) was the biggest UX gap. Every consumer was
rewriting the same boilerplate to:

- create a `TextEditingController`
- two-way sync `controller.text ↔ control.value` (the only genuinely
  hard piece — infinite-loop risk, has to handle external `reset` /
  `clear` / `patchValue`)
- mark touched on focus loss

**Design decision: one widget, not separate bindings.** An earlier
iteration shipped `EzyTextBinding` / `EzyTypedTextBinding<T>` as
standalone widgets. This worked but introduced two new names users had
to learn, broke the `EzyForm*` naming convention, and felt disconnected
from the package's core identity of simplicity.

**Resolution: merge the binding into `EzyFormControl` itself.** The
builder signature changed from `(context, control)` to
`(context, control, controller, focusNode)`. A `TextEditingController`
and `FocusNode` are always created and passed in the builder — for text
inputs, wire them up; for non-text inputs, ignore them (`_, __`).

Three patterns, one widget:

```dart
// 1. String text field — controller auto-syncs, no parse/format needed
EzyFormControl<String>(
  formControlName: 'email',
  builder: (context, control, controller, focusNode) => TextField(
    controller: controller,
    focusNode: focusNode,
    decoration: InputDecoration(
      errorText: control.valid ? null : control.error,
    ),
  ),
)

// 2. Typed text field — supply parse + format
EzyFormControl<int>(
  formControlName: 'age',
  parse: int.tryParse,
  format: (v) => v?.toString() ?? '',
  builder: (context, control, controller, focusNode) => TextField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: TextInputType.number,
  ),
)

// 3. Non-text (checkbox, dropdown, etc.) — ignore controller/focusNode
EzyFormControl<bool>(
  formControlName: 'agreed',
  builder: (context, control, _, __) => Checkbox(
    value: control.value ?? false,
    onChanged: (v) => control.setValue(v),
  ),
)
```

**How it works internally:**
- For `String`: controller auto-syncs with the control (identity
  parse/format). Handles `reset`, `clear`, `patchValue` automatically.
- For non-`String` with `parse`/`format`: controller syncs via those
  callbacks. Unparseable text writes `null` to the control but the
  binding **never** rewrites the user's raw text mid-keystroke.
- For non-`String` without `parse`/`format`: controller stays idle —
  user ignores it and uses `onChanged` directly.
- `FocusNode` always fires touched-on-blur.
- Optional `controller:` / `focusNode:` parameters let callers supply
  externally-owned instances.

**Why this is better than standalone binding widgets:**
- ONE widget to learn, not three.
- Zero naming confusion — no `EzyTextBinding` / `EzyTypedTextBinding`
  breaking the `EzyForm*` convention.
- The simple `EzyFormControl + onChanged` pattern from the README still
  works — just add `_, __` for the unused params.
- Stays headless — the user still picks their text-input widget.

**Opinionated widgets are deliberately deferred** to a future companion
package (`ezy_form_fields` or `package:ezy_form/material.dart`). The
headless core stays lean.

### 5. `FormControl.onReset` is a single callback — second registrant overwrites the first
If two widgets observe the same control (e.g. a text field and a counter
badge), only one of them gets reset. Should be a list of callbacks, or
replaced by a `valueChanges` stream/listener mechanism that any number of
consumers can subscribe to.

---

## Medium impact — missing standard features

### 6. Built-in validator library — DONE in 1.0.0
Previously only `requiredValidator` and `requiredTrueValidator` shipped.

**Resolution (shipped in 1.0.0):** added `emailValidator`,
`minLength(n)`, `maxLength(n)`, `min(n)`, `max(n)`,
`pattern(RegExp, {message})`, `equalTo(otherControl, {message})`,
`compose([...])`, and `composeOr([...])`. All factory validators return
`null` on `null`/empty input so they compose cleanly with
`requiredValidator`.

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
(`clear()` and `removeAll()` shipped in 1.0.0 — see #1.)

- `insert(index, value)`
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

### 18. `FormControl<DateTime>` won't survive `jsonEncode(form.values)` — WON'T FIX
Decided against adding `toJson` / `fromJson` to `FormControl`. In
practice, JSON parsing belongs in the repository/data layer — by the
time data reaches the form, it's already typed Dart objects. The form
stays focused on state management; model conversion is a one-liner
(`MyModel.fromFormValues(form.values)`) in the calling code. The
example app demonstrates this pattern with a `UserProfile` model.

### 19. README doesn't show: nested groups, array validators, async, dynamic add/remove, or `EzyFormConsumer`
The package has features the docs hide.

### 20. Type-safety: `FormGroup` map accepts `Object` — DONE in 1.0.0
Previously `FormGroup({'email': 42})` compiled and only failed at
runtime on first lookup. Now `FormGroup` requires `Map<String, FormNode>`
where `FormNode` is an `abstract interface class` implemented by
`FormControl`, `FormArrayControl`, and `FormGroup`. Invalid entries are
caught at compile time.

### 21. `FormGroupArray` — array of `FormGroup`s
`FormArrayControl<T>` holds a flat list of scalars. Many real-world forms
need arrays of objects — e.g. a list of addresses (each with
street/city/zip), multiple phone numbers (type + number), or line items
in an invoice. A `FormGroupArray` (or `FormArrayControl<FormGroup>`)
would hold `List<FormGroup>` with `add()` / `remove(index)` /
`removeAll()` / `reset()` / `setValue(List<Map>)` / `patchValue(List<Map>)`
semantics matching the existing array API.

### 22. Async validators
Server-side checks (username availability, email uniqueness) need:

```dart
typedef AsyncValidatorFn<T> = Future<String?> Function(T? value);
```

…plus a `pending` state on the control and a debounce mechanism so the
form can show a loading indicator and delay submission until validation
completes.

### 23. `disabled` / `enabled` state on `FormControl`
Conditional fields ("shipping address same as billing") are a daily form
requirement. Disabled controls should:
- Be skipped by `validate()`
- Be excluded from `FormGroup.values`
- Expose an `enabled` / `disabled` getter
- Notify listeners on state change so the UI can grey out the field

---

## Suggested ship order

1. ~~**`FormControl.reset()` restores the initial value** — bug parity with
   `FormArrayControl`.~~ **Shipped in 1.0.0 along with `clear()` /
   `removeAll()` across all three model types.** (#1)
2. ~~**`setValue` short-circuits on no-op + optional `markDirty: false`,
   plus `FormGroup.patchValue`**~~ **Shipped in 1.0.0.** (#2, #3)
3. ~~**First-party `EzyTextField` / `EzyCheckbox` / `EzyDropdown`**~~
   **Resolved differently in 1.0.0**: merged text binding directly into
   `EzyFormControl` (builder now receives `controller` + `focusNode`).
   Standalone `EzyTextBinding` / `EzyTypedTextBinding` were shipped then
   deleted in favor of this unified approach. Opt-in Material widgets
   deferred to a companion package. (#4)
4. ~~**Built-in validator library**~~ **Shipped in 1.0.0.** (#6)
5. **`disabled` state on `FormControl`.** (#9)
6. **Async validators + `pending` / debounce.** (#8)
7. **Multi-error map + i18n-friendly validator messages.** (#7, #12)
8. **Dynamic `addControl` / `removeControl` on `FormGroup`, plus `insert`
   / `clear` / `move` on `FormArrayControl`.** (#10, #11)
9. **Memoize `flatControls` / `values`** with notifier-based cache
   invalidation. (#13)
10. **`EzyFormSelector` + `EzyFormSubmitButton`** for fewer rebuilds and a
    standard submit flow. (#14, #15)

11. **`FormGroupArray` — array of form groups** for complex repeated
    sections (addresses, line items, etc.). (#21)

Items #5, #16–#20 are smaller polish tasks that can land alongside any of
the above as they touch the same files.
