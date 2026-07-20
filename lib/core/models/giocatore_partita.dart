class GiocatorePartita {
  final String idPartita;
  final String idUtente;
  final int ospitiExtra;

  final String? nomeGiocatore;
  final String? cognomeGiocatore;

  GiocatorePartita({
    required this.idPartita,
    required this.idUtente,
    this.ospitiExtra = 0,
    this.nomeGiocatore,
    this.cognomeGiocatore,
  });

  factory GiocatorePartita.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? datiUtente =
        json['utenti'] as Map<String, dynamic>?;

    return GiocatorePartita(
      idPartita: json['id_partita']?.toString() ?? '',

      idUtente: (datiUtente != null && datiUtente.containsKey('id'))
          ? datiUtente['id'].toString()
          : (json['id_utente']?.toString() ?? ''),

      ospitiExtra: json['ospiti_extra'] as int? ?? 0,

      nomeGiocatore: datiUtente?['nome'] as String?,
      cognomeGiocatore: datiUtente?['cognome'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_partita': idPartita,
      'id_utente': idUtente,
      'ospiti_extra': ospitiExtra,
    };
  }
}
