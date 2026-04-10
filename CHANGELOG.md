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
