import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/core/models/campo.dart';
import 'package:app_campi/core/repositories/campi_repository.dart';
import 'package:app_campi/features/prenotazione/application/creazione_partita_controller.dart';
import 'package:app_campi/features/prenotazione/presentation/pages/creazione_partita_page.dart';

class ListaCampiScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> societa;

  const ListaCampiScreen({super.key, required this.societa});

  @override
  ConsumerState<ListaCampiScreen> createState() => _ListaCampiScreenState();
}

class _ListaCampiScreenState extends ConsumerState<ListaCampiScreen> {
  final CampiRepository _campiRepository = CampiRepository();
  late Future<List<Campo>> _futureCampi;

  @override
  void initState() {
    super.initState();
    final String idSocieta = widget.societa['id'].toString();

    _futureCampi = _campiRepository.getCampiSocieta(idSocieta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.societa['nome_societa'] ?? 'Dettaglio Centro',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
            Text(
              widget.societa['indirizzo'] ?? '',
              style: const TextStyle(fontSize: 12, color: AppTheme.neonCyan),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Campo>>(
        future: _futureCampi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.neonOrange),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Errore durante il caricamento:\n${snapshot.error}",
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final campi = snapshot.data ?? [];

          if (campi.isEmpty) {
            return const Center(
              child: Text(
                "Nessun campo disponibile al momento.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: campi.length,
            itemBuilder: (context, index) {
              final Campo campo = campi[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppTheme.neonCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    campo.nomeCampo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          campo.coperto ? Icons.roofing : Icons.wb_sunny,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          campo.coperto ? "Coperto" : "All'aperto",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.groups,
                          size: 16,
                          color: AppTheme.neonOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${campo.numeroDiGiocatori} Giocatori",
                          style: const TextStyle(
                            color: AppTheme.neonOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Prezzo",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      Text(
                        "€${campo.prezzo.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: AppTheme.neonCyan,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    ref
                        .read(creazionePartitaProvider.notifier)
                        .selezionaCampo(campo);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreazionePartitaPage(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
