# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package

This is a Flutter package published as `ezy_form` (the directory name `dynamic_form` is historical — the `pubspec.yaml` name, library name, and all imports use `ezy_form`). The single public entrypoint is `lib/ezy_form.dart`.

## Common commands

```bash
# Get dependencies (run in package root and in example/)
flutter pub get

# Run all tests
flutter test

# Run a single test file
flutter test test/form_group_test.dart

# Run a single test by name
flutter test --plain-name "test name substring"

# Static analysis (uses flutter_lints via analysis_options.yaml)
flutter analyze

# Run the example app
cd example && flutter run
```

## Architecture

The package implements a reactive-forms-style API built on top of Flutter's `ChangeNotifier` + `InheritedNotifier`. There is no third-party state management dependency.

### Three model types (all implement `FormControlBase`)

- `FormControl<T>` (`lib/src/models/form_control.dart`) — holds a single typed value, validators, and `dirty`/`touched`/`error` state. `setValue` mutates and notifies.
- `FormArrayControl<T>` (`lib/src/models/form_array_control.dart`) — holds `List<FormControl<T>>`. When constructed with existing controls or when `add()` is called, its `validators` list is **propagated down** to every child `FormControl`. Its own `error` is a roll-up of child errors.
- `FormGroup` (`lib/src/models/form_group.dart`) — holds `Map<String, Object>` where values may be `FormControl`, `FormArrayControl`, or a nested `FormGroup`. The group is the root aggregator: `isValid`, `isDirty`, `isTouched`, `validate()`, and `reset()` walk a **flattened** view of all descendant controls via `_flattenMapValues`.

### Nested control lookup

`FormGroup.control<T>(name)`, `groupControl(name)`, and `arrayControl<T>(name)` all accept **dot-separated paths** (e.g. `'info.firstName'`) and resolve them through `_travelNested`. When adding new lookup methods or extending nested handling, preserve this dot-path convention and the type checks that reject plain maps that aren't `FormGroup`/`FormControl`/`FormArrayControl`.

`FormGroup.values` returns a nested `Map<String, dynamic>` mirroring the group shape — nested groups recurse, `FormControl` contributes its `value`, and `FormArrayControl` contributes `values` (non-null children only).

### Widget ↔ model wiring

Three `InheritedNotifier` providers in `lib/src/providers/` bridge the models to the widget tree:

- `EzyFormProvider` wraps a `FormGroup`
- `EzyFormControlProvider<T>` wraps a `FormControl<T>`
- `EzyFormArrayProvider<T>` wraps a `FormArrayControl<T>`

The public widgets in `lib/src/` are thin wrappers around these:

- `EzyFormWidget` — **must be the root** of any form usage; installs `EzyFormProvider`.
- `EzyFormControl<T>` — looks up a `FormControl<T>` by `formControlName` from the ancestor `EzyFormProvider` and supplies it to `builder`.
- `EzyFormArrayControl<T>` — same, for `FormArrayControl<T>`.
- `EzyFormConsumer` — re-reads the ancestor `FormGroup` (used to access the form in places outside the original `builder`).

Because each `InheritedNotifier` listens to its own `ChangeNotifier`, calling `setValue` / `add` / `remove` on a model rebuilds only the subtree that depends on that specific notifier. `FormGroup.validate()` and `reset()` additionally call `notifyListeners()` on the group itself to force a top-level rebuild.

### Validators

`lib/src/validators.dart` defines the `ValidatorFn<T> = String? Function(T? value)` typedef and ships two built-ins: `requiredValidator` (handles null/empty for String, Iterable, List, Set, Map) and `requiredTrueValidator`. New validators should follow the same "return error message or null" contract so they compose in any control's `validators` list.

## Testing notes

Tests live in `test/` and are split by concern: `form_control_test.dart`, `form_group_test.dart`, `form_widget_test.dart`. Widget tests exercise the provider wiring end-to-end (pump an `EzyFormWidget`, interact with builders, assert on the underlying models), so changes to the inherited-notifier plumbing should be validated there.
