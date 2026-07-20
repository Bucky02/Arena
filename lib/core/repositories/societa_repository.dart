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
}
