import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scrutiny_core/scrutiny_core.dart';
import 'package:scrutiny_domain/scrutiny_domain.dart';
import 'package:scrutiny_data/scrutiny_data.dart';

import 'package:scrutiny_app/providers/repository_providers.dart';
import 'package:scrutiny_app/features/auth/auth_providers.dart';

void main() {
  group('authStateProvider', () {
    late FakeAuthRepository authRepository;
    late ProviderContainer container;

    setUp(() {
      authRepository = FakeAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      authRepository.dispose();
    });

    // `authStateProvider` is autoDispose, so each test opens its own
    // listener to keep the provider chain alive while `.future` is awaited —
    // without one, it can be disposed before the stream emits a value.

    test('is Unauthenticated before anyone signs in', () async {
      final subscription = container.listen(authStateProvider, (_, _) {});
      addTearDown(subscription.close);

      final state = await container.read(authStateProvider.future);

      expect(state, isA<Unauthenticated>());
    });

    test('is Authenticated once the repository reports a signed-in account', () async {
      final signIn = await authRepository.signInWithEmail(
        const Email('driver@example.com'),
        'password',
      );
      expect(signIn, isA<Success<Account>>());

      // Subscribed only now, after signing in: `FakeAuthRepository` replays
      // the present account to a new subscriber, so this reads the signed-in
      // state directly instead of racing a stream event.
      final subscription = container.listen(authStateProvider, (_, _) {});
      addTearDown(subscription.close);

      final state = await container.read(authStateProvider.future);

      expect(state, isA<Authenticated>());
      expect(
        (state as Authenticated).account.email,
        const Email('driver@example.com'),
      );
    });
  });
}
