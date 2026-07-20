import 'package:app_campi/core/models/campo.dart';
import 'package:app_campi/core/services/partita_service.dart';
import 'package:app_campi/core/models/societa.dart';

class CreazionePartitaState {
  final bool isLoading;
  final List<Societa> societaTrovate;
  final List<Campo> campiTrovati;
  final Campo? campoSelezionato;
  final DateTime dataSelezionata;
  final List<String> orariDisponibili;
  final List<String> orariOccupati;
  final List<String> orariChiusi;
  final List<DateTime> giorniChiusi;
  final Map<String, int> partiteApertePerSlot;
  final String? oraInizioSelezionata;
  final int ospitiExtra;
  final bool isPartitaPrivata;

  CreazionePartitaState({
    this.isLoading = false,
    this.societaTrovate = const [],
    this.campiTrovati = const [],
    this.campoSelezionato,
    required this.dataSelezionata,
    this.orariDisponibili = const [],
    this.orariOccupati = const [],
    this.orariChiusi = const [],
    this.giorniChiusi = const [],
    this.partiteApertePerSlot = const {},
    this.oraInizioSelezionata,
    this.ospitiExtra = 0,
    this.isPartitaPrivata = false,
  });

  CreazionePartitaState copyWith({
    bool? isLoading,
    List<Societa>? societaTrovate,
    List<Campo>? campiTrovati,
    Campo? campoSelezionato,
    DateTime? dataSelezionata,
    List<String>? orariDisponibili,
    List<String>? orariOccupati,
    List<String>? orariChiusi,
    List<DateTime>? giorniChiusi,
    Map<String, int>? partiteApertePerSlot,
    String? oraInizioSelezionata,
    int? ospitiExtra,
    bool? isPartitaPrivata,
    bool clearCampo = false,
    bool clearOrario = false,
  }) {
    return CreazionePartitaState(
      isLoading: isLoading ?? this.isLoading,
      societaTrovate: societaTrovate ?? this.societaTrovate,
      campiTrovati: campiTrovati ?? this.campiTrovati,
      campoSelezionato: clearCampo
          ? null
          : (campoSelezionato ?? this.campoSelezionato),
      dataSelezionata: dataSelezionata ?? this.dataSelezionata,
      orariDisponibili: orariDisponibili ?? this.orariDisponibili,
      orariOccupati: orariOccupati ?? this.orariOccupati,
      orariChiusi: orariChiusi ?? this.orariChiusi,
      giorniChiusi: giorniChiusi ?? this.giorniChiusi,
      partiteApertePerSlot: partiteApertePerSlot ?? this.partiteApertePerSlot,
      oraInizioSelezionata: clearOrario
          ? null
          : (oraInizioSelezionata ?? this.oraInizioSelezionata),
      ospitiExtra: ospitiExtra ?? this.ospitiExtra,
      isPartitaPrivata: isPartitaPrivata ?? this.isPartitaPrivata,
    );
  }

  int get giocatoriTotali => 1 + ospitiExtra;

  bool get isPrimeTime {
    if (oraInizioSelezionata == null) return false;
    int ora = int.parse(oraInizioSelezionata!.split(':')[0]);
    return ora >= 18 && ora <= 22;
  }

  int get minRichiesti => campoSelezionato == null
      ? 0
      : PartitaService().getMinimoApertura(
          campoSelezionato!.numeroDiGiocatori,
          isPrimeTime,
        );

  int get sogliaProtetta => campoSelezionato == null
      ? 0
      : PartitaService().getSogliaProtezione(
          campoSelezionato!.numeroDiGiocatori,
        );
}
