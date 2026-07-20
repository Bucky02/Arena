import 'package:flutter/material.dart';
import 'package:app_campi/core/theme/app_theme.dart';

class NotificheBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const NotificheBell({super.key, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.textPrimary.withOpacity(0.05),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppTheme.textPrimary,
              size: 26,
            ),
            onPressed: onTap,
          ),
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 6,
            child: TweenAnimationBuilder<double>(
              key: ValueKey(count),
              tween: Tween(begin: 0.4, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.statoErrore,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.darkBg, width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
