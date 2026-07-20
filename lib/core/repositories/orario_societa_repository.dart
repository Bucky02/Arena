import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/orario_societa.dart';

class OrarioSocietaRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// [giornoSettimana] va da 1 (Lunedì) a 7 (Domenica).
  Future<OrarioSocieta?> getOrarioGiorno(
    String idSocieta,
    int giornoSettimana,
  ) async {
    try {
      final response = await _supabase
          .from('orari_societa')
          .select()
          .eq('id_societa', idSocieta)
          .eq('giorno_settimana', giornoSettimana)
          .maybeSingle();

      if (response == null) return null;
      return OrarioSocieta.fromJson(response);
    } catch (e) {
      print('Errore DB in getOrarioGiorno: $e');
      throw Exception(
        'Impossibile recuperare gli orari standard del centro sportivo.',
      );
    }
  }
}
