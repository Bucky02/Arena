import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chiusura_straordinaria.dart';

class ChiusuraStraordinariaRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ChiusuraStraordinaria>> getChiusurePerData(
    String idSocieta,
    DateTime dataTarget,
  ) async {
    try {
      String dataFormattata =
          "${dataTarget.year}-${dataTarget.month.toString().padLeft(2, '0')}-${dataTarget.day.toString().padLeft(2, '0')}";

      final response = await _supabase
          .from('chiusure_straordinarie')
          .select()
          .eq('id_societa', idSocieta)
          .lte('data_inizio', dataFormattata)
          .gte('data_fine', dataFormattata);

      return (response as List)
          .map((json) => ChiusuraStraordinaria.fromJson(json))
          .toList();
    } catch (e) {
      print('Errore DB in getChiusurePerData: $e');
      throw Exception('Impossibile recuperare le chiusure straordinarie.');
    }
  }
}
