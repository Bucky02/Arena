import 'package:flutter/material.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/features/admin/config/piani_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PianiAbbonamentoScreen extends StatefulWidget {
  const PianiAbbonamentoScreen({super.key});

  @override
  State<PianiAbbonamentoScreen> createState() => _PianiAbbonamentoScreenState();
}

class _PianiAbbonamentoScreenState extends State<PianiAbbonamentoScreen> {
  int _indiceSelezionato = -1;
  bool _isLoading = false;

  Future<void> _avviaPagamento(String priceId, String nomePiano) async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'crea-checkout-session',
        body: {'priceId': priceId, 'piano': nomePiano},
      );

      final String? url = response.data['url'];
      if (url == null) throw Exception('URL non ricevuto da Stripe');

      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore avvio pagamento: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPianoCard({
    required int index,
    required String titolo,
    required String sottotitolo,
    required String prezzo,
    required String priceId,
    required String nomePiano,
  }) {
    final bool isEvidenziato = _indiceSelezionato == index;

    return GestureDetector(
      onTap: () => setState(() => _indiceSelezionato = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 260,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEvidenziato ? AppTheme.neonOrange : Colors.grey.shade800,
            width: isEvidenziato ? 2 : 1,
          ),
          boxShadow: isEvidenziato
              ? [
                  BoxShadow(
                    color: AppTheme.neonOrange.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: isEvidenziato
                    ? AppTheme.neonOrange
                    : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                titolo,
                style: TextStyle(
                  color: isEvidenziato ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              sottotitolo,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '€ ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  prezzo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Text(
              '/ mese',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 5),
            const Text(
              '( IVA esclusa )',
              style: TextStyle(color: Colors.white30, fontSize: 12),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _avviaPagamento(priceId, nomePiano),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEvidenziato
                      ? AppTheme.neonOrange
                      : Colors.transparent,
                  foregroundColor: isEvidenziato ? Colors.black : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: isEvidenziato
                        ? BorderSide.none
                        : BorderSide(color: Colors.grey.shade600),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Seleziona Piano',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.neonOrange, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.neonOrange),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.neonOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.neonOrange),
              ),
              child: const Text(
                "SEI UN GESTORE? SCEGLI L'ABBONMANETO CHE FA PER TE",
                style: TextStyle(
                  color: AppTheme.neonOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'I nostri piani sono semplici e flessibili.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Text(
                "Tutti i Club di ogni dimensione hanno bisogno di questo gestionale, per questo abbiamo un'offerta a prezzi flessibili per ogni tipo di centro sportivo e senza nessun costo di attivazione.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 50),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: PianiConfig.piani.asMap().entries.map((entry) {
                final index = entry.key;
                final piano = entry.value;
                return _buildPianoCard(
                  index: index,
                  titolo: piano['titolo']!,
                  sottotitolo: piano['sottotitolo']!,
                  prezzo: piano['prezzo']!,
                  priceId: piano['priceId']!,
                  nomePiano: piano['nome']!,
                );
              }).toList(),
            ),
            const SizedBox(height: 50),

            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.neonOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Perché scegliere la nostra App?',
                    style: TextStyle(
                      color: AppTheme.neonOrange,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildFeatureRow(
                    Icons.payments,
                    'Flessibilità di Pagamento: Decidi in autonomia se incassare le prenotazioni in contanti al campo, richiedere il pagamento online tramite carta, oppure offrire entrambe le opzioni.',
                  ),
                  _buildFeatureRow(
                    Icons.rule,
                    'Regole di Cancellazione Chiare: Rimborso automatico (sul portafoglio in-app) per chi annulla la partita con preavviso, e penali a tuo favore per chi disdice all\'ultimo minuto.',
                  ),
                  _buildFeatureRow(
                    Icons.phone_disabled,
                    'Basta chiamate e messaggi a tutte le ore. Il sistema lavora per te H24, mostrando ai clienti in tempo reale la disponibilità del calendario.',
                  ),
                  _buildFeatureRow(
                    Icons.group_add,
                    'Mai più campi vuoti per "mancanza di un giocatore". Con le "Partite Aperte", aiutiamo i ragazzi a trovare i giocatori mancanti direttamente in app, aumentando i tuoi incassi.',
                  ),
                  _buildFeatureRow(
                    Icons.map,
                    'Integrazione nel nostro motore di ricerca geolocalizzato: i giocatori nei paraggi troveranno il tuo centro sportivo in un tap.',
                  ),
                  _buildFeatureRow(
                    Icons.settings_suggest,
                    'Tariffe dinamiche: configura sconti per soci, prezzi diversi in base alla fascia oraria e gestisci le liste d\'attesa automatiche.',
                  ),
                  _buildFeatureRow(
                    Icons.calendar_month,
                    'Tabellone sempre a portata di mano: consulta il calendario giornaliero interattivo direttamente dal tuo profilo, con tutti i campi, gli orari e i dettagli delle prenotazioni in tempo reale.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trasparenza e Regolamento',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildPolicyText(
                    '• Rimodulazione automatica: Se nel corso dell\'utilizzo aggiungi o rimuovi campi, il tuo piano si adatterà automaticamente.',
                  ),
                  _buildPolicyText(
                    '• Prezzo bloccato a vita: La tariffa che vedi al momento dell\'iscrizione rimarrà tua per sempre, senza futuri aumenti di prezzo, a patto di non interrompere l\'abbonamento.',
                  ),
                  _buildPolicyText(
                    '• Riattivazioni: Se disdici l\'abbonamento e decidi di tornare mesi dopo, sarai soggetto alle nuove tariffe vigenti in quel momento.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
