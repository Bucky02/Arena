import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_campi/core/models/societa.dart';
import 'package:flutter/material.dart';

class SocietaRepository {
  final SupabaseClient _supabase;

  SocietaRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<List<Societa>> cercaSocietaPerNome(String query) async {
    try {
      final response = await _supabase
          .from('societa')
          .select()
          .ilike('nome_societa', '%$query%');

      return (response as List).map((json) => Societa.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Errore in cercaSocietaPerNome: $e");
      return [];
    }
  }

  Future<List<Societa>> cercaSocietaPerCitta(String query) async {
    try {
      final response = await _supabase
          .from('societa')
          .select()
          .ilike('indirizzo', '%$query%');

      return (response as List).map((json) => Societa.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Errore in cercaSocietaPerCitta: $e");
      return [];
    }
  }

  Future<List<Societa>> cercaSocietaGlobale(String query) async {
    try {
      final response = await _supabase
          .from('societa')
          .select()
          .or('nome_societa.ilike.%$query%, indirizzo.ilike.%$query%');

      return (response as List).map((json) => Societa.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Errore in cercaSocietaGlobale: $e");
      return [];
    }
  }

  Future<Societa?> getSocietaById(String idSocieta) async {
    try {
      final response = await _supabase
          .from('societa')
          .select()
          .eq('id', idSocieta)
          .maybeSingle();
      if (response == null) return null;
      return Societa.fromJson(response);
    } catch (e) {
      debugPrint("Errore in getSocietaById: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> cercaSocietaEPrezziPerSport({
    required String sport,
    required int giornoSettimana, // 1 = Lunedì, ..., 7 = Domenica
  }) async {
    try {
      debugPrint("Cerco società per sport: $sport e giorno: $giornoSettimana");

      // Query che estrae i campi e le società che HANNO un orario APERTO per il giorno richiesto
      final response = await _supabase
          .from('campi')
          .select('''
          tariffe_sport, 
          societa!inner(
            *,
            orari_societa!inner(giorno_settimana, is_chiuso)
          )
        ''')
          .filter('tariffe_sport', 'cs', '[{"sport":"$sport"}]')
          .eq('societa.orari_societa.giorno_settimana', giornoSettimana)
          .eq('societa.orari_societa.is_chiuso', false);

      final Map<String, Map<String, dynamic>> mappaRisultati = {};

      for (var row in response) {
        if (row['societa'] != null) {
          final societa = Societa.fromJson(row['societa']);

          // Estraggo il prezzo specifico per questo sport
          double prezzoMinimo = 0.0;
          final List tariffe = row['tariffe_sport'] ?? [];
          for (var t in tariffe) {
            if (t['sport'] == sport) {
              prezzoMinimo = (t['prezzo'] ?? 0.0).toDouble();
              break;
            }
          }

          // Se la società è già presente, tengo il prezzo più conveniente
          if (!mappaRisultati.containsKey(societa.id) ||
              prezzoMinimo <
                  (mappaRisultati[societa.id]!['prezzo'] as double)) {
            mappaRisultati[societa.id] = {
              'societa': societa,
              'prezzo': prezzoMinimo,
            };
          }
        }
      }

      debugPrint(
        "Società aperte e con $sport trovate: ${mappaRisultati.length}",
      );
      return mappaRisultati.values.toList();
    } catch (e) {
      debugPrint("Errore ricerca società con filtri: $e");
      return [];
    }
  }
}
