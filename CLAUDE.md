# Scrutiny

Scrutiny is a syatem for managing motorsport scrutineering.

It is a Flutter monorepo using pub workspaces.
Two applications share three pure-Dart packages.

## Layout

```
Scrutiny/
  pubspec.yaml          # workspace root, resolution happens here
  app/                  # scrutiny_app    — mobile (Android, iOS)
  admin/                # scrutiny_admin  — web  [not created yet]
  packages/
    core/               # scrutiny_core   — Result, AppException, IDs
    domain/             # scrutiny_domain — entities, repository interfaces, use cases
    data/               # scrutiny_data   — DTOs, mappers, repository implementations
```

Dependency direction, never to be violated:

```
core  <-  domain  <-  data  <-  app / admin
```

`core`, `domain` and `data` are pure Dart packages. They must not depend on
Flutter. If shared widgets or theming become necessary, add a separate
`packages/ui` as a Flutter package rather than pulling Flutter into these.

## Adding a package

Three steps, all required:

1. `dart create --template=package packages/<name>`
2. In its `pubspec.yaml`: set `name: scrutiny_<name>`, add `publish_to: none`
   and `resolution: workspace`
3. Add the path to `workspace:` in the root `pubspec.yaml`

Then run `flutter pub get` from the root. There must be exactly one
`pubspec.lock`, at the root. A lock file appearing inside a package means
`resolution: workspace` is missing.

Never add `dependency_overrides` — it breaks workspace resolution.

## Layer rules

### domain

- Depends only on `scrutiny_core` and `freezed_annotation`.
- **Must never depend on `supabase_flutter`, `firebase_*`, `dio`, `riverpod` or
  any other SDK.** This single rule is what keeps the backend replaceable; the
  compiler enforces the rest.
- No `fromJson` / `toJson`. Serialisation belongs to `data`.
- Entities are Freezed. **Every field is `required`, including nullable ones**
  (`required String? avatarUrl`). Do not use `@Default(...)` on entities — it
  lets a mapper silently omit a field instead of failing to compile.
- Identifiers are wrapped in `extension type` (`UserId`, `Email`) so a raw
  `String` cannot be passed by mistake. No runtime cost.

### data

- DTOs are Freezed with `json_serializable`. They mirror the wire format, not
  the domain shape.
- `build.yaml` sets `field_rename: snake`, so `displayName` maps to
  `display_name` without an explicit `@JsonKey`. Only add `@JsonKey` for fields
  that genuinely deviate.
- **Mapping extensions live in the same file as their DTO**, never in a separate
  `mappers/` directory. Adding a field to a DTO should put the mapping directly
  in view.
- Repository implementations take their dependencies through the constructor.
  **No Riverpod in this package.**
- Name implementations after their backend: `SupabaseAuthRepository`, not
  `AuthRepositoryImpl`. A second implementation should be able to sit beside the
  first.
- Absence is not an error. A lookup that may legitimately find nothing returns
  `Success(null)`, not `Failure(NotFoundException())`.

### app / admin

- The only packages that may use Riverpod.
- `lib/di/repository_providers.dart` is the single place where interfaces are
  bound to implementations. Changing backend should mean editing that file
  alone.
- `Result` is converted to `AsyncValue` at the provider boundary: rethrow the
  `Failure` and let Riverpod capture it as `AsyncError`. Below that line nothing
  throws; above it, nothing sees `Result`.

## Error handling

- Repositories and use cases return `Result<T>` from `scrutiny_core`. **Do not
  throw across layer boundaries.**
- SDK exceptions (`PostgrestException`, `DioException`, `FirebaseAuthException`)
  are translated into `AppException` subtypes inside the repository
  implementation and must never escape `data`.
- `AppException` is sealed. Adding a subtype will break every exhaustive
  `switch` over it — that is intentional; fix the call sites rather than adding
  a default branch.
- `Result` is a hand-written sealed class, not Freezed. Consume it with pattern
  matching:

  ```dart
  switch (result) {
    case Success(:final value): ...
    case Failure(:final error): ...
  }
  ```

## Language and text

- All identifiers, comments, doc comments and hard-coded strings use **British
  English** spelling: `colour`, `organisation`, `initialise`, `cancelled`,
  `serialise`, `behaviour`.
- User-facing text in `app/` and `admin/` goes through l10n
  (`AppLocalizations`). Korean and any other language lives in `.arb` files
  only, never inline. The template ARB is British English.
- `AppException.message` is the one exception: it is British English and not
  localised, being primarily diagnostic. If it must reach a user, map the
  exception type to a localised string at the widget layer.
- Public APIs carry Dartdoc (`///`). Explain why, not what — the signature
  already says what.

## Code generation

Generated files (`*.freezed.dart`, `*.g.dart`) **are committed**. The policy is
uniform across the repository: `app` cannot compile without `domain`'s generated
files, so a split policy would give the drawbacks of both.

After editing any entity, DTO or Riverpod provider:

```bash
cd packages/domain && dart run build_runner build -d
cd packages/data   && dart run build_runner build -d
cd app             && dart run build_runner build -d
```

build_runner operates per package; running it at the root does nothing. Never
hand-write or hand-edit a generated file.

Before committing, confirm sources and generated output agree:

```bash
dart run build_runner build -d && git status --short
```

## Verification

Run from the root after any change:

```bash
flutter pub get
flutter analyze
```

Use `flutter`, not `dart`, now that `app` is part of the workspace — `dart pub`
cannot resolve Flutter SDK dependencies.

**Editing `packages/core` or `packages/domain` can break `app` and `admin`
simultaneously.** After changing anything in those packages, check the whole
workspace, not just the package you edited.

## Environment

- Primary development on Windows with Git Bash; a Mac (M4 Pro) is also in use.
- iOS and macOS builds are only possible on the Mac. Windows builds `web` and
  `windows` targets.
- Line endings are normalised by `.gitattributes` (`eol=lf`, except `.bat` and
  `.ps1`).

## Working style

- **Report before changing.** When asked to review or verify, list findings with
  file paths and actual values; do not start editing unless asked.
- Prefer the smallest change that satisfies the request. Do not refactor
  adjacent code, rename things, or add abstractions that were not requested.
- Do not introduce a shared `UseCase<Params, T>` interface, a `Result.fold`
  helper, or similar abstractions until there are several concrete cases
  demanding them.
- Follow the structure of `lib/features/auth/` when adding a new feature.

## Current state

The `User` vertical slice (sign-in → `Account` → `UserProfile` → display name)
is the reference implementation. It runs against `FakeAuthRepository` and
`FakeUserProfileRepository`; Supabase is not yet wired in.

`admin` has not been created. When it is, the application ID must be
`kr.scrutineer.scrutiny.admin` against the app's `kr.scrutineer.scrutiny.app` — both
may be installed on the same machine.

The fakes are to be kept after the real implementations arrive. Move them under
`test/fakes/` and use them to drive use case tests offline.
