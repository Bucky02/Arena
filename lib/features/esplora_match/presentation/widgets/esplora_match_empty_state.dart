import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/core/theme/app_constants.dart';
import '../../application/esplora_match_providers.dart';
import '../../domain/filtro_distanza.dart';

class EsploraMatchEmptyState extends ConsumerWidget {
  const EsploraMatchEmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEstesa = ref.watch(filtroDistanzaProvider) == FiltroDistanza.estesa;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.textPrimary.withOpacity(0.04),
              ),
              child: const Icon(
                Icons.radar_rounded,
                size: 60,
                color: AppTheme.textDisabled,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEstesa
                  ? "Nessun match entro ${MatchThresholds.distanzaEstesa.toInt()} km"
                  : "Nessun match qui vicino",
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isEstesa
                  ? "Al momento non ci sono partite aperte nella tua zona estesa. Torna più tardi o crea tu una partita."
                  : "Provando ad ampliare la ricerca potresti trovare qualcosa in più nella zona estesa.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (!isEstesa) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(filtroDistanzaProvider.notifier).state =
                        FiltroDistanza.estesa,
                icon: const Icon(Icons.travel_explore_rounded, size: 18),
                label: const Text("AMPLIA LA RICERCA"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
