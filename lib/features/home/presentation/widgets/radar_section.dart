import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/features/home/presentation/widgets/radar_map_screen.dart';

class RadarSection extends StatelessWidget {
  const RadarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonCyan.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.3,
              child: CachedNetworkImage(
                imageUrl:
                    'https://images.unsplash.com/photo-1508344928928-7137b29de216?auto=format&fit=crop&w=1000&q=80',
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppTheme.cardBg),
                errorWidget: (context, url, error) =>
                    Container(color: AppTheme.cardBg),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkBg.withOpacity(0.8),
                      AppTheme.neonCyan.withOpacity(0.1),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.radar,
                        size: 140,
                        color: AppTheme.neonCyan.withOpacity(0.2),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "CAMPI IN ZONA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Scopri le arene entro 5km da te.",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.location_searching, size: 18),
                          label: const Text("ATTIVA RADAR"),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RadarMapScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
