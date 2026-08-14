import 'package:supabase_flutter/supabase_flutter.dart';

class PartitaRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> streamPartiteUtente(String idUtente) {
    return _supabase
        .from('partite')
        .stream(primaryKey: ['id'])
        .order('data_partita', ascending: true)
        .order('orario_inizio', ascending: true)
        .map(
          (partite) =>
              partite.where((p) => p['id_organizzatore'] == idUtente).toList(),
        );
  }

  Future<List<Map<String, dynamic>>> getMatchPubbliciApertiGeolocalizzati({
    required double latUtente,
    required double lonUtente,
    double raggioKm = 30.0,
  }) async {
    try {
      final responseRpc = await _supabase.rpc(
        'get_match_vicini',
        params: {
          'lat_utente': latUtente,
          'lon_utente': lonUtente,
          'raggio_km': raggioKm,
        },
      );

      final List<dynamic> risultatiRaggio = responseRpc;
      if (risultatiRaggio.isEmpty) return [];

      final List<String> idPartite = risultatiRaggio
          .map((e) => e['id_partita'].toString())
          .toList();

      final Map<String, double> mappaDistanze = {
        for (var e in risultatiRaggio)
          e['id_partita'].toString(): (e['distanza_km'] as num).toDouble(),
      };

      final responseCompleta = await _supabase
          .from('partite')
          .select('''
            *,
            campo:campi(*, societa(*)),
            organizzatore:utenti!partite_id_organizzatore_fkey(*),
            giocatori_partita(
              ospiti_extra,
              utenti(*)
            )
          ''')
          .inFilter('id', idPartite);

      final datiFinali = List<Map<String, dynamic>>.from(responseCompleta);

      for (var partita in datiFinali) {
        final id = partita['id'].toString();
        partita['distanza_km'] = mappaDistanze[id] ?? 0.0;
      }

      datiFinali.sort(
        (a, b) =>
            (a['distanza_km'] as double).compareTo(b['distanza_km'] as double),
      );

      return datiFinali;
    } catch (e) {
      throw Exception('Impossibile recuperare i match pubblici in zona.');
    }
  }

  Future<List<Map<String, dynamic>>> getPartiteDatiGrezzi() async {
    try {
      final response = await _supabase
          .from('partite')
          .select('''
            *,
            campo:campi(*, societa(*)),
            organizzatore:utenti!partite_id_organizzatore_fkey(*),
            giocatori_partita(
              ospiti_extra,
              utenti(*)
            )
          ''')
          .order('data_partita', ascending: true)
          .order('orario_inizio', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Impossibile recuperare le partite dal database.');
    }
  }

  Future<int> getOspitiExtraGiocatore(String idPartita, String idUtente) async {
    try {
      final response = await _supabase
          .from('giocatori_partita')
          .select('ospiti_extra')
          .match({'id_partita': idPartita, 'id_utente': idUtente})
          .maybeSingle();

      if (response == null) return 0;
      return response['ospiti_extra'] as int? ?? 0;
    } catch (e) {
      throw Exception('Impossibile recuperare i dati di iscrizione.');
    }
  }

  Future<List<Map<String, dynamic>>> getPartiteAperteNelloSlot({
    required String idCampo,
    required DateTime dataPartita,
    required String orarioInizio,
  }) async {
    try {
      final dataStr = _formatData(dataPartita);

      final response = await _supabase
          .from('partite')
          .select('*')
          .match({
            'id_campo': idCampo,
            'data_partita': dataStr,
            'orario_inizio': orarioInizio,
          })
          .eq('is_public', true)
          .inFilter('stato_partita', ['aperta_a_rischio', 'aperta_protetta']);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception(
        'Impossibile verificare le partite esistenti nello slot.',
      );
    }
  }

  Future<bool> isSlotOccupato(
    String idCampo,
    DateTime data,
    String orario,
  ) async {
    final dataStr = _formatData(data);

    final response = await _supabase
        .from('partite')
        .select('id')
        .match({
          'id_campo': idCampo,
          'data_partita': dataStr,
          'orario_inizio': orario,
        })
        .inFilter('stato_partita', ['completa', 'aperta_protetta'])
        .maybeSingle();

    return response != null;
  }

  Future<Map<String, dynamic>> creaPartitaDinamica(
    Map<String, dynamic> parametri,
  ) async {
    try {
      final response = await _supabase.rpc(
        'gestione_prenotazione_dinamica',
        params: parametri,
      );

      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      return {'id': response.toString(), 'status': 'success'};
    } on PostgrestException catch (e) {
      throw Exception('Errore database: ${e.message}');
    } catch (e) {
      throw Exception('Errore imprevisto durante la creazione: $e');
    }
  }

  Future<void> inserisciGiocatorePartita(
    Map<String, dynamic> datiIscrizione,
  ) async {
    try {
      await _supabase.from('giocatori_partita').insert(datiIscrizione);
    } catch (e) {
      throw Exception('Impossibile iscrivere il giocatore.');
    }
  }

  Future<void> aggiornaNumeroGiocatoriPrenotati(
    String idPartita,
    int nuovoTotale,
  ) async {
    try {
      await _supabase
          .from('partite')
          .update({'numero_giocatori_prenotati': nuovoTotale})
          .eq('id', idPartita);
    } catch (e) {
      throw Exception('Impossibile aggiornare i posti occupati.');
    }
  }

  Future<void> aggiornaStatoPartita(String idPartita, String nuovoStato) async {
    try {
      await _supabase
          .from('partite')
          .update({'stato_partita': nuovoStato})
          .eq('id', idPartita);
    } catch (e) {
      throw Exception('Impossibile aggiornare lo stato della partita.');
    }
  }

  Future<void> aggiornaGiocatoriEStato({
    required String idPartita,
    required int nuovoTotale,
    required String nuovoStato,
  }) async {
    try {
      await _supabase.rpc(
        'aggiorna_giocatori_e_stato',
        params: {
          'p_id_partita': idPartita,
          'p_nuovo_totale': nuovoTotale,
          'p_nuovo_stato': nuovoStato,
        },
      );
    } on PostgrestException catch (e) {
      throw Exception('Errore database aggiornamento atomico: ${e.message}');
    } catch (e) {
      throw Exception('Errore aggiornamento atomico: $e');
    }
  }

  Future<void> completaPartitaEAnnullaSlotRpc({
    required String idPartita,
    required int nuovoTotale,
    required String idCampo,
    required DateTime dataPartita,
    required String orarioInizio,
  }) async {
    try {
      final dataStr = _formatData(dataPartita);
      final orarioFormattato = orarioInizio.length == 5
          ? "$orarioInizio:00"
          : orarioInizio;

      await _supabase.rpc(
        'completa_partita_e_annulla_slot',
        params: {
          'p_id_partita': idPartita,
          'p_nuovo_totale': nuovoTotale,
          'p_id_campo': idCampo,
          'p_data_partita': dataStr,
          'p_orario_inizio': orarioFormattato,
        },
      );
    } on PostgrestException catch (e) {
      throw Exception(
        'Errore nel completamento atomico dello slot: ${e.message}',
      );
    } catch (e) {
      throw Exception('Errore imprevisto nel completamento slot: $e');
    }
  }

  Future<void> annullaAltrePartiteNelloSlot({
    required String idCampo,
    required DateTime dataPartita,
    required String orarioInizio,
    required String idPartitaVincente,
  }) async {
    try {
      final dataStr = _formatData(dataPartita);

      await _supabase
          .from('partite')
          .update({'stato_partita': 'annullata'})
          .match({
            'id_campo': idCampo,
            'data_partita': dataStr,
            'orario_inizio': orarioInizio,
          })
          .neq('id', idPartitaVincente)
          .inFilter('stato_partita', ['aperta_a_rischio', 'aperta_protetta']);
    } catch (e) {
      throw Exception('Impossibile annullare le altre partite concorrenti.');
    }
  }

  Future<void> annullaPartiteARischioNelloSlot({
    required String idCampo,
    required DateTime dataPartita,
    required String orarioInizio,
    required String idPartitaVincente,
  }) async {
    try {
      final dataStr = _formatData(dataPartita);

      await _supabase
          .from('partite')
          .update({'stato_partita': 'annullata'})
          .match({
            'id_campo': idCampo,
            'data_partita': dataStr,
            'orario_inizio': orarioInizio,
          })
          .neq('id', idPartitaVincente)
          .eq('stato_partita', 'aperta_a_rischio');
    } catch (e) {
      throw Exception(
        'Impossibile annullare le partite a rischio concorrenti.',
      );
    }
  }

  Future<void> rimuoviGiocatorePartita(
    String idPartita,
    String idUtente,
  ) async {
    try {
      await _supabase.from('giocatori_partita').delete().match({
        'id_partita': idPartita,
        'id_utente': idUtente,
      });
    } catch (e) {
      throw Exception('Impossibile disiscrivere il giocatore.');
    }
  }

  // 🟢 CORRETTO: Includiamo tutti i campi necessari (* in campi e tariffe_sport)
  Future<List<Map<String, dynamic>>> fetchPrenotazioniGestore(
    String idSocieta,
  ) async {
    try {
      final campiData = await _supabase
          .from('campi')
          .select('id')
          .eq('id_societa', idSocieta);

      if (campiData.isEmpty) return [];

      final List<String> idCampi = campiData
          .map((c) => c['id'] as String)
          .toList();

      final partiteData = await _supabase
          .from('partite')
          .select('''
            *,
            campo:campi(*),
            organizzatore:utenti!partite_id_organizzatore_fkey(
              nome, cognome, email, telefono
            )
          ''')
          .inFilter('id_campo', idCampi);

      return List<Map<String, dynamic>>.from(partiteData);
    } on PostgrestException catch (e) {
      throw Exception('Errore SQL nel recupero prenotazioni: ${e.message}');
    }
  }

  Future<Map<String, Map<String, dynamic>>> getStatoOrariGiorno(
    String idCampo,
    DateTime data,
  ) async {
    final dataStr = _formatData(data);

    final response = await _supabase
        .from('partite')
        .select('orario_inizio, stato_partita')
        .eq('id_campo', idCampo)
        .eq('data_partita', dataStr)
        .neq('stato_partita', 'annullata');

    final List<Map<String, dynamic>> partite = List<Map<String, dynamic>>.from(
      response,
    );
    final Map<String, Map<String, dynamic>> mappaStati = {};

    for (var p in partite) {
      String ora = (p['orario_inizio'] as String).substring(0, 5);
      String stato = p['stato_partita'] as String;

      if (!mappaStati.containsKey(ora)) {
        mappaStati[ora] = {'occupato_fisso': false, 'aperte': 0};
      }

      if (stato == 'completa' || stato == 'aperta_protetta') {
        mappaStati[ora]!['occupato_fisso'] = true;
      } else if (stato == 'aperta_a_rischio') {
        mappaStati[ora]!['aperte'] = (mappaStati[ora]!['aperte'] as int) + 1;
      }
    }

    return mappaStati;
  }

  Future<List<Map<String, dynamic>>> getPartiteUtente(String idUtente) async {
    try {
      final response = await _supabase
          .from('partite')
          .select('''
            *,
            campo:campi(*, societa(*)), 
            organizzatore:utenti!partite_id_organizzatore_fkey(*),
            giocatori_partita!inner(ospiti_extra, utenti(*))
          ''')
          .eq('giocatori_partita.id_utente', idUtente)
          .order('data_partita', ascending: true)
          .order('orario_inizio', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Impossibile recuperare le tue partite.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPartiteCompletatePerGuadagni(
    String idSocieta,
  ) async {
    try {
      final campiData = await _supabase
          .from('campi')
          .select('id')
          .eq('id_societa', idSocieta);

      if (campiData.isEmpty) return [];

      final List<String> idCampi = campiData
          .map((c) => c['id'] as String)
          .toList();

      final response = await _supabase
          .from('partite')
          .select('*, campo:campi(*)')
          .inFilter('id_campo', idCampi)
          .eq('stato_partita', 'completa');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Errore nel calcolo dei guadagni: $e');
    }
  }

  String _formatData(DateTime data) {
    return "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";
  }
}
