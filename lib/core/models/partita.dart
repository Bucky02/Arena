import 'package:app_campi/core/models/giocatore_partita.dart';

import 'campo.dart';
import 'utente.dart';

class Partita {
  final String id;
  final Campo campo;
  final Utente organizzatore;
  final DateTime dataPartita;
  final String orarioInizio;
  final String orarioFine;

  int numeroGiocatoriPrenotati;
  String statoPartita;
  bool isPublic;

  List<GiocatorePartita> listaGiocatoriIscritti;

  Partita({
    required this.id,
    required this.campo,
    required this.organizzatore,
    required this.dataPartita,
    required this.orarioInizio,
    required this.orarioFine,
    this.numeroGiocatoriPrenotati = 1,
    this.statoPartita = 'aperta',
    this.isPublic = true,
    this.listaGiocatoriIscritti = const [],
  });

  int get postiMancanti => campo.numeroDiGiocatori - numeroGiocatoriPrenotati;

  bool get eCompleta => postiMancanti <= 0 || statoPartita == 'completa';

  double get quotaSingolaGiocatore {
    if (campo.numeroDiGiocatori == 0) return 0.0;
    return campo.prezzo / campo.numeroDiGiocatori;
  }

  factory Partita.fromJson(Map<String, dynamic> json) {
    List<GiocatorePartita> giocatoriParsati = [];

    if (json['giocatori_partita'] != null) {
      final List<dynamic> partecipantiRaw = json['giocatori_partita'];

      giocatoriParsati = partecipantiRaw
          .map((e) => GiocatorePartita.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Partita(
      id: json['id'] as String,
      campo: Campo.fromJson(json['campo'] as Map<String, dynamic>),
      organizzatore: Utente.fromJson(
        json['organizzatore'] as Map<String, dynamic>,
      ),
      dataPartita: DateTime.parse(json['data_partita'] as String),
      orarioInizio: json['orario_inizio'] as String,
      orarioFine: json['orario_fine'] as String,
      numeroGiocatoriPrenotati: json['numero_giocatori_prenotati'] as int? ?? 1,
      statoPartita: json['stato_partita'] as String? ?? 'aperta',
      isPublic: json['is_public'] as bool? ?? true,
      listaGiocatoriIscritti: giocatoriParsati,
    );
  }
}
