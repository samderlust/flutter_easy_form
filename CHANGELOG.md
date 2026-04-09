## 0.0.2

* Fix: `FormArrayControl.validate()` now calls `notifyListeners()` so
  `EzyFormArrayControl` widgets rebuild to show errors after validation.
* Fix: `FormArrayControl.markAsDirty()` / `markAsTouched()` now call
  `notifyListeners()`, matching `FormControl`'s behavior.
* Fix: `FormArrayControl.validate()` no longer silently treats a null or
  empty array as valid — the array's validators now run against `null`
  when there are no children, so `requiredValidator` correctly flags an
  empty array as invalid.
* Fix: `FormGroup.isDirty` / `isTouched` now reflect edits made to
  `FormControl`s nested inside a `FormArrayControl` (previously the
  parent group reported `false` because only the array itself, not its
  children, was walked).
* Fix: `FormArrayControl.remove(int index)` is now a no-op when the index
  is out of range (or `controls` is null), instead of throwing
  `RangeError`.
* Fix: grammar in `FormGroup` lookup error — `"... not is invalid type"`
  is now `"... has invalid type"`.
* Internal: removed a dead `List<T>` branch in `FormGroup._flattenMapValues`
  and a needless map copy in `_travelNested`.

## 0.0.1

* TODO: Describe initial release.
