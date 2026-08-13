import 'package:flutter/material.dart';
import 'package:app_campi/core/models/societa.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SocietaCardPro extends StatelessWidget {
  final Societa societa;
  final String sport;
  final double prezzoPartenza;
  final String? distanzaKm;
  final VoidCallback onTap;

  const SocietaCardPro({
    super.key,
    required this.societa,
    required this.sport,
    required this.prezzoPartenza,
    this.distanzaKm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAMAGINE DI COPERTINA + BADGE PREZZO
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      societa.fotoUrl != null && societa.fotoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: societa.fotoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.white10,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.neonOrange,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),

                      // SFUMATURA SCURA IN BASSO ALL'IMMAGINE
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.85),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // PREZZO BADGE (Stile Arena Pro / Playtomic)
                      Positioned(
                        bottom: 12,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.neonOrange,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonOrange.withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '1h a ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${prezzoPartenza.toStringAsFixed(0)} €',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // NOME SOCIETÀ SOVRAPPOSTO SULLA FOTO
                      Positioned(
                        bottom: 12,
                        left: 14,
                        right: 110,
                        child: Text(
                          societa.nomeSocieta,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // INFO DETTAGLI (CITTÀ E DISTANZA)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.neonCyan,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        distanzaKm != null ? '$distanzaKm • ' : '',
                        style: const TextStyle(
                          color: AppTheme.neonCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${societa.citta}, ${societa.via}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white30,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF252830),
      child: const Center(
        child: Icon(
          Icons.sports_tennis_rounded,
          color: Colors.white24,
          size: 48,
        ),
      ),
    );
  }
}
