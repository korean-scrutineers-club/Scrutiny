# Scrutiny

Scrutiny is a system for managing motorsport scrutineering.

It is a Flutter monorepo using pub workspaces. Two applications share three
packages.

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
                        #                   (Flutter package: holds supabase_flutter)
```

Dependency direction, never to be violated:

```
core  <-  domain  <-  data  <-  app / admin
```

`core` and `domain` are pure Dart packages and must stay that way — they must
not depend on Flutter, and `dart test` must run in them without a Flutter SDK.

`data` is a Flutter package. It holds `supabase_flutter`, which needs Flutter
for session persistence and deep-link handling. This is the correct place for
that dependency: `data` is the layer that knows about infrastructure. It does
not weaken the boundary, because the rule that matters is the one below it —
`domain` has no SDK dependency.

If shared widgets or theming become necessary, add a separate `packages/ui`
rather than putting them in `data`.

Application identifiers are `kr.scrutineer.scrutiny.app` and
`kr.scrutineer.scrutiny.admin`. The reverse-domain prefix `kr.scrutineer`
corresponds to a domain that is actually held — it is not a placeholder and must
not be "corrected".

## Architecture

Clean Architecture, adapted. The dependency rule is absolute: source code
dependencies point inwards only, towards `domain`. Anything to do with storage,
transport, UI or DI frameworks stays outside it.

Repository **interfaces** live in `domain`; **implementations** live in `data`.
This is what inverts the dependency — `data` points at `domain`, never the
reverse. There is no separate repositories package.

Where this project departs from the conventional Flutter reading of Clean
Architecture — deliberately, after consideration. Do not "correct" these:

- **Entities use Freezed.** `freezed_annotation` is pure Dart and knows nothing
  of frameworks, so it does not violate the dependency rule. Hand-written `==`,
  `hashCode` and `copyWith` cost more than they save.
- **DTOs do not extend or implement entities.** The two are unrelated types
  joined by an explicit mapper. Subtyping would let a DTO pass wherever an entity
  is expected, erasing the boundary the layering exists to create — and Freezed
  cannot inherit from Freezed in any case.
- **No shared `UseCase<Params, T>` interface.** Use cases are plain classes with
  a `call` method. Introduce a common interface only when several concrete cases
  show what it should look like. The `Either` and `NoParams` of the usual
  examples are artefacts of pre-Dart-3 code; `Result` and pattern matching
  replace both.
- **No mandated `datasources/` layer.** A repository implementation may talk to
  an SDK directly when there is nothing to abstract. Add a data source when two
  implementations genuinely share one.

The rule that matters more than the label: `packages/domain` has no SDK
dependency in its pubspec. Everything else follows from that.

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
  Sealed unions with few fields and no need for `copyWith` (`AuthState`,
  `Result`) are hand-written instead; the `required` rule still applies to them.
- Identifiers are wrapped in `extension type` (`UserId`, `Email`) so a raw
  `String` cannot be passed by mistake. No runtime cost. An extension type cannot
  reject its input, so a value needing validation becomes a class with a private
  constructor and a factory returning `Result<T>`.
- Use cases are named as verb phrases **without a `UseCase` suffix**
  (`SignInWithEmail`, not `SignInWithEmailUseCase`). The directory and the `call`
  method already identify them.

### data

- DTOs are Freezed with `json_serializable`. They mirror the wire format, not the
  domain shape.
- `build.yaml` sets `field_rename: snake`, so `displayName` maps to
  `display_name` without an explicit `@JsonKey`. Only add `@JsonKey` for fields
  that genuinely deviate. This file sits at the **package** root; build_runner
  works per package, so any new package needing JSON needs its own copy.
- **Mapping extensions live in the same file as their DTO**, never in a separate
  `mappers/` directory. Adding a field to a DTO should put the mapping directly
  in view.
- Files are grouped by feature (`src/auth/`, `src/profile/`), with each feature's
  DTOs under a `dto/` directory inside it. Do not collect every DTO into one
  top-level directory — that separates them from the repositories that use them.
- Repository implementations take their dependencies through the constructor.
  **No Riverpod in this package.**
- Name implementations after their backend: `SupabaseAuthRepository`, not
  `AuthRepositoryImpl`. A second implementation should be able to sit beside the
  first.
- Absence is not an error. A lookup that may legitimately find nothing returns
  `Success(null)`, not `Failure(NotFoundException())`.
- This package may depend on backend SDKs; that is its purpose. It may not
  depend on Riverpod, and it must not import anything from `app` or `admin`.
- SDK types (`supabase.User`, `PostgrestException`) appear only inside this
  package. Nothing crossing into `domain` may reference them. The Supabase
  `AuthException` collides in name with the domain's own, so import the SDK
  with a prefix rather than renaming the domain type.

### app / admin

- The only packages that may use Riverpod.
- `lib/providers/repository_providers.dart` is the single place where interfaces
  are bound to implementations. Changing backend should mean editing that
  file alone.
- Feature code lives under `lib/features/<feature>/`, holding that feature's
  providers and screens together.
- `Result` is converted to `AsyncValue` at the provider boundary: rethrow the
  `Failure` and let Riverpod capture it as `AsyncError`. Below that line nothing
  throws; above it, nothing sees `Result`.

## Error handling

- Repositories and use cases return `Result<T>` from `scrutiny_core`. **Do not
  throw across layer boundaries.**
- SDK exceptions (`PostgrestException`, `DioException`, `FirebaseAuthException`)
  are translated into `AppException` subtypes inside the repository
  implementation and must never escape `data`.
- `AppException` is sealed. Adding a subtype will break every exhaustive `switch`
  over it — that is intentional; fix the call sites rather than adding a default
  branch.
- `Result` is a hand-written sealed class, not Freezed. Consume it with pattern
  matching:

  ```dart
  switch (result) {
    case Success(:final value): ...
    case Failure(:final error): ...
  }
  ```

- **Never add a `_` case to a `switch` over sealed types.** Listing every case is
  what makes the analyser report a missing branch when a new subtype appears; a
  wildcard silently renders the wrong thing instead. If the analyser reports
  `unreachable_switch_case`, the wildcard is the mistake — remove it.

## Naming

- Directory names use lowercase_with_underscores throughout — the same
  convention as file names. Multi-word directories are split:
  `use_cases/`, not `usecases/`; `data_sources/`, not `datasources/`;
  `value_objects/`, not `valueobjects/`. Single-word directories stay as
  they are: `entities/`, `repositories/`, `dto/`.
  Established Clean Architecture examples often run these words together;
  Dart convention does not.
- File names follow the primary declaration: `sign_in_with_email.dart` for
  `SignInWithEmail`.
- DTOs carry a `Dto` suffix so they cannot be mistaken for the entity of the same
  name at an import site.

## Language and text

- All identifiers, comments, doc comments and hard-coded strings use **British
  English** spelling: `colour`, `organisation`, `initialise`, `cancelled`,
  `serialise`, `behaviour`. Commit messages too.
- User-facing text in `app/` and `admin/` is to be localised; Korean and any
  other language lives in resource files, never inline. The library is not yet
  chosen — `flutter_localizations` with ARB, or Slang. Until it is, hard-coded
  British English in widgets is acceptable; do not introduce either library
  speculatively.
- `AppException.message` is the one exception: it is British English and not
  localised, being primarily diagnostic. If it must reach a user, map the
  exception type to a localised string at the widget layer — a `switch` over the
  sealed hierarchy keeps that mapping exhaustive.
- Public APIs carry Dartdoc (`///`). Explain why, not what — the signature
  already says what.

## Code generation

Generated files (`*.freezed.dart`, `*.g.dart`) **are committed**, in the same
commit as the source they were generated from. The policy is uniform across the
repository: `app` cannot compile without `domain`'s generated files, so a split
policy would give the drawbacks of both.

After editing any entity, DTO or Riverpod provider:

```bash
(cd packages/domain && dart run build_runner build)
(cd packages/data   && dart run build_runner build)
(cd app             && dart run build_runner build)
```

build_runner operates per package; running it at the root does nothing. Never
hand-write or hand-edit a generated file. The `--delete-conflicting-outputs` flag
was removed in build_runner 3.x — overwriting is now the default. Use
`dart run build_runner clean` when the cache appears stale.

When creating a new Freezed class, **generate before writing any code that reads
its fields.** A mapping extension referring to not-yet-generated getters leaves
the file unresolvable, so the builder skips it and the getters are never
generated. Running `build_runner watch` makes this order happen naturally.

Before committing, confirm sources and generated output agree:

```bash
# from the package you edited
dart run build_runner build && git status --short
```

## Testing

- `core` and `domain` tests run with `dart test`. `data` and `app` need
  `flutter test`, since `data` is a Flutter package.
- Write fakes and stubs by hand. **Do not add `mockito` or `mocktail`** until
  hand-written ones become genuinely burdensome. A fake has working in-memory
  behaviour (`FakeAuthRepository`); a stub returns a fixed value for one test.
- The fakes in `data` double as override targets for provider tests
  (`overrideWithValue`), and are expected to survive the arrival of real
  implementations.
- Tests worth having at this stage: that a use case rejects invalid input
  *without* reaching its repository; that a DTO round-trips snake_case JSON and
  maps onto the right entity.

## Verification

Run from the root after any change:

```bash
flutter pub get
flutter analyze
```

Use `flutter`, not `dart`, since `app` is part of the workspace — `dart pub`
cannot resolve Flutter SDK dependencies.

**Editing `packages/core` or `packages/domain` can break `app` and `admin`
simultaneously.** After changing anything in those packages, check the whole
workspace, not just the package edited.

Boundary checks, which should return nothing but comments:

```bash
# domain and core must be free of SDKs, Flutter and Riverpod
grep -rn "riverpod\|supabase\|firebase\|flutter" packages/domain/lib packages/core/lib
grep -n "flutter\|supabase\|firebase\|riverpod" packages/core/pubspec.yaml packages/domain/pubspec.yaml

# data may use SDKs but not Riverpod
grep -rn "riverpod" packages/data/lib

# no throwing across layer boundaries
grep -rn "throw " packages/*/lib --include="*.dart" \
  --exclude="*.freezed.dart" --exclude="*.g.dart"
```

## Git

- Conventional Commits, in British English: `feat`, `fix`, `refactor`, `chore`,
  `test`, `docs`.
- Scope is the package: `feat(domain):`, `chore(deps):`.
- Trunk-based. Work lands on `main` directly; branches (`feat/`, `fix/`,
  `refactor/`, `spike/`) are for experiments that may be abandoned or work that
  may be interrupted, and merge with `--no-ff`.
- Releases are tags, not branches.

## Environment

- Development happens on both a Mac (M4 Pro) and Windows with Git Bash. Written
  guidance should not assume either platform.
- iOS and macOS builds require the Mac.
- Line endings are normalised by `.gitattributes` (`eol=lf`, except `.bat` and
  `.ps1`). Generated Dart files are marked `linguist-generated` and `-diff` there
  to keep reviews readable.
- Configuration comes from `--dart-define-from-file=config/dev.json`, read
  through `Environment` in `app/lib/config/`. Never add `flutter_dotenv`;
  compile-time constants avoid an initialisation-order dependency and avoid
  bundling a plain-text `.env` as an asset. `config/*.json` is ignored by Git;
  `config/dev.example.json` is committed as the template.
- Only the Supabase publishable key belongs in client configuration. The secret
  key bypasses RLS and must never appear in `app` or `admin`, including the
  admin web build.

## Supabase
- A new table created in SQL needs four things, in order: `create table`,
  `alter table ... enable row level security`, `grant` to `authenticated`,
  then policies. Creating a table through the dashboard adds the grant
  automatically; creating it in SQL does not. A missing grant surfaces as
  Postgres error 42501; a missing policy surfaces as an empty result.

## Working style

- **Report before changing.** When asked to review or verify, list findings with
  file paths and actual values; do not start editing unless asked.
- Prefer the smallest change that satisfies the request. Do not refactor adjacent
  code, rename things, or add abstractions that were not requested.
- Do not introduce a shared `UseCase<Params, T>` interface, a `Result.fold`
  helper, or similar abstractions until there are several concrete cases
  demanding them.
- If a change appears to require breaking one of the architecture rules above,
  stop and say so rather than working around it. The rule is probably right; the
  design may need rethinking.
- Follow the structure of `lib/features/auth/` when adding a new feature.
- Much published Flutter Clean Architecture material predates Dart 3 sealed
  classes and pattern matching, and predates Freezed 3.x. Where it conflicts with
  this document, this document wins.

## Current state

The `User` vertical slice (sign-in → `Account` → `UserProfile` → display name) is
the reference implementation and the pattern new features should copy.

Supabase is wired in via `SupabaseAuthRepository` and
`SupabaseUserProfileRepository`. The fakes remain and are used for tests. The
`profiles` table has RLS enabled with own-row select/insert/update policies;
there is no delete policy, deletion happens by cascade from `auth.users`.

`admin` has not been created.

Not yet set up, and to be introduced only when the work calls for it: l10n and
routing, Melos, CI.
