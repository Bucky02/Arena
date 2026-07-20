import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_campi/core/models/partita.dart';
import 'package:app_campi/core/services/partita_service.dart';

enum FiltroPartita { complete, aperte }

final partitaServiceProvider = Provider<PartitaService>((ref) {
  return PartitaService();
});

class FiltroPartitaNotifier extends Notifier<FiltroPartita> {
  @override
  FiltroPartita build() => FiltroPartita.complete;

  void impostaFiltro(FiltroPartita nuovoFiltro) {
    state = nuovoFiltro;
  }
}

final filtroPartitaProvider =
    NotifierProvider<FiltroPartitaNotifier, FiltroPartita>(
      FiltroPartitaNotifier.new,
    );

final partiteUtenteProvider = FutureProvider.family<List<Partita>, String>((
  ref,
  idUtente,
) async {
  final service = ref.watch(partitaServiceProvider);
  final tutteLePartite = await service.getPartiteDellUtente(idUtente);
  final adesso = DateTime.now();

  return tutteLePartite.where((partita) {
    final partiInizio = partita.orarioInizio.split(':');
    final oraInizio = int.parse(partiInizio[0]);
    final minInizio = int.parse(partiInizio[1]);

    final partiFine = partita.orarioFine.split(':');
    final oraFine = int.parse(partiFine[0]);
    final minFine = int.parse(partiFine[1]);

    DateTime fineEsatta = DateTime(
      partita.dataPartita.year,
      partita.dataPartita.month,
      partita.dataPartita.day,
      oraFine,
      minFine,
    );

    final minutiInizio = oraInizio * 60 + minInizio;
    final minutiFine = oraFine * 60 + minFine;

    if (minutiFine <= minutiInizio) {
      fineEsatta = fineEsatta.add(const Duration(days: 1));
    }

    return adesso.isBefore(fineEsatta);
  }).toList();
});
