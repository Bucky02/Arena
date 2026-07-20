import 'package:flutter/material.dart';
import 'package:app_campi/core/theme/app_theme.dart';

class DettagliPrenotazioneDialog extends StatelessWidget {
  final Map<String, dynamic> partita;

  const DettagliPrenotazioneDialog({super.key, required this.partita});

  @override
  Widget build(BuildContext context) {
    final org = partita['organizzatore'] ?? {};
    final nomeCampo = partita['campo']?['nome_campo'] ?? 'Campo Sconosciuto';
    final orarioInizio =
        partita['orario_inizio']?.toString().substring(0, 5) ?? '--:--';
    final orarioFine =
        partita['orario_fine']?.toString().substring(0, 5) ?? '--:--';

    return AlertDialog(
      backgroundColor: AppTheme.cardBg,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.neonOrange, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        'Dettagli Prenotazione',
        style: TextStyle(
          color: AppTheme.neonOrange,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 30,
            ),
            title: Text(
              nomeCampo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              'Dalle $orarioInizio alle $orarioFine',
              style: const TextStyle(color: AppTheme.neonOrange),
            ),
          ),
          const Divider(color: Colors.grey),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person, color: Colors.grey),
            title: Text(
              '${org['nome'] ?? 'N/D'} ${org['cognome'] ?? ''}',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Organizzatore',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email, color: Colors.grey),
            title: Text(
              org['email'] ?? 'N/D',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.phone, color: Colors.grey),
            title: Text(
              org['telefono'] ?? 'N/D',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Chiudi',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
