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

  // 🟢 NUOVO CAMPO: Mappa per salvare i livelli dei vari sport (es. {'calcio': 'Intermedio'})
  final Map<String, dynamic>? livelliSport;

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
    this.livelliSport, // 🟢 Aggiunto al costruttore
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

      // 🟢 Lettura da Supabase in modo sicuro
      livelliSport: json['livelli_sport'] != null
          ? Map<String, dynamic>.from(json['livelli_sport'] as Map)
          : null,
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
      if (livelliSport != null)
        'livelli_sport': livelliSport, // 🟢 Aggiunto al salvataggio
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
      if (livelliSport != null)
        'livelli_sport': livelliSport, // 🟢 Aggiunto all'update
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
    Map<String, dynamic>? livelliSport, // 🟢 Aggiunto al copyWith
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
      livelliSport: livelliSport ?? this.livelliSport, // 🟢
    );
  }

  String get nomeCompleto => '$nome $cognome';

  @override
  String toString() =>
      'Utente(id: $id, nome: $nomeCompleto, ruolo: $ruolo, livelliSport: $livelliSport)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Utente && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
