import 'package:flutter/material.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/features/admin/presentation/pages/aggiungi_campo_page.dart';
import 'package:app_campi/core/services/campi_service.dart';

class ListaCampiWidget extends StatelessWidget {
  final List<Map<String, dynamic>> campi;
  final int limiteCampiConsentiti;
  final String idSocieta;
  final VoidCallback onAggiornamento;

  const ListaCampiWidget({
    super.key,
    required this.campi,
    required this.limiteCampiConsentiti,
    required this.idSocieta,
    required this.onAggiornamento,
  });

  bool _isCampoAttivo(int index) => index < limiteCampiConsentiti;

  Future<bool?> _mostraDialogElimina(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text(
          'Elimina Campo',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: const Text(
          'Sei sicuro di voler eliminare questo campo e tutte le partite collegate?',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Elimina',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (campi.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Center(
          child: Text(
            'Nessun campo inserito.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: campi.length,
      itemBuilder: (context, index) {
        final campo = campi[index];
        final bool attivo = _isCampoAttivo(index);
        final int numGiocatoriDisplay =
            (campo['numero_di_giocatori'] as int? ?? 10) ~/ 2;

        return Opacity(
          opacity: attivo ? 1.0 : 0.45,
          child: Container(
            width: 190,
            margin: const EdgeInsets.only(right: 10),
            child: Card(
              color: AppTheme.cardBg,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: attivo ? AppTheme.neonOrange : Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    Icon(
                      attivo ? Icons.sports_soccer : Icons.lock,
                      color: attivo ? AppTheme.neonOrange : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campo['nome_campo'] ?? 'Senza nome',
                            style: TextStyle(
                              color: attivo ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            attivo
                                ? 'Calcio a $numGiocatoriDisplay'
                                : 'Piano superiore richiesto',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (attivo)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                          size: 16,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: AppTheme.cardBg,
                        onSelected: (value) async {
                          if (value == 'modifica') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AggiungiCampo(
                                  idSocieta: idSocieta,
                                  campoEsistente: campo,
                                ),
                              ),
                            );
                            onAggiornamento();
                          } else if (value == 'elimina') {
                            final conferma = await _mostraDialogElimina(
                              context,
                            );
                            if (conferma == true) {
                              try {
                                await CampiService().eliminaCampo(campo['id']);
                                onAggiornamento();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll(
                                          'Exception: ',
                                          '',
                                        ),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'modifica',
                            child: Text(
                              'Modifica',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'elimina',
                            child: Text(
                              'Elimina',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      )
                    else
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                          size: 16,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: AppTheme.cardBg,
                        onSelected: (value) async {
                          if (value == 'elimina') {
                            final conferma = await _mostraDialogElimina(
                              context,
                            );
                            if (conferma == true) {
                              try {
                                await CampiService().eliminaCampo(campo['id']);
                                onAggiornamento();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll(
                                          'Exception: ',
                                          '',
                                        ),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'elimina',
                            child: Text(
                              'Elimina',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
