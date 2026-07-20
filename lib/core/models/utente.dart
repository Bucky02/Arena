enum Ruolo { giocatore, gestore }

class Utente {
  final String id;
  final String nome;
  final String cognome;
  final DateTime? dataNascita;
  final String email;
  final String? telefono;
  final String? indirizzo;
  final DateTime? createdAt;
  final Ruolo ruolo;

  Utente({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.email,
    this.dataNascita,
    this.telefono,
    this.indirizzo,
    this.createdAt,
    this.ruolo = Ruolo.giocatore,
  });

  bool get isGestore => ruolo == Ruolo.gestore;
  bool get isGiocatore => ruolo == Ruolo.giocatore;

  /// Età calcolata da [dataNascita]. Null se la data di nascita non è nota.
  int? get eta {
    if (dataNascita == null) return null;
    final oggi = DateTime.now();
    int anni = oggi.year - dataNascita!.year;
    final compleannoNonAncoraArrivato =
        oggi.month < dataNascita!.month ||
        (oggi.month == dataNascita!.month && oggi.day < dataNascita!.day);
    if (compleannoNonAncoraArrivato) anni--;
    return anni;
  }

  factory Utente.fromJson(Map<String, dynamic> json) {
    return Utente(
      id: json['id'] as String,
      nome: json['nome'] as String,
      cognome: json['cognome'] as String,
      email: json['email'] as String,

      dataNascita: json['data_nascita'] != null
          ? DateTime.parse(json['data_nascita'] as String)
          : null,

      telefono: json['telefono'] as String?,
      indirizzo: json['indirizzo'] as String?,

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,

      ruolo: switch (json['tipo'] as int?) {
        1 => Ruolo.gestore,
        0 => Ruolo.giocatore,
        null => Ruolo.giocatore,
        _ => Ruolo.giocatore,
      },
    );
  }

  /// Non include [createdAt]
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cognome': cognome,
      'email': email,
      if (dataNascita != null)
        'data_nascita': dataNascita!.toIso8601String().split('T').first,
      if (telefono != null) 'telefono': telefono,
      if (indirizzo != null) 'indirizzo': indirizzo,
      'tipo': ruolo == Ruolo.gestore ? 1 : 0,
    };
  }

  Map<String, dynamic> toJsonUpdate() {
    return {
      'nome': nome,
      'cognome': cognome,
      if (dataNascita != null)
        'data_nascita': dataNascita!.toIso8601String().split('T').first,
      if (telefono != null) 'telefono': telefono,
      if (indirizzo != null) 'indirizzo': indirizzo,
    };
  }

  Utente copyWith({
    String? nome,
    String? cognome,
    DateTime? dataNascita,
    String? email,
    String? telefono,
    String? indirizzo,
    Ruolo? ruolo,
  }) {
    return Utente(
      id: id,
      nome: nome ?? this.nome,
      cognome: cognome ?? this.cognome,
      email: email ?? this.email,
      dataNascita: dataNascita ?? this.dataNascita,
      telefono: telefono ?? this.telefono,
      indirizzo: indirizzo ?? this.indirizzo,
      createdAt: createdAt,
      ruolo: ruolo ?? this.ruolo,
    );
  }

  String get nomeCompleto => '$nome $cognome';

  @override
  String toString() => 'Utente(id: $id, nome: $nomeCompleto, ruolo: $ruolo)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Utente && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
