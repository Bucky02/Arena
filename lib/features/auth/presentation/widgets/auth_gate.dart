import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_campi/features/auth/application/auth_provider.dart';
import 'package:app_campi/features/admin/presentation/pages/dashboard_gestore_page.dart';
import 'package:app_campi/features/home/presentation/home_page.dart';
import 'package:app_campi/features/home/presentation/views/onboarding_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final utenteAsync = ref.watch(utenteCorrenteProvider);

    return utenteAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const OnboardingScreen(),
      data: (utente) {
        if (utente == null) {
          return const OnboardingScreen();
        }
        if (utente.isGestore) {
          return DashboardGestore.fromLogin(utenteLoggato: utente);
        }
        return const HomePage();
      },
    );
  }
}
