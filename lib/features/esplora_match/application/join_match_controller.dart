import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_campi/core/models/partita.dart';
import 'package:app_campi/core/models/utente.dart';
import 'package:app_campi/core/services/partita_service.dart';

class JoinMatchController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<String?> unisciti(Partita partita, Utente utente, int ospiti) async {
    state = const AsyncLoading();

    final errore = await PartitaService().uniscitiAPartita(
      partita: partita,
      nuovoGiocatore: utente,
      ospitiExtra: ospiti,
    );

    state = const AsyncData(null);
    return errore;
  }
}

final joinMatchControllerProvider =
    AsyncNotifierProvider<JoinMatchController, void>(
      () => JoinMatchController(),
    );
