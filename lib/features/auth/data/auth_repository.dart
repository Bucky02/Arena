import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_campi/core/models/utente.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<String> registraProprietario({
    required String email,
    required String password,
    required String nomeProprietario,
    required String pIva,
    required String nomeSocieta,
    required String indirizzo,
    required String telefonoFisso,
    required String cellulare,
    double? latitudine,
    double? longitudine,
    required String pianoScelto,
    required int limiteCampi,
    String? stripeCustomerId,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final User? utenteCreato = res.user;
      if (utenteCreato == null) {
        throw Exception("Errore: Impossibile creare l'account Auth.");
      }

      // CREAZIONE PROFILO UTENTE (Tipo 1 = Gestore)
      await _supabase.from('utenti').insert({
        'id': utenteCreato.id,
        'nome': nomeProprietario.split(' ').first,
        'cognome': nomeProprietario.split(' ').length > 1
            ? nomeProprietario.split(' ').last
            : '',
        'email': email,
        'telefono': cellulare,
        'tipo': 1,
      });

      // CREAZIONE SOCIETÀ
      final societaInserita = await _supabase
          .from('societa')
          .insert({
            'id_utente': utenteCreato.id,
            'p_iva': pIva,
            'nome_societa': nomeSocieta,
            'indirizzo': indirizzo,
            'nome_proprietario': nomeProprietario,
            'telefono': cellulare,
            'cellulare': telefonoFisso,
            'email': email,
            'latitudine': latitudine,
            'longitudine': longitudine,
            'piano_attuale': pianoScelto.toUpperCase(),
            'limite_campi': limiteCampi,
            'status_abbonamento': 'active',
            'stripe_customer_id': stripeCustomerId,
          })
          .select('id')
          .single();

      return societaInserita['id'] as String;
    } on AuthException catch (e) {
      throw Exception('Errore di Autenticazione: ${e.message}');
    } catch (e) {
      throw Exception('Errore di sistema durante la registrazione: $e');
    }
  }

  // REGISTRAZIONE GIOCATORE
  Future<void> registraGiocatore({
    required String email,
    required String password,
    required String nome,
    required String cognome,
    DateTime? dataNascita,
    String? telefono,
    String? indirizzo,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final User? supabaseUser = res.user;
      if (supabaseUser == null) {
        throw Exception("Errore critico: Impossibile generare l'utente Auth.");
      }

      // 2. CREAZIONE PROFILO UTENTE Giocatore
      final nuovoUtente = Utente(
        id: supabaseUser.id,
        nome: nome,
        cognome: cognome,
        email: email,
        dataNascita: dataNascita,
        telefono: telefono,
        indirizzo: indirizzo,
        createdAt: DateTime.now(),
      );

      await _supabase.from('utenti').insert(nuovoUtente.toJson());
    } on AuthException catch (e) {
      throw Exception('Errore di Autenticazione: ${e.message}');
    } catch (e) {
      throw Exception('Errore durante il salvataggio dei dati: $e');
    }
  }
}
