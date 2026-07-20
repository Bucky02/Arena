import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_campi/core/models/utente.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final utenteCorrenteProvider = FutureProvider<Utente?>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  final session = authState.session;

  if (session == null) {
    return null;
  }

  final response = await Supabase.instance.client
      .from('utenti')
      .select()
      .eq('id', session.user.id)
      .single();

  return Utente.fromJson(response);
});
