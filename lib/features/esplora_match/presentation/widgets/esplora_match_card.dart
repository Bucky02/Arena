import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/core/shared_widget/status_badge.dart';
import 'package:app_campi/core/shared_widget/urgenza_badge.dart';
import 'package:app_campi/core/shared_widget/animated_fill_bar.dart';
import 'package:app_campi/features/home/presentation/widgets/date_time_row.dart';
import '../../domain/partita_con_dati.dart';
import 'join_match_bottom_sheet.dart';
import 'package:app_campi/core/models/utente.dart';

class EsploraMatchCard extends ConsumerWidget {
  final PartitaConDati item;
  final bool giaIscritto;

  const EsploraMatchCard({
    super.key,
    required this.item,
    required this.giaIscritto,
  });

  // 🟢 Helper per estrarre il livello dell'organizzatore per lo sport scelto (default 'calcio')
  String _estraiLivelloOrganizzatore(
    Utente organizzatore, {
    String sport = 'calcio',
  }) {
    if (organizzatore.livelliSport != null &&
        organizzatore.livelliSport!.containsKey(sport)) {
      return organizzatore.livelliSport![sport].toString();
    }
    return "Non specificato";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raw = item.raw;
    final partita = item.partita;

    final bool protetta = raw['stato_partita'] == 'aperta_protetta';
    final Color coloreTema = protetta
        ? AppTheme.textPrimary
        : AppTheme.statoErrore;
    final String tipoSport = protetta ? "PROTETTA" : "A RISCHIO";

    final double distanzaKm = (raw['distanza_km'] as num?)?.toDouble() ?? 0.0;
    final int giocatoriAttuali = partita.numeroGiocatoriPrenotati;
    final int giocatoriMassimi = partita.campo.numeroDiGiocatori;
    final int postiRimasti = giocatoriMassimi - giocatoriAttuali;
    final String dataOra = formattaDataOra(
      partita.dataPartita,
      partita.orarioInizio,
    );

    // 🟢 Recupero livello organizzatore
    final String livelloOrg = _estraiLivelloOrganizzatore(
      partita.organizzatore,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.cardBg,
        border: Border.all(
          color: giaIscritto
              ? AppTheme.accent.withOpacity(0.5)
              : (coloreTema == AppTheme.textPrimary
                    ? AppTheme.cardBorder
                    : coloreTema.withOpacity(0.4)),
          width: giaIscritto ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: giaIscritto
                ? AppTheme.accent.withOpacity(0.1)
                : coloreTema.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => mostraDettagliEUnisciti(context, ref, raw),
            splashColor: AppTheme.accent.withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          StatusBadge(label: tipoSport, color: coloreTema),
                          if (UrgenzaBadge.shouldShow(postiRimasti)) ...[
                            const SizedBox(width: 8),
                            UrgenzaBadge(postiRimasti: postiRimasti),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${distanzaKm.toStringAsFixed(1)} km",
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    partita.campo.nomeCampo,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  DateTimeRow(text: dataOra),
                  const SizedBox(height: 12),

                  // 🟢 NUOVO RIQUADRO ORGANIZZATORE BELLO E ORDINATO
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.accent.withOpacity(0.2),
                          child: Text(
                            partita.organizzatore.nome[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Organizzato da: ${partita.organizzatore.nomeCompleto}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (partita.organizzatore.eta != null) ...[
                                    Text(
                                      "Età: ${partita.organizzatore.eta} anni",
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const Text(
                                      " • ",
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                  Text(
                                    "Livello: $livelloOrg",
                                    style: const TextStyle(
                                      color: AppTheme.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  AnimatedFillBar(
                    label: "Posti occupati",
                    valoreAttuale: giocatoriAttuali,
                    valoreMassimo: giocatoriMassimi,
                    colore: coloreTema == AppTheme.textPrimary
                        ? AppTheme.accent
                        : coloreTema,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _MatchCtaButton(
                      raw: raw,
                      giaIscritto: giaIscritto,
                      postiRimasti: postiRimasti,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchCtaButton extends ConsumerWidget {
  final Map<String, dynamic> raw;
  final bool giaIscritto;
  final int postiRimasti;

  const _MatchCtaButton({
    required this.raw,
    required this.giaIscritto,
    required this.postiRimasti,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (giaIscritto) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.accent.withOpacity(0.5)),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 18),
            SizedBox(width: 8),
            Text(
              "SEI DENTRO",
              style: TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    if (postiRimasti <= 0) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.darkBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        alignment: Alignment.center,
        child: const Text(
          "PARTITA AL COMPLETO",
          style: TextStyle(
            color: AppTheme.textDisabled,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => mostraDettagliEUnisciti(context, ref, raw),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.darkBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Text(
        "UNISCITI AL MATCH",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
