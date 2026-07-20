import 'package:flutter/material.dart';
import 'package:app_campi/core/models/societa.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/features/prenotazione/presentation/widget/modern_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

final Color _coloreElementiPage = AppTheme.neonOrange;

class SocietaCard extends StatelessWidget {
  final Societa societa;
  final VoidCallback onTap;

  const SocietaCard({super.key, required this.societa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ModernCard(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: societa.fotoUrl != null && societa.fotoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: societa.fotoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.white.withValues(alpha: 0.02),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: _coloreElementiPage,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      societa.nomeSocieta,
                      style: TextStyle(
                        color: _coloreElementiPage,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_city_outlined,
                          size: 14,
                          color: AppTheme.neonCyan,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            societa.citta,
                            style: const TextStyle(
                              color: AppTheme.neonCyan,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.house_outlined,
                          size: 14,
                          color: AppTheme.testoSecondario,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            societa.via,
                            style: const TextStyle(
                              color: AppTheme.testoSecondario,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.chevron_right,
                  color: AppTheme.testoSecondario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonCyan.withValues(alpha: 0.2),
            AppTheme.neonCyan.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.business, color: AppTheme.neonCyan, size: 30),
    );
  }
}
