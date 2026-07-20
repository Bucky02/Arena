class Societa {
  final String id;
  final String pIva;
  final String nomeSocieta;
  final String indirizzo;
  final String? nomeProprietario;
  final String telefono;
  final String? cellulare;
  final String email;
  final DateTime? createdAt;
  final String? idUtente;
  final double? latitudine;
  final double? longitudine;
  final String? fotoUrl;
  final int limiteCampi;

  Societa({
    required this.id,
    required this.pIva,
    required this.nomeSocieta,
    required this.indirizzo,
    this.nomeProprietario,
    required this.telefono,
    this.cellulare,
    required this.email,
    this.createdAt,
    this.idUtente,
    this.latitudine,
    this.longitudine,
    this.fotoUrl,
    required this.limiteCampi,
  });

  factory Societa.fromJson(Map<String, dynamic> json) {
    return Societa(
      id: json['id'] as String,
      pIva: json['p_iva'] as String,
      nomeSocieta: json['nome_societa'] as String,
      indirizzo: json['indirizzo'] as String,
      nomeProprietario: json['nome_proprietario'] as String?,
      telefono: json['telefono'] as String,
      cellulare: json['cellulare'] as String?,
      email: json['email'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      idUtente: json['id_utente'] as String?,
      latitudine: json['latitudine'] != null
          ? (json['latitudine'] as num).toDouble()
          : null,
      longitudine: json['longitudine'] != null
          ? (json['longitudine'] as num).toDouble()
          : null,
      fotoUrl: json['foto_url'] as String?,
      limiteCampi: json['limite_campi'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'p_iva': pIva,
      'nome_societa': nomeSocieta,
      'indirizzo': indirizzo,
      'nome_proprietario': nomeProprietario,
      'telefono': telefono,
      'cellulare': cellulare,
      'email': email,
      'id_utente': idUtente,
      'latitudine': latitudine,
      'longitudine': longitudine,
      'foto_url': fotoUrl,
      'limite_campi': limiteCampi,
    };
  }

  String get citta {
    if (indirizzo.isEmpty) return "Città non specificata";

    final parti = indirizzo.split(',');
    if (parti.length >= 2) {
      final comune = parti[parti.length - 2].trim();
      final provincia = parti[parti.length - 1].trim();
      return "$comune, $provincia";
    }
    return indirizzo;
  }

  String get via {
    if (indirizzo.isEmpty) return "Via non specificata";
    final parti = indirizzo.split(',');
    if (parti.length > 1) {
      return parti.first.trim();
    }
    return indirizzo;
  }
}
