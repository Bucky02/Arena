import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_campi/core/models/campo.dart';
import 'package:app_campi/core/models/utente.dart';
import 'package:app_campi/core/models/societa.dart';
import 'package:app_campi/core/repositories/campi_repository.dart';
import 'package:app_campi/core/repositories/orario_societa_repository.dart';
import 'package:app_campi/core/repositories/partita_repository.dart';
import 'package:app_campi/core/services/partita_service.dart';
import 'package:app_campi/features/prenotazione/application/creazione_partita_state.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/core/repositories/chiusura_straordinaria_repository.dart';
import 'package:app_campi/core/models/orario_societa.dart';
import 'package:app_campi/core/repositories/societa_repository.dart';

enum TipoRicerca { tutti, societa, citta }

final creazionePartitaProvider =
    NotifierProvider<CreazionePartitaController, CreazionePartitaState>(
      CreazionePartitaController.new,
    );

class CreazionePartitaController extends Notifier<CreazionePartitaState> {
  final _campiRepo = CampiRepository();
  final _societaRepo = SocietaRepository();
  final _orarioRepo = OrarioSocietaRepository();
  final _partitaRepo = PartitaRepository();
  final _partitaService = PartitaService();
  final _chiusuraRepo = ChiusuraStraordinariaRepository();

  TipoRicerca filtroCorrente = TipoRicerca.tutti;

  @override
  CreazionePartitaState build() {
    return CreazionePartitaState(dataSelezionata: DateTime.now());
  }

  void impostaFiltroRicerca(TipoRicerca filtro) {
    filtroCorrente = filtro;
  }

  Future<void> cercaSocieta(String queryText) async {
    if (queryText.isEmpty) return;
    state = state.copyWith(isLoading: true, societaTrovate: []);

    try {
      List<Societa> risultati = [];
      if (filtroCorrente == TipoRicerca.societa) {
        risultati = await _societaRepo.cercaSocietaPerNome(queryText);
      } else if (filtroCorrente == TipoRicerca.citta) {
        risultati = await _societaRepo.cercaSocietaPerCitta(queryText);
      } else {
        risultati = await _societaRepo.cercaSocietaGlobale(queryText);
      }

      final Map<String, Societa> mappaUnivoca = {
        for (var s in risultati) s.id: s,
      };

      state = state.copyWith(
        isLoading: false,
        societaTrovate: mappaUnivoca.values.toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint("Errore ricerca società: $e");
    }
  }

  Future<void> caricaCampiSocieta(String idSocieta) async {
    state = state.copyWith(isLoading: true, campiTrovati: []);
    try {
      final campi = await _campiRepo.getCampiSocietaConDettagli(idSocieta);
      final societa = await _societaRepo.getSocietaById(idSocieta);
      final int limiteCampi = societa?.limiteCampi ?? campi.length;
      final campiAttivi = campi.take(limiteCampi).toList();
      state = state.copyWith(isLoading: false, campiTrovati: campiAttivi);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint("Errore caricamento campi: $e");
    }
  }

  void selezionaCampo(Campo? campo) {
    state = state.copyWith(
      campoSelezionato: campo,
      clearCampo: campo == null,
      ospitiExtra: 0,
      clearOrario: true,
      giorniChiusi: [],
    );
    if (campo != null) {
      _inizializzaCalendario(campo.idSocieta);
      caricaOrari(state.dataSelezionata);
    }
  }

  Future<void> _inizializzaCalendario(String idSocieta) async {
    List<DateTime> chiusi = [];
    Map<int, bool> cacheSettimanale = {};

    await Future.wait(
      List.generate(14, (i) async {
        final data = DateTime.now().add(Duration(days: i));
        final weekday = data.weekday;

        if (!cacheSettimanale.containsKey(weekday)) {
          final orario = await _orarioRepo.getOrarioGiorno(idSocieta, weekday);
          cacheSettimanale[weekday] = (orario == null || orario.isChiuso);
        }

        if (cacheSettimanale[weekday] == true) {
          chiusi.add(data);
        } else {
          final chiusureStr = await _chiusuraRepo.getChiusurePerData(
            idSocieta,
            data,
          );
          if (chiusureStr.any(
            (c) => c.orarioInizio == null && c.orarioFine == null,
          )) {
            chiusi.add(data);
          }
        }
      }),
    );

    state = state.copyWith(giorniChiusi: chiusi);
  }

  void resetConfigurazione() => selezionaCampo(null);

  void svuotaTutto() =>
      state = CreazionePartitaState(dataSelezionata: DateTime.now());

  Future<void> caricaOrari(DateTime data) async {
    if (state.campoSelezionato == null) return;
    state = state.copyWith(
      isLoading: true,
      dataSelezionata: data,
      clearOrario: true,
    );

    try {
      final orari = await _orarioRepo.getOrarioGiorno(
        state.campoSelezionato!.idSocieta,
        data.weekday,
      );

      final statiOrari = await _partitaRepo.getStatoOrariGiorno(
        state.campoSelezionato!.id,
        data,
      );

      final chiusure = await _chiusuraRepo.getChiusurePerData(
        state.campoSelezionato!.idSocieta,
        data,
      );

      if (orari != null && !orari.isChiuso) {
        final slots = _generaSlotDoppioTurno(orari);

        List<String> slotChiusi = [];
        List<String> slotOccupati = [];
        Map<String, int> apertePerSlot = {};

        for (var slot in slots) {
          int minSlot = _orarioInMinuti(slot);
          bool isChiuso = false;

          for (var c in chiusure) {
            if (c.orarioInizio == null ||
                c.orarioFine == null ||
                (minSlot >= _orarioInMinuti(c.orarioInizio!) &&
                    minSlot < _orarioInMinuti(c.orarioFine!))) {
              slotChiusi.add(slot);
              isChiuso = true;
              break;
            }
          }

          if (!isChiuso) {
            final info = statiOrari[slot];
            if (info != null) {
              bool fisso = info['occupato_fisso'] as bool;
              int aperte = info['aperte'] as int;

              if (fisso) {
                slotOccupati.add(slot);
              } else if (aperte > 0) {
                apertePerSlot[slot] = aperte;
              }
            }
          }
        }

        final firstAvailable = slots.firstWhere(
          (s) => !slotChiusi.contains(s) && !slotOccupati.contains(s),
          orElse: () => '',
        );

        state = state.copyWith(
          orariDisponibili: slots,
          orariOccupati: slotOccupati,
          orariChiusi: slotChiusi,
          partiteApertePerSlot: apertePerSlot,
          oraInizioSelezionata: firstAvailable.isNotEmpty
              ? firstAvailable
              : null,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          orariDisponibili: [],
          orariChiusi: [],
          orariOccupati: [],
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint("Errore orari: $e");
    }
  }

  void aggiornaOrario(String? orario) =>
      state = state.copyWith(oraInizioSelezionata: orario);

  void aggiornaOspiti(int ospiti) =>
      state = state.copyWith(ospitiExtra: ospiti);

  void aggiornaTipoPartita(bool isPrivata) =>
      state = state.copyWith(isPartitaPrivata: isPrivata);

  Future<void> confermaMatch(Utente organizzatore) async {
    if (state.oraInizioSelezionata == null || state.campoSelezionato == null) {
      return;
    }
    state = state.copyWith(isLoading: true);

    try {
      int ospitiFinali = state.isPartitaPrivata
          ? (state.campoSelezionato!.numeroDiGiocatori - 1)
          : state.ospitiExtra;

      final errore = await _partitaService.creaNuovaPartita(
        campo: state.campoSelezionato!,
        organizzatore: organizzatore,
        dataPartita: state.dataSelezionata,
        orarioInizio: "${state.oraInizioSelezionata}:00",
        orarioFine: _calcolaOrarioFine(state.oraInizioSelezionata!),
        ospitiExtra: ospitiFinali,
        isPartitaPrivata: state.isPartitaPrivata,
      );

      if (errore != null) {
        String msg = errore;
        if (errore == 'SLOT_OCCUPATO_PARTITA_PROTETTA') {
          msg =
              "Impossibile prenotare: è già presente una partita protetta in questo orario.";
        } else if (errore == 'SLOT_GIA_OCCUPATO') {
          msg = "Questo slot è già occupato da una partita completa.";
        }
        throw Exception(msg);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  bool isMenoDi24h() {
    if (state.oraInizioSelezionata == null) return false;

    final parti = state.oraInizioSelezionata!.split(':');
    final inizioPartita = DateTime(
      state.dataSelezionata.year,
      state.dataSelezionata.month,
      state.dataSelezionata.day,
      int.parse(parti[0]),
      int.parse(parti[1]),
    );

    return DateTime.now().isAfter(
      inizioPartita.subtract(
        const Duration(hours: PartitaService.orePerditaProtezioneFissa),
      ),
    );
  }

  bool isNumeroGiocatoriValido() {
    if (state.isPartitaPrivata) return true;
    final max = state.campoSelezionato?.numeroDiGiocatori ?? 0;
    final attuali = state.ospitiExtra + 1;
    final oraInizio =
        int.tryParse(state.oraInizioSelezionata?.split(':').first ?? '0') ?? 0;
    bool isPrimeTime =
        oraInizio >= PartitaService.primeTimeInizio &&
        oraInizio <= PartitaService.primeTimeFine;
    return attuali >= _partitaService.getMinimoApertura(max, isPrimeTime);
  }

  String getInfoStatoPartita() {
    if (state.isPartitaPrivata) return "PARTITA PRIVATA (COMPLETA)";

    final max = state.campoSelezionato?.numeroDiGiocatori ?? 0;
    final attuali = state.ospitiExtra + 1;

    if (attuali >= max) return "PARTITA AL COMPLETO";

    final minRichiesti = _partitaService.getMinimoApertura(max, _isPrimeTime());
    final sogliaProtezione = _partitaService.getSogliaProtezione(max);

    if (attuali < minRichiesti) return "POCHI GIOCATORI";
    if (attuali < sogliaProtezione || isMenoDi24h()) return "PARTITA A RISCHIO";
    return "PARTITA PROTETTA";
  }

  Color getColoreStato() {
    if (state.isPartitaPrivata) return AppTheme.neonOrange;

    final max = state.campoSelezionato?.numeroDiGiocatori ?? 0;
    final attuali = state.ospitiExtra + 1;

    if (attuali >= max) return AppTheme.neonOrange;

    final minRichiesti = _partitaService.getMinimoApertura(max, _isPrimeTime());
    final sogliaProtezione = _partitaService.getSogliaProtezione(max);

    if (attuali < minRichiesti) return Colors.orange;
    if (attuali < sogliaProtezione || isMenoDi24h()) return Colors.redAccent;
    return AppTheme.neonGreen;
  }

  bool _isPrimeTime() {
    final oraInizio =
        int.tryParse(state.oraInizioSelezionata?.split(':').first ?? '0') ?? 0;
    return oraInizio >= PartitaService.primeTimeInizio &&
        oraInizio <= PartitaService.primeTimeFine;
  }

  List<String> _generaSlotDoppioTurno(OrarioSocieta orari) {
    List<String> slotsValidi = [];

    if (orari.orarioApertura != null && orari.orarioChiusura != null) {
      int minAttuale = _orarioInMinuti(orari.orarioApertura!);
      int minLimite = _orarioInMinuti(orari.orarioChiusura!);

      while (minAttuale + 60 <= minLimite) {
        slotsValidi.add(
          "${(minAttuale ~/ 60 % 24).toString().padLeft(2, '0')}:${(minAttuale % 60).toString().padLeft(2, '0')}",
        );
        minAttuale += 60;
      }
    }

    if (orari.orarioApertura2 != null && orari.orarioChiusura2 != null) {
      int minAttuale2 = _orarioInMinuti(orari.orarioApertura2!);
      int minLimite2 = _orarioInMinuti(orari.orarioChiusura2!);

      while (minAttuale2 + 60 <= minLimite2) {
        String slot =
            "${(minAttuale2 ~/ 60 % 24).toString().padLeft(2, '0')}:${(minAttuale2 % 60).toString().padLeft(2, '0')}";
        if (!slotsValidi.contains(slot)) {
          slotsValidi.add(slot);
        }
        minAttuale2 += 60;
      }
    }

    slotsValidi.sort(
      (a, b) => _orarioInMinuti(a).compareTo(_orarioInMinuti(b)),
    );

    return slotsValidi;
  }

  int _orarioInMinuti(String orario) {
    List<String> parti = orario.trim().split(':');
    return (int.parse(parti[0]) * 60) + int.parse(parti[1]);
  }

  String _calcolaOrarioFine(String oraInizio) {
    int totalMinutes = _orarioInMinuti(oraInizio) + 60;
    return "${(totalMinutes ~/ 60 % 24).toString().padLeft(2, '0')}:${(totalMinutes % 60).toString().padLeft(2, '0')}:00";
  }
}
