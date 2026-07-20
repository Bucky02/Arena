import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:app_campi/core/theme/app_theme.dart';

void showAuthBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext ctx) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppTheme.darkBg.withOpacity(0.94),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: const Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.neonGreen.withOpacity(0.2),
                        AppTheme.neonCyan.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_person_outlined,
                    size: 36,
                    color: AppTheme.neonGreen,
                  ),
                ),
                const SizedBox(height: 15),

                const Text(
                  'Area Personale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Accedi per prenotare i campi o crea un nuovo account per iniziare.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
                const SizedBox(height: 30),

                // Bottone ACCEDI
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final navigator = Navigator.of(ctx);
                      navigator.pop();
                      navigator.pushNamed('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.coloreBottoneAccedi,
                      foregroundColor: AppTheme.darkBg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'ACCEDI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Bottone REGISTRATI
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      final navigator = Navigator.of(ctx);
                      navigator.pop();
                      navigator.pushNamed('/registrazione');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.coloreBottoneRegistrati,
                      side: const BorderSide(
                        color: AppTheme.coloreBottoneRegistrati,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'REGISTRATI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      );
    },
  );
}
