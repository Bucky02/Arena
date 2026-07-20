import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/core/theme/app_constants.dart';
import '../../application/esplora_match_providers.dart';
import '../../domain/filtro_distanza.dart';

class FiltroDistanzaChips extends ConsumerWidget {
  const FiltroDistanzaChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtroAttuale = ref.watch(filtroDistanzaProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: 10,
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: _DistanzaChip(
                label: "Vicino (≤${MatchThresholds.distanzaVicino.toInt()}km)",
                valore: FiltroDistanza.vicini,
                icon: Icons.near_me_rounded,
                filtroAttuale: filtroAttuale,
              ),
            ),
            Expanded(
              child: _DistanzaChip(
                label: "Estesa (≤${MatchThresholds.distanzaEstesa.toInt()}km)",
                valore: FiltroDistanza.estesa,
                icon: Icons.travel_explore_rounded,
                filtroAttuale: filtroAttuale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistanzaChip extends ConsumerWidget {
  final String label;
  final FiltroDistanza valore;
  final IconData icon;
  final FiltroDistanza filtroAttuale;

  const _DistanzaChip({
    required this.label,
    required this.valore,
    required this.icon,
    required this.filtroAttuale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = filtroAttuale == valore;
    final color = isSelected ? AppTheme.accent : AppTheme.textSecondary;

    return GestureDetector(
      onTap: () => ref.read(filtroDistanzaProvider.notifier).state = valore,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.accent.withOpacity(0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
