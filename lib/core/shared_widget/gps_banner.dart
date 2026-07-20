import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/core/theme/app_constants.dart';
import 'package:app_campi/core/services/location_provider.dart';

class GpsBanner extends ConsumerWidget {
  final bool permessoNegatoPerSempre;

  const GpsBanner({super.key, this.permessoNegatoPerSempre = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpsState = ref.watch(gpsAttivoProvider);

    return gpsState.when(
      data: (isGpsAttivo) {
        if (isGpsAttivo && !permessoNegatoPerSempre) {
          return const SizedBox.shrink();
        }

        final bool problemaPermesso = isGpsAttivo && permessoNegatoPerSempre;

        final String titolo = problemaPermesso
            ? "PERMESSO NEGATO"
            : "GPS DISATTIVATO";
        final String sottotitolo = problemaPermesso
            ? "Consenti l'accesso alla posizione nelle impostazioni per vedere i centri vicino a te."
            : "Attivalo per esplorare i match in zona.";
        final IconData icona = problemaPermesso
            ? Icons.gps_off_rounded
            : Icons.location_off;
        final String etichettaBottone = problemaPermesso
            ? "IMPOSTAZIONI"
            : "ATTIVA";
        final VoidCallback azione = problemaPermesso
            ? () => Geolocator.openAppSettings()
            : () => Geolocator.openLocationSettings();

        return Container(
          margin: const EdgeInsets.only(
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            bottom: 16,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.statoErrore.withOpacity(0.10),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: AppTheme.statoErrore.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.statoErrore.withOpacity(0.16),
                ),
                child: Icon(icona, color: AppTheme.statoErrore, size: 22),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titolo,
                      style: const TextStyle(
                        color: AppTheme.statoErrore,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sottotitolo,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              ElevatedButton(
                onPressed: azione,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.statoErrore,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.chip ?? 10),
                  ),
                ),
                child: Text(
                  etichettaBottone,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
