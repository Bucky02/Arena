import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_campi/core/models/utente.dart';
import 'package:app_campi/core/theme/app_theme.dart';

class HeroBanner extends StatelessWidget {
  final Utente? utenteLoggato;

  const HeroBanner({super.key, this.utenteLoggato});

  @override
  Widget build(BuildContext context) {
    final double bannerHeight = MediaQuery.of(context).size.height * 0.52;

    return SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // IMMAGINE DI SFONDO
          CachedNetworkImage(
            imageUrl:
                'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?auto=format&fit=crop&w=1000&q=80',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppTheme.cardBg,
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.neonGreen),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppTheme.cardBg,
              child: const Center(
                child: Icon(
                  Icons.sports_soccer,
                  color: Colors.white24,
                  size: 50,
                ),
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkBg.withOpacity(0.9),
                  Colors.transparent,
                  AppTheme.darkBg,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (utenteLoggato != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonGreen.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      "BENTORNATO, ${utenteLoggato!.nome.toUpperCase()}!",
                      style: const TextStyle(
                        color: AppTheme.darkBg,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                const Text(
                  "PRENOTA IL CAMPO.\nTROVA LA SQUADRA.\nDOMINA IL MATCH.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Dimentica le chat infinite. L'unica app che unisce prenotazioni istantanee e matchmaking automatico.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonGreen.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("TROVA PARTITA"),
                        SizedBox(width: 8),
                        Icon(Icons.sports_soccer, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
