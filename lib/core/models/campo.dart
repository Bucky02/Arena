import 'societa.dart';

class Campo {
  final String id;
  final String idSocieta;
  final String nomeCampo;
  final int numeroDiGiocatori;
  final double prezzo;
  final bool coperto;
  final String? fotoUrl;
  final DateTime? createdAt;
  final Societa? societa;

  Campo({
    required this.id,
    required this.idSocieta,
    required this.nomeCampo,
    required this.numeroDiGiocatori,
    required this.prezzo,
    this.coperto = false,
    this.fotoUrl,
    this.createdAt,
    this.societa,
  });

  String get nomeSocieta => societa?.nomeSocieta ?? "Struttura Sportiva";
  String get citta => societa?.citta ?? "Città non specificata";
  String get via => societa?.via ?? "Via non specificata";

  factory Campo.fromJson(Map<String, dynamic> json) {
    return Campo(
      id: json['id'] as String,
      idSocieta: json['id_societa'] as String,
      nomeCampo: json['nome_campo'] as String,
      numeroDiGiocatori: json['numero_di_giocatori'] as int,
      prezzo: (json['prezzo'] as num).toDouble(),
      coperto: json['coperto'] as bool? ?? false,
      fotoUrl: json['foto_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,

      societa: json['societa'] != null
          ? Societa.fromJson(json['societa'] as Map<String, dynamic>)
          : null,
    );
  }
}
