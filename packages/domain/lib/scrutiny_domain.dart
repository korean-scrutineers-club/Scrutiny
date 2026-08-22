/// Entities, repository interfaces and use cases — the business rules,
/// stated independently of storage, transport and interface.
///
/// Depends only on `scrutiny_core` and `freezed_annotation`,
/// both of which are pure Dart.
/// Adding an SDK dependency to this package would defeat its purpose.
library;

// Authentication
export 'src/entities/account.dart';
export 'src/entities/auth_state.dart';
export 'src/repositories/auth_repository.dart';
export 'src/use_cases/sign_in_with_email.dart';

// Profile
export 'src/entities/user_profile.dart';
export 'src/repositories/user_profile_repository.dart';
