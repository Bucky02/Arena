import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/core/models/utente.dart';
import 'package:app_campi/core/services/campi_service.dart';
import 'package:app_campi/core/services/partita_service.dart';

class DashboardState {
  final List<Map<String, dynamic>> campi;
  final List<Map<String, dynamic>> datiPartiteRaw;
  final List<Map<String, dynamic>> orariSocieta;
  final List<Map<String, dynamic>> chiusureStraordinarie;
  final List<Appointment> prenotazioniVisibili;
  final String? idCampoSelezionato;
  final String stringaDataCorrente;
  final bool isLoading;
  final String? actualIdSocieta;
  final int limiteCampiConsentiti;
  final double startHour;
  final double endHour;
  final bool isCentroAttivo;

  const DashboardState({
    this.campi = const [],
    this.datiPartiteRaw = const [],
    this.orariSocieta = const [],
    this.chiusureStraordinarie = const [],
    this.prenotazioniVisibili = const [],
    this.idCampoSelezionato,
    this.stringaDataCorrente = '',
    this.isLoading = true,
    this.actualIdSocieta,
    this.limiteCampiConsentiti = 1,
    this.startHour = 8.0,
    this.endHour = 24.0,
    this.isCentroAttivo = true,
  });

  DashboardState copyWith({
    List<Map<String, dynamic>>? campi,
    List<Map<String, dynamic>>? datiPartiteRaw,
    List<Map<String, dynamic>>? orariSocieta,
    List<Map<String, dynamic>>? chiusureStraordinarie,
    List<Appointment>? prenotazioniVisibili,
    String? idCampoSelezionato,
    bool clearIdCampo = false,
    String? stringaDataCorrente,
    bool? isLoading,
    String? actualIdSocieta,
    int? limiteCampiConsentiti,
    double? startHour,
    double? endHour,
    bool? isCentroAttivo,
  }) {
    return DashboardState(
      campi: campi ?? this.campi,
      datiPartiteRaw: datiPartiteRaw ?? this.datiPartiteRaw,
      orariSocieta: orariSocieta ?? this.orariSocieta,
      chiusureStraordinarie:
          chiusureStraordinarie ?? this.chiusureStraordinarie,
      prenotazioniVisibili: prenotazioniVisibili ?? this.prenotazioniVisibili,
      idCampoSelezionato: clearIdCampo
          ? null
          : (idCampoSelezionato ?? this.idCampoSelezionato),
      stringaDataCorrente: stringaDataCorrente ?? this.stringaDataCorrente,
      isLoading: isLoading ?? this.isLoading,
      actualIdSocieta: actualIdSocieta ?? this.actualIdSocieta,
      limiteCampiConsentiti:
          limiteCampiConsentiti ?? this.limiteCampiConsentiti,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      isCentroAttivo: isCentroAttivo ?? this.isCentroAttivo,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  final CampiService _campiService = CampiService();
  final PartitaService _partitaService = PartitaService();
  RealtimeChannel? _realtimeChannel;

  @override
  DashboardState build() => const DashboardState();

  Future<void> inizializza({String? idSocieta, Utente? utenteLoggato}) async {
    state = state.copyWith(isLoading: true);

    try {
      String? actualIdSocieta;
      int limiteCampiConsentiti = 1;

      final String idDaUsare = idSocieta ?? state.actualIdSocieta ?? '';

      if (idDaUsare.isNotEmpty) {
        final res = await Supabase.instance.client
            .from('societa')
            .select('piano_attuale')
            .eq('id', idDaUsare)
            .single();

        final String piano =
            res['piano_attuale']?.toString().toLowerCase() ?? 'nessuno';
        final bool attivo = piano != 'nessuno';

        state = state.copyWith(isCentroAttivo: attivo);
      }
      if (idSocieta != null) {
        actualIdSocieta = idSocieta;
        final societaData = await Supabase.instance.client
            .from('societa')
            .select('limite_campi')
            .eq('id', idSocieta)
            .single();
        limiteCampiConsentiti = societaData['limite_campi'] as int? ?? 1;
      } else if (utenteLoggato != null) {
        final societaData = await Supabase.instance.client
            .from('societa')
            .select('id, limite_campi')
            .eq('id_utente', utenteLoggato.id)
            .single();
        actualIdSocieta = societaData['id'] as String;
        limiteCampiConsentiti = societaData['limite_campi'] as int? ?? 1;
      }

      state = state.copyWith(
        actualIdSocieta: actualIdSocieta,
        limiteCampiConsentiti: limiteCampiConsentiti,
      );

      if (actualIdSocieta != null) {
        List<Map<String, dynamic>> campi = [];
        List<Map<String, dynamic>> datiPartiteRaw = [];
        List<Map<String, dynamic>> orariSocieta = [];
        List<Map<String, dynamic>> chiusureStraordinarie = [];

        try {
          campi = await _campiService.ottieniCampiSocieta(actualIdSocieta);
        } catch (e) {
          debugPrint("Err campi: $e");
        }

        String? idCampoSelezionato;
        bool clearIdCampo = false;
        if (campi.isEmpty) {
          clearIdCampo = true;
        } else {
          final ids = campi.map((c) => c['id'].toString()).toList();
          if (state.idCampoSelezionato == null ||
              !ids.contains(state.idCampoSelezionato)) {
            idCampoSelezionato = campi.first['id'].toString();
          } else {
            idCampoSelezionato = state.idCampoSelezionato;
          }
        }

        try {
          datiPartiteRaw = await _partitaService.ottieniPrenotazioniSocieta(
            actualIdSocieta,
          );
        } catch (e) {
          debugPrint("Err partite: $e");
        }

        try {
          orariSocieta = await Supabase.instance.client
              .from('orari_societa')
              .select()
              .eq('id_societa', actualIdSocieta);
        } catch (e) {
          debugPrint("Err orari: $e");
        }

        try {
          chiusureStraordinarie = await Supabase.instance.client
              .from('chiusure_straordinarie')
              .select()
              .eq('id_societa', actualIdSocieta);
        } catch (e) {
          debugPrint("Err chiusure: $e");
        }

        state = state.copyWith(
          campi: campi,
          datiPartiteRaw: datiPartiteRaw,
          orariSocieta: orariSocieta,
          chiusureStraordinarie: chiusureStraordinarie,
          idCampoSelezionato: idCampoSelezionato,
          clearIdCampo: clearIdCampo,
        );

        _calcolaOrariGriglia();
        filtraEConvertiDatiCalendario();
      }
    } catch (e) {
      debugPrint("Errore inizializzazione: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void _calcolaOrariGriglia() {
    if (state.orariSocieta.isEmpty) return;
    double minH = 24.0;
    double maxH = 0.0;

    for (var o in state.orariSocieta) {
      if (o['is_chiuso'] == true) continue;
      final apStr = o['orario_apertura']?.toString() ?? '08:00:00';
      final chStr = o['orario_chiusura']?.toString() ?? '23:00:00';
      final hAp = double.tryParse(apStr.split(':')[0]) ?? 8.0;
      if (hAp < minH) minH = hAp;
      final hCh = double.tryParse(chStr.split(':')[0]) ?? 23.0;
      final mCh = double.tryParse(chStr.split(':')[1]) ?? 0.0;
      double endCh = hCh + (mCh > 0 ? 1.0 : 0.0);
      if (endCh > maxH) maxH = endCh;

      final ap2Str = o['orario_apertura_2']?.toString();
      final ch2Str = o['orario_chiusura_2']?.toString();
      if (ap2Str != null && ch2Str != null) {
        final hAp2 = double.tryParse(ap2Str.split(':')[0]) ?? hAp;
        if (hAp2 < minH) minH = hAp2;
        final hCh2 = double.tryParse(ch2Str.split(':')[0]) ?? hCh;
        final mCh2 = double.tryParse(ch2Str.split(':')[1]) ?? 0.0;
        double endCh2 = hCh2 + (mCh2 > 0 ? 1.0 : 0.0);
        if (endCh2 > maxH) maxH = endCh2;
      }
    }

    if (minH < maxH) {
      state = state.copyWith(startHour: minH, endHour: maxH);
    }
  }

  DateTime _parseDateTimeSicuro(String data, String orario) {
    try {
      final dStr = data.split('T')[0].split(' ')[0];
      final oStr = orario.contains(':') ? orario.substring(0, 5) : "00:00";
      return DateTime.parse('$dStr $oStr:00');
    } catch (e) {
      return DateTime.now();
    }
  }

  void filtraEConvertiDatiCalendario({String? idCampo}) {
    final campoId = idCampo ?? state.idCampoSelezionato;
    List<Appointment> tempAppointments = [];

    final partiteFiltrate = campoId == null
        ? state.datiPartiteRaw
        : state.datiPartiteRaw.where((p) => p['id_campo'] == campoId).toList();

    for (var p in partiteFiltrate) {
      try {
        final start = _parseDateTimeSicuro(
          p['data_partita'].toString(),
          p['orario_inizio'].toString(),
        );
        final end = _parseDateTimeSicuro(
          p['data_partita'].toString(),
          p['orario_fine'].toString(),
        );
        final String nomeCampo = p['campo']?['nome_campo'] ?? 'Campo';
        final String nomeOrg = p['organizzatore'] != null
            ? '${p['organizzatore']['nome']} ${p['organizzatore']['cognome']}'
            : 'Utente Sconosciuto';
        final String idPartita = p['id']?.toString() ?? '';
        tempAppointments.add(
          Appointment(
            id: idPartita,
            startTime: start,
            endTime: end,
            subject: '$nomeOrg\n⚽ $nomeCampo',
            color: AppTheme.neonOrange,
            isAllDay: false,
          ),
        );
      } catch (e) {}
    }

    for (var c in state.chiusureStraordinarie) {
      try {
        final start = _parseDateTimeSicuro(
          c['data_inizio'].toString(),
          c['orario_inizio'].toString(),
        );
        final end = _parseDateTimeSicuro(
          c['data_fine'].toString(),
          c['orario_fine'].toString(),
        );
        tempAppointments.add(
          Appointment(
            startTime: start,
            endTime: end,
            subject: '⛔ CHIUSO',
            color: Colors.red.shade900,
            isAllDay: false,
          ),
        );
      } catch (e) {}
    }

    final DateTime oggi = DateTime.now();
    for (int i = -30; i <= 30; i++) {
      final DateTime giornoCorrente = oggi.add(Duration(days: i));
      final int giornoSettimana = giornoCorrente.weekday;
      final orarioGiorno = state.orariSocieta.firstWhere(
        (o) => o['giorno_settimana'] == giornoSettimana,
        orElse: () => <String, dynamic>{},
      );
      if (orarioGiorno.isNotEmpty && orarioGiorno['is_chiuso'] == true) {
        tempAppointments.add(
          Appointment(
            startTime: DateTime(
              giornoCorrente.year,
              giornoCorrente.month,
              giornoCorrente.day,
              0,
              0,
            ),
            endTime: DateTime(
              giornoCorrente.year,
              giornoCorrente.month,
              giornoCorrente.day,
              23,
              59,
              59,
            ),
            subject: '⛔ GIORNO DI CHIUSURA',
            color: Colors.grey.shade900,
            isAllDay: false,
          ),
        );
      }
    }

    state = state.copyWith(
      prenotazioniVisibili: tempAppointments,
      idCampoSelezionato: campoId,
    );
  }

  void aggiornaDataCorrente(String data) {
    state = state.copyWith(stringaDataCorrente: data);
  }

  void avviaRealtimePartite({
    required String? idSocieta,
    required Utente? utenteLoggato,
  }) {
    _realtimeChannel = Supabase.instance.client
        .channel('partite_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'partite',
          callback: (payload) {
            debugPrint('Realtime: cambio rilevato nelle partite');
            inizializza(idSocieta: idSocieta, utenteLoggato: utenteLoggato);
          },
        )
        .subscribe();
  }

  void cancellaRealtime() {
    _realtimeChannel?.unsubscribe();
  }
}

// ===== PROVIDER =====
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);
