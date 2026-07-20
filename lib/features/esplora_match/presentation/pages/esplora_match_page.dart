import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/core/theme/app_constants.dart';
import 'package:app_campi/core/models/utente.dart';
import 'package:app_campi/core/services/location_provider.dart';
import 'package:app_campi/features/auth/application/auth_provider.dart';
import 'package:app_campi/core/shared_widget/fade_slide_in.dart';
import 'package:app_campi/core/shared_widget/gps_banner.dart';
import '../../application/esplora_match_filter.dart';
import '../../application/esplora_match_providers.dart';
import '../widgets/esplora_match_card.dart';
import '../widgets/esplora_match_empty_state.dart';
import '../widgets/filtro_distanza_chips.dart';

class EsploraMatchPage extends ConsumerWidget {
  const EsploraMatchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchInZonaAsync = ref.watch(matchInZonaProvider);
    final filtro = ref.watch(filtroDistanzaProvider);
    final Utente? utenteLoggato = ref.watch(utenteCorrenteProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: AppSpacing.screenPadding,
                    top: 12,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "ESPLORA MATCH",
                        style: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const FiltroDistanzaChips(),
                const SizedBox(height: 8),
                const GpsBanner(),

                Expanded(
                  child: matchInZonaAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    ),
                    error: (err, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          "Errore: $err",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.statoErrore),
                        ),
                      ),
                    ),
                    data: (partite) {
                      final partiteDaEsplorare = filtraEOrdina(
                        partite,
                        utenteLoggato,
                        filtro,
                      );

                      if (partiteDaEsplorare.isEmpty) {
                        return const EsploraMatchEmptyState();
                      }

                      return RefreshIndicator(
                        color: AppTheme.accent,
                        backgroundColor: AppTheme.cardBg,
                        onRefresh: () async {
                          ref.invalidate(matchInZonaProvider);
                          await ref.read(matchInZonaProvider.future);
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: AppSpacing.screenPadding,
                            right: AppSpacing.screenPadding,
                            bottom: 100,
                          ),
                          itemCount: partiteDaEsplorare.length,
                          itemBuilder: (context, index) {
                            final item = partiteDaEsplorare[index];
                            return FadeSlideIn(
                              delay: index * MatchThresholds.stepDelayLista,
                              child: EsploraMatchCard(
                                item: item,
                                giaIscritto: isGiaIscritto(
                                  item.partita,
                                  utenteLoggato,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
