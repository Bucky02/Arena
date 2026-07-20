import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_campi/core/models/societa.dart';
import 'package:app_campi/features/home/data/preferiti_service.dart';
import 'package:app_campi/features/auth/application/auth_provider.dart';

final preferitiServiceProvider = Provider<PreferitiService>((ref) {
  return PreferitiService();
});

class PreferitiNotifier extends AsyncNotifier<List<Societa>> {
  @override
  Future<List<Societa>> build() async {
    final utente = ref.watch(utenteCorrenteProvider).value;
    if (utente == null) return [];

    final service = ref.watch(preferitiServiceProvider);
    return await service.getCentriPreferiti(utente.id);
  }

  Future<void> togglePreferito(Societa societa) async {
    final utente = ref.read(utenteCorrenteProvider).value;
    if (utente == null) return;

    final service = ref.read(preferitiServiceProvider);

    final listaAttuale = state.value ?? [];
    final isPreferito = listaAttuale.any((s) => s.id == societa.id);

    if (isPreferito) {
      state = AsyncValue.data(
        listaAttuale.where((s) => s.id != societa.id).toList(),
      );
    } else {
      state = AsyncValue.data([...listaAttuale, societa]);
    }

    try {
      await service.togglePreferito(
        utente.id,
        societa.id.toString(),
        isPreferito,
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      ref.invalidateSelf();
    }
  }
}

final preferitiProvider =
    AsyncNotifierProvider<PreferitiNotifier, List<Societa>>(
      PreferitiNotifier.new,
    );
