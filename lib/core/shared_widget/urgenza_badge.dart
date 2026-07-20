import 'package:flutter/material.dart';
import 'package:app_campi/core/theme/app_constants.dart';

//Badge di urgenza mostrato quando rimangono pochi posti liberi
/// (controllato da [MatchThresholds.postiUrgenza]).
class UrgenzaBadge extends StatelessWidget {
  final int postiRimasti;

  const UrgenzaBadge({super.key, required this.postiRimasti});

  static bool shouldShow(int postiRimasti) {
    return postiRimasti > 0 && postiRimasti <= MatchThresholds.postiUrgenza;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 12,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              "ULTIMI $postiRimasti POSTI",
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
