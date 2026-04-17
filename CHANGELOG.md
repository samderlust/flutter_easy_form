## 1.0.0 (Unreleased)

### Breaking changes

* **`FormControl.reset()` now restores the constructor-time initial value**
  instead of clearing to `null`. This brings it in line with the
  ecosystem (Angular reactive forms, web `<form>.reset()`, react-hook-form)
  and with the `FormArrayControl.reset()` snapshot behavior shipped in
  0.0.2. Migration: if your code relied on `reset()` wiping a control to
  `null`, call the new `clear()` instead.
* **`FormControlBase` interface gained a `clear()` method.** Any custom
  implementer of this interface must add it.
* **`FormControl.setValue` is now a no-op when the new value equals the
  current value.** No listeners are notified and `dirty` / `touched` are
  not flipped. Most consumers won't notice this; if you relied on
  `setValue` to forcibly retrigger a rebuild on an unchanged value, call
  `notifyListeners()` directly or use `markAsDirty()` / `markAsTouched()`.
* **`FormGroup` now requires `Map<String, FormNode>`** instead of
  `Map<String, Object>`. `FormControl`, `FormArrayControl`, and
  `FormGroup` all implement the new `FormNode` interface, so existing
  code that passes form nodes compiles unchanged. Code that accidentally
  passed raw `Map`, `int`, `String`, etc. as map values will now fail at
  compile time instead of at runtime — this is the intended improvement.
* **`EzyFormControl` builder signature changed** from
  `(BuildContext, FormControl<T>)` to
  `(BuildContext, FormControl<T>, TextEditingController, FocusNode)`.
  Migration: add `controller, focusNode` params (or `_, __` if unused).
  `EzyFormControl` is now a `StatefulWidget` that manages the
  controller/focus-node lifecycle internally.

### New features

* **`FormControl.clear()`** — wipes the value to `null` and clears
  `dirty` / `touched` / `error`, regardless of the constructor's initial
  value. Use this for "Clear" buttons that should empty all fields.
* **`FormGroup.clear()`** — recursively clears every descendant control,
  preserving the group's structure (and any nested array shapes).
* **`FormArrayControl.clear()`** — keeps the current children but nulls
  every value, so an array with three slots stays at three empty slots.
  Composes naturally with `FormGroup.clear()`.
* **`FormArrayControl.removeAll()`** — drops every child outright,
  leaving `controls = []`. Use this when you want to start over from
  scratch (e.g. a "Remove all tags" button or rebuilding a dynamic form).

* **`FormControl.setValue` accepts `markDirty: false`** for programmatic
  writes that should not flip the `dirty` / `touched` flags (e.g.
  populating a form from an API response).
* **`FormControl.patchValue(T? v)`** — convenience wrapper around
  `setValue(v, markDirty: false)`.
* **`FormGroup.patchValue(Map)`** — recursively writes a (possibly
  partial) map of values into the group, descending into nested
  `FormGroup`s and dispatching `List`s into nested `FormArrayControl`s.
  Unknown keys are ignored. Nothing is marked dirty. This is the
  one-liner replacement for "load form values from an API response".
* **`FormGroup.setValue(Map)`** — strict variant of `patchValue` that
  throws `ArgumentError` on missing or unknown keys, on shape mismatches
  (e.g. a `List` for a `FormGroup` slot), and marks affected controls as
  `dirty` / `touched`.
* **`FormArrayControl.setValue(List<T?>)` /
  `patchValue(List<T?>)`** — resize the array's children list in place
  to match the new values. Existing `FormControl` instances are reused
  where possible, so widgets holding direct references stay valid.
* **`EzyFormControl` now provides a `TextEditingController` and
  `FocusNode` in its builder** (breaking: builder signature changed
  from `(context, control)` to `(context, control, controller,
  focusNode)`). For text inputs, wire the controller and focus node to
  get automatic two-way sync including external writes from `reset`,
  `clear`, `patchValue`, etc. For non-text inputs (checkbox, dropdown,
  slider, etc.) just ignore them (`_, __`). This replaces the
  previously-separate `EzyTextBinding` / `EzyTypedTextBinding` — one
  widget handles all cases.
* **Optional `parse` / `format` callbacks on `EzyFormControl`** for
  typed text binding. Supply them when `T` is not `String` (e.g. `int`,
  `double`, `DateTime`). The binding never rewrites the user's raw text
  mid-keystroke: typing `"abc"` into an int field leaves `"abc"` visible
  while the model holds `null`.
* **Optional `controller` / `focusNode` parameters on `EzyFormControl`**
  let callers supply externally-owned instances for imperative access.

* **`EzyFormControlWatcher<T>`** — a lightweight widget that watches a
  single `FormControl` and rebuilds when its value changes. Use it for
  reactive UI (e.g. conditionally showing a field when a checkbox is
  checked) without nesting inside the controlling field's builder. Accepts
  dotted paths for nested controls.
* **`EzyFormWatcher<R>`** — a selector-based widget that watches the
  entire `FormGroup` and rebuilds when any control changes. A `selector`
  function extracts the data you care about — use Dart records for
  type-safe multi-value watching. Also useful for derived/computed values
  like `form.isValid`.
* **Built-in validator library** — new validators shipped alongside the
  existing `requiredValidator` / `requiredTrueValidator`:
  - `emailValidator` — permissive email pattern check
  - `minLength(n)` / `maxLength(n)` — String length bounds
  - `min(n)` / `max(n)` — numeric bounds (works with `int` and `double`)
  - `pattern(RegExp, {message})` — regex match with optional custom error
  - `equalTo(otherControl, {message})` — cross-control equality (e.g.
    confirm password)
  - `compose([...])` — runs all validators, returns first error (AND)
  - `composeOr([...])` — returns null if any passes (OR), last error
    if all fail

  All factory validators return `null` on `null`/empty input so they
  compose cleanly with `requiredValidator` — put `requiredValidator`
  first to enforce presence, then the shape/range validator after it.

### Reset / clear / removeAll cheat sheet

| | `reset()` | `clear()` | `removeAll()` |
|---|---|---|---|
| `FormControl<T>` | restore initial value | value → `null` | — |
| `FormGroup` | recurse `reset()` | recurse `clear()` | — |
| `FormArrayControl<T>` | restore initial children | keep children, null values | drop every child |

All three operations also clear `dirty` / `touched` / `error` and notify.

---

## 0.0.2

* Fix: `FormArrayControl.validate()` now calls `notifyListeners()` so `EzyFormArrayControl` widgets rebuild to show errors after validation.
* Fix: `FormArrayControl.markAsDirty()` / `markAsTouched()` now call `notifyListeners()`, matching `FormControl`'s behavior.
* Fix: `FormArrayControl.validate()` no longer silently treats a null or empty array as valid — the array's validators now run against `null` when there are no children, so `requiredValidator` correctly flags an empty array as invalid.
* Fix: `FormGroup.isDirty` / `isTouched` now reflect edits made to `FormControl`s nested inside a `FormArrayControl` (previously the parent group reported `false` because only the array itself, not its children, was walked).
* Fix: `FormArrayControl.remove(int index)` is now a no-op when the index is out of range (or `controls` is null), instead of throwing `RangeError`.
* Fix: grammar in `FormGroup` lookup error — `"... not is invalid type"` is now `"... has invalid type"`.
* Internal: removed a dead `List<T>` branch in `FormGroup._flattenMapValues` and a needless map copy in `_travelNested`.
* Feat: `FormArrayControl` now accepts `arrayValidators: List<ArrayValidatorFn<T>>` for rules that need the whole list (min/max length, uniqueness, etc.). The existing `validators` field remains per-item and is propagated to each child.
* Fix: `FormArrayControl.reset()` now restores the array to its **initial shape and values** — items added via `add()` after construction are discarded and the original controls are rebuilt from a value snapshot taken in the constructor. Previously reset cleared each child in-place but left the list populated.
* Fix (potentially breaking): `FormArrayControl.values` now returns `List<T?>?` and includes `null` entries for empty slots. An array with three empty items yields `[null, null, null]` rather than `[]`, so the length matches `controls`. `ArrayValidatorFn<T>`'s argument type changed to `List<T?>?` accordingly.
* Fix: removed `FormControl`'s deep-equality `==` / `hashCode` override. Two distinct controls no longer compare equal just because they share the same value/state, which fixes silent collapse when storing controls in a `Set` or `Map` key.
* Fix: provider `of(context)` helpers now throw `StateError` with a descriptive message pointing at `EzyFormWidget`, instead of a plain `Exception`.
* Chore: bumped `pubspec.yaml` version to `0.0.2`.

## 0.0.1

* TODO: Describe initial release.
