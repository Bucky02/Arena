import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AbbonamentoState {
  final bool isLoading;
  final String piano;
  final int limite;
  final int campiInseriti;
  final String? stripeCustomerId;

  const AbbonamentoState({
    this.isLoading = true,
    this.piano = 'NESSUNO',
    this.limite = 0,
    this.campiInseriti = 0,
    this.stripeCustomerId,
  });

  AbbonamentoState copyWith({
    bool? isLoading,
    String? piano,
    int? limite,
    int? campiInseriti,
    String? stripeCustomerId,
  }) {
    return AbbonamentoState(
      isLoading: isLoading ?? this.isLoading,
      piano: piano ?? this.piano,
      limite: limite ?? this.limite,
      campiInseriti: campiInseriti ?? this.campiInseriti,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
    );
  }
}

class AbbonamentoNotifier extends Notifier<AbbonamentoState> {
  @override
  AbbonamentoState build() => const AbbonamentoState();

  Future<void> caricaDati(String idSocieta) async {
    state = state.copyWith(isLoading: true);
    try {
      final societa = await Supabase.instance.client
          .from('societa')
          .select('piano_attuale, limite_campi, stripe_customer_id')
          .eq('id', idSocieta)
          .single();

      final campi = await Supabase.instance.client
          .from('campi')
          .select('id')
          .eq('id_societa', idSocieta);

      state = state.copyWith(
        piano: societa['piano_attuale'] ?? 'NESSUNO',
        limite: societa['limite_campi'] ?? 0,
        stripeCustomerId: societa['stripe_customer_id'],
        campiInseriti: (campi as List).length,
        isLoading: false,
      );
    } catch (e) {
      debugPrint("Errore caricamento abbonamento: $e");
      state = state.copyWith(isLoading: false);
    }
  }
}

final abbonamentoProvider =
    NotifierProvider<AbbonamentoNotifier, AbbonamentoState>(
      AbbonamentoNotifier.new,
    );
