import 'package:app_campi/core/models/partita.dart';

/// Contenitore che accoppia la mappa raw proveniente dall'API
/// con il modello già deserializzato, evitando di ripetere il parsing.
class PartitaConDati {
  final Map<String, dynamic> raw;
  final Partita partita;

  const PartitaConDati({required this.raw, required this.partita});
}
