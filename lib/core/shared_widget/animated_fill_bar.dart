import 'package:flutter/material.dart';
import 'package:app_campi/core/theme/app_constants.dart';

class AnimatedFillBar extends StatelessWidget {
  final String label;
  final int valoreAttuale;
  final int valoreMassimo;
  final Color colore;

  const AnimatedFillBar({
    super.key,
    required this.label,
    required this.valoreAttuale,
    required this.valoreMassimo,
    required this.colore,
  });

  @override
  Widget build(BuildContext context) {
    final double percentuale = valoreMassimo > 0
        ? (valoreAttuale / valoreMassimo).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              "$valoreAttuale / $valoreMassimo",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percentuale),
            duration: AppDurations.progressFill,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white10,
              color: colore,
              minHeight: 7,
            ),
          ),
        ),
      ],
    );
  }
}
