import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_campi/core/theme/app_theme.dart';

class LiveTimerWidget extends StatefulWidget {
  final DateTime dataPartita;
  final String orarioInizio;

  const LiveTimerWidget({
    super.key,
    required this.dataPartita,
    required this.orarioInizio,
  });

  @override
  State<LiveTimerWidget> createState() => _LiveTimerWidgetState();
}

class _LiveTimerWidgetState extends State<LiveTimerWidget> {
  Timer? _timer;
  Duration _tempoRimanente = Duration.zero;
  bool _isScaduto = false;

  @override
  void initState() {
    super.initState();
    _calcolaTempo();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calcolaTempo();
    });
  }

  void _calcolaTempo() {
    final partiOrario = widget.orarioInizio.split(':');
    final inizioEsatto = DateTime(
      widget.dataPartita.year,
      widget.dataPartita.month,
      widget.dataPartita.day,
      int.parse(partiOrario[0]),
      int.parse(partiOrario[1]),
    );

    final adesso = DateTime.now();

    if (adesso.isAfter(inizioEsatto)) {
      setState(() {
        _isScaduto = true;
        _tempoRimanente = Duration.zero;
      });
      _timer?.cancel();
    } else {
      setState(() {
        _tempoRimanente = inizioEsatto.difference(adesso);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isScaduto) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_score, color: AppTheme.neonOrange, size: 18),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              "MATCH IN CORSO / TERMINATO",
              style: TextStyle(
                color: AppTheme.neonOrange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    String giorni = _tempoRimanente.inDays > 0
        ? "${_tempoRimanente.inDays}g "
        : "";
    String ore = (_tempoRimanente.inHours % 24).toString().padLeft(2, '0');
    String minuti = (_tempoRimanente.inMinutes % 60).toString().padLeft(2, '0');
    String secondi = (_tempoRimanente.inSeconds % 60).toString().padLeft(
      2,
      '0',
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.neonGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: AppTheme.neonGreen, size: 16),
          const SizedBox(width: 6),

          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "Inizia tra: $giorni$ore:$minuti:$secondi",
                style: const TextStyle(
                  color: AppTheme.neonGreen,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Courier',
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
