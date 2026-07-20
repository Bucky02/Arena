import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfiloRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> getDatiSocieta(String idUtente) async {
    return await _client
        .from('societa')
        .select('foto_url, telefono, cellulare, indirizzo')
        .eq('id_utente', idUtente)
        .maybeSingle();
  }

  Future<String> uploadAvatarSocieta({
    required String fileName,
    required Uint8List bytes,
  }) async {
    await _client.storage
        .from('avatar_societa')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('avatar_societa').getPublicUrl(fileName);
  }

  Future<void> updateDatiUtenteBase(
    String idUtente,
    Map<String, dynamic> dati,
  ) async {
    await _client.from('utenti').update(dati).eq('id', idUtente);
  }

  Future<void> updateDatiSocieta(
    String idUtente,
    Map<String, dynamic> dati,
  ) async {
    await _client.from('societa').update(dati).eq('id_utente', idUtente);
  }

  Future<void> updatePassword(String nuovaPassword) async {
    await _client.auth.updateUser(UserAttributes(password: nuovaPassword));
  }
}

final profiloRepositoryProvider = Provider<ProfiloRepository>((ref) {
  return ProfiloRepository();
});
