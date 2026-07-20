import 'package:flutter/material.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/core/theme/app_constants.dart';
import 'package:app_campi/features/miei_match/application/partite_utente_provider.dart';

class FiltriMatchWidget extends StatelessWidget {
  final FiltroPartita filtroAttivo;
  final ValueChanged<FiltroPartita> onFiltroChanged;

  const FiltriMatchWidget({
    super.key,
    required this.filtroAttivo,
    required this.onFiltroChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
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
              child: _TabFiltro(
                label: "Aperti",
                icon: Icons.lock_open_rounded,
                isSelected: filtroAttivo == FiltroPartita.aperte,
                onTap: () => onFiltroChanged(FiltroPartita.aperte),
              ),
            ),
            Expanded(
              child: _TabFiltro(
                label: "Completi",
                icon: Icons.check_circle_rounded,
                isSelected: filtroAttivo == FiltroPartita.complete,
                onTap: () => onFiltroChanged(FiltroPartita.complete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabFiltro extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabFiltro({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.accent : AppTheme.textSecondary;

    return GestureDetector(
      onTap: onTap,
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
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
