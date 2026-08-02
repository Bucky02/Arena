import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_campi/core/theme/app_theme.dart';

final List<Map<String, String>> livelliDisponibili = [
  {
    'titolo': 'Principiante',
    'descrizione': 'Ho appena iniziato o gioco molto raramente.',
  },
  {
    'titolo': 'Amatoriale',
    'descrizione': 'Conosco le regole base e gioco ogni tanto.',
  },
  {
    'titolo': 'Intermedio',
    'descrizione': 'Gioco con continuità e ho una buona visione di gioco.',
  },
  {
    'titolo': 'Avanzato',
    'descrizione': 'Ritmo alto, ottima tecnica e parlo la lingua del calcio.',
  },
  {
    'titolo': 'Esperto / Agonista',
    'descrizione': 'Livello competitivo elevato o tesserato agonista.',
  },
];

Future<void> verificaESelezionaLivello({
  required BuildContext context,
  required String userId,
  required Map<String, dynamic>? livelliSportAttuali,
  required String sport,
  required VoidCallback onCompletato,
}) async {
  Map<String, dynamic> mappaLivelli = Map.from(livelliSportAttuali ?? {});

  // Se l'utente ha GIÀ impostato il livello per questo sport, proseguiamo subito!
  if (mappaLivelli.containsKey(sport) && mappaLivelli[sport] != null) {
    onCompletato();
    return;
  }

  // Se NON lo ha impostato, mostriamo il Dialog elegante
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.sports_soccer, color: AppTheme.accent, size: 36),
            const SizedBox(height: 10),
            Text(
              "Qual è il tuo livello a ${sport.toUpperCase()}?",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Lo chiederemo solo questa volta per bilanciare i match in zona.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: livelliDisponibili.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = livelliDisponibili[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  Navigator.pop(dialogContext); // Chiudi popup

                  // Aggiorna la mappa (pronto per aggiungere Padel/Tennis in futuro)
                  mappaLivelli[sport] = item['titolo'];

                  // Salva su Supabase
                  await Supabase.instance.client
                      .from('utenti')
                      .update({'livelli_sport': mappaLivelli})
                      .eq('id', userId);

                  // Procedi con l'azione (es. naviga alla ricerca centri)
                  onCompletato();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['titolo']!,
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['descrizione']!,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
