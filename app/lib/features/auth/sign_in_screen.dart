import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scrutiny_core/scrutiny_core.dart';
import 'package:scrutiny_domain/scrutiny_domain.dart';

import '../../providers/repository_providers.dart';
import 'auth_providers.dart';

/// Signs a user in, and once signed in shows their name.
///
/// The interface is deliberately minimal. The purpose of this screen is to
/// prove that a request travels from a widget through a use case to
/// a repository and back, not to look presentable.
class SignInScreen extends ConsumerWidget {
  /// Creates the sign-in screen.
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Failures are announced through a listener rather than rendered,
    // so that a rejected attempt leaves the form on screen with
    // its input intact.
    ref.listen(signInControllerProvider, (_, next) {
      if (next case AsyncError(:final error) when error is AppException) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    });

    final auth = ref.watch(authStateProvider);

    return Scaffold(
      body: Center(
        // Two sealed types are matched at once here: `AsyncValue` for
        // the progress of the load, `AuthState` for its result.
        child: switch (auth) {
          AsyncLoading() => const CircularProgressIndicator(),
          AsyncError(:final error) => Text('$error'),
          AsyncData(value: Unauthenticated()) => const _SignInForm(),
          AsyncData(value: Authenticated(:final account, :final profile)) =>
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // A null profile means no row exists yet; a real app would
                // route to onboarding at this point.
                Text(
                  profile?.displayName ?? 'No profile',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(account.email?.value ?? ''),
                TextButton(
                  // Provisional: reaching for the repository from a widget
                  // bypasses the domain.
                  // Replace with a `SignOut` use case
                  // once the slice is confirmed.
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  child: const Text('Logout'),
                ),
              ],
            ),
        },
      ),
    );
  }
}

/// Collects an email address and password.
///
/// Stateful because the controllers must be disposed. Kept private:
/// it has no meaning outside this screen.
class _SignInForm extends ConsumerStatefulWidget {
  const _SignInForm();

  @override
  ConsumerState<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<_SignInForm> {
  // Pre-filled to match what MockAuthRepository accepts, saving a good deal of
  // typing during development. Clear these before the real backend is wired in.
  final _email = TextEditingController(text: 'test@example.com');
  final _password = TextEditingController(text: 'password');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signInControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _email),
          TextField(controller: _password, obscureText: true),
          const SizedBox(height: 16),
          FilledButton(
            // Disabled mid-request, so a second attempt cannot be started
            // before the first has settled.
            onPressed: state.isLoading
                ? null
                : () => ref
                      .read(signInControllerProvider.notifier)
                      .signIn(_email.text, _password.text),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
