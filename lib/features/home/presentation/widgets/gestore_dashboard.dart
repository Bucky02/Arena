import 'package:flutter/material.dart';
import 'package:app_campi/core/theme/app_theme.dart';

class GestoreDashboard extends StatelessWidget {
  const GestoreDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.neonOrange.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonOrange.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppTheme.neonOrange.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.analytics, color: AppTheme.neonOrange),
                    SizedBox(width: 10),
                    Text(
                      "DASHBOARD GESTORE",
                      style: TextStyle(
                        color: AppTheme.neonOrange,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatGestore("MATCH", "12", AppTheme.neonGreen),
                    Container(width: 1, height: 40, color: Colors.white12),
                    _buildStatGestore("CAMPI", "4", AppTheme.neonCyan),
                    Container(width: 1, height: 40, color: Colors.white12),
                    _buildStatGestore("INCASSO", "€140", AppTheme.neonOrange),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatGestore(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
