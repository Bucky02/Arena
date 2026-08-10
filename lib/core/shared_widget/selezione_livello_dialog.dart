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
    'descrizione': 'Ritmo alto, ottima tecnica e padronanza del gioco.',
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

  // Se ha già impostato il livello, proseguiamo direttamente
  if (mappaLivelli.containsKey(sport) && mappaLivelli[sport] != null) {
    onCompletato();
    return;
  }

  // Mostra il Bottom Sheet che scivola dal basso
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "Pillola" di trascinamento in stile iOS/Modern UI
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      color: AppTheme.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Seleziona livello (${sport.toUpperCase()})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Serve per bilanciare i match in zona.",
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Lista livelli
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: livelliDisponibili.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = livelliDisponibili[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        Navigator.pop(sheetContext); // Chiude il Bottom Sheet

                        mappaLivelli[sport] = item['titolo'];

                        // Aggiornamento su Supabase
                        await Supabase.instance.client
                            .from('utenti')
                            .update({'livelli_sport': mappaLivelli})
                            .eq('id', userId);

                        onCompletato();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['titolo']!,
                                    style: const TextStyle(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item['descrizione']!,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
