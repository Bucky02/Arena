class OrarioSocieta {
  final String id;
  final String idSocieta;
  final int giornoSettimana;
  final String? orarioApertura;
  final String? orarioChiusura;
  final String? orarioApertura2;
  final String? orarioChiusura2;
  final bool isChiuso;

  OrarioSocieta({
    required this.id,
    required this.idSocieta,
    required this.giornoSettimana,
    this.orarioApertura,
    this.orarioChiusura,
    this.orarioApertura2,
    this.orarioChiusura2,
    this.isChiuso = false,
  });

  factory OrarioSocieta.fromJson(Map<String, dynamic> json) {
    return OrarioSocieta(
      id: json['id'] as String,
      idSocieta: json['id_societa'] as String,
      giornoSettimana: json['giorno_settimana'] as int,
      orarioApertura: json['orario_apertura'] as String?,
      orarioChiusura: json['orario_chiusura'] as String?,
      orarioApertura2: json['orario_apertura_2'] as String?,
      orarioChiusura2: json['orario_chiusura_2'] as String?,
      isChiuso: json['is_chiuso'] as bool? ?? false,
    );
  }
}
