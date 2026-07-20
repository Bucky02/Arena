import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_campi/features/prenotazione/application/creazione_partita_controller.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/features/prenotazione/presentation/widget/societa_card.dart';
import 'lista_campi_centro_page.dart';

class RicercaCentriPage extends ConsumerStatefulWidget {
  const RicercaCentriPage({super.key});

  @override
  ConsumerState<RicercaCentriPage> createState() => _RicercaCentriPageState();
}

class _RicercaCentriPageState extends ConsumerState<RicercaCentriPage> {
  final TextEditingController searchCtrl = TextEditingController();
  TipoRicerca filtroSelezionato = TipoRicerca.tutti;

  Timer? _debounceTimer;
  bool _ricercaEseguita = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    final testo = value.trim();

    if (testo.length < 3) {
      if (_ricercaEseguita) {
        setState(() => _ricercaEseguita = false);
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() => _ricercaEseguita = true);
      ref.read(creazionePartitaProvider.notifier).cercaSocieta(testo);
    });
  }

  void _eseguiRicerca() {
    _debounceTimer?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    final query = searchCtrl.text.trim();

    if (query.length < 3) {
      if (_ricercaEseguita) {
        setState(() => _ricercaEseguita = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inserisci almeno 3 caratteri per cercare."),
          backgroundColor: AppTheme.statoAttenzione,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _ricercaEseguita = true);
    ref.read(creazionePartitaProvider.notifier).cercaSocieta(query);
  }

  void _cancellaRicerca() {
    _debounceTimer?.cancel();
    searchCtrl.clear();
    setState(() => _ricercaEseguita = false);
  }

  Widget _buildFilterChip(String label, TipoRicerca tipo) {
    final bool isSelected = filtroSelezionato == tipo;
    return GestureDetector(
      onTap: () {
        if (filtroSelezionato == tipo) return;

        setState(() => filtroSelezionato = tipo);
        ref.read(creazionePartitaProvider.notifier).impostaFiltroRicerca(tipo);

        final testo = searchCtrl.text.trim();
        if (testo.length >= 3) {
          FocusManager.instance.primaryFocus?.unfocus();
          ref.read(creazionePartitaProvider.notifier).cercaSocieta(testo);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent.withOpacity(0.12)
              : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.accent.withOpacity(0.5)
                : AppTheme.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(state) {
    if (!_ricercaEseguita) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.travel_explore_rounded, color: Colors.white12, size: 72),
            SizedBox(height: 16),
            Text(
              'Cerca per nome centro\no per città',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }

    if (state.societaTrovate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: Colors.white24,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun risultato per\n"${searchCtrl.text.trim()}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Prova con un nome diverso o cambia filtro.',
              style: TextStyle(color: Colors.white30, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: state.societaTrovate.length,
      itemBuilder: (context, index) {
        final societa = state.societaTrovate[index];
        return SocietaCard(
          societa: societa,
          onTap: () {
            ref
                .read(creazionePartitaProvider.notifier)
                .caricaCampiSocieta(societa.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListaCampiCentroPage(societa: societa),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(creazionePartitaProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 20,
                    top: 12,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "PRENOTA PARTITA",
                        style: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DOVE VUOI GIOCARE?',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchCtrl,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              onChanged: _onSearchChanged,
                              onSubmitted: (_) => _eseguiRicerca(),
                              decoration: InputDecoration(
                                hintText: 'Cerca un centro o città...',
                                hintStyle: const TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppTheme.textSecondary,
                                ),
                                suffixIcon:
                                    ValueListenableBuilder<TextEditingValue>(
                                      valueListenable: searchCtrl,
                                      builder: (_, value, __) {
                                        return value.text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.close_rounded,
                                                  color: AppTheme.textSecondary,
                                                ),
                                                onPressed: _cancellaRicerca,
                                              )
                                            : const SizedBox.shrink();
                                      },
                                    ),
                                filled: true,
                                fillColor: AppTheme.cardBg,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppTheme.cardBorder,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppTheme.cardBorder,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppTheme.accent.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.accent.withOpacity(0.3),
                              ),
                            ),
                            child: IconButton(
                              onPressed: _eseguiRicerca,
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppTheme.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildFilterChip(
                                'Tutti',
                                TipoRicerca.tutti,
                              ),
                            ),
                            Expanded(
                              child: _buildFilterChip(
                                'Società',
                                TipoRicerca.societa,
                              ),
                            ),
                            Expanded(
                              child: _buildFilterChip(
                                'Città',
                                TipoRicerca.citta,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
