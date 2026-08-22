import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/environment.dart';
import 'features/auth/sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    publishableKey: Environment.supabasePublishableKey,
  );
  runApp(const ProviderScope(child: ScrutinyApp()));
}

/// The application root.
class ScrutinyApp extends StatelessWidget {
  /// Creates the application root.
  const ScrutinyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrutiny',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const SignInScreen(),
    );
  }
}
