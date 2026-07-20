class ChiusuraStraordinaria {
  final String id;
  final String idSocieta;
  final DateTime dataInizio;
  final DateTime dataFine;
  final String? orarioInizio;
  final String? orarioFine;

  ChiusuraStraordinaria({
    required this.id,
    required this.idSocieta,
    required this.dataInizio,
    required this.dataFine,
    this.orarioInizio,
    this.orarioFine,
  });

  factory ChiusuraStraordinaria.fromJson(Map<String, dynamic> json) {
    return ChiusuraStraordinaria(
      id: json['id'] as String,
      idSocieta: json['id_societa'] as String,
      dataInizio: DateTime.parse(json['data_inizio'] as String),
      dataFine: DateTime.parse(json['data_fine'] as String),
      orarioInizio: json['orario_inizio'] as String?,
      orarioFine: json['orario_fine'] as String?,
    );
  }
}
