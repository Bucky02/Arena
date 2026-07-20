import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_campi/core/repositories/partita_repository.dart';
import 'package:app_campi/core/theme/app_constants.dart';

final gpsAttivoProvider = StreamProvider<bool>((ref) async* {
  try {
    yield await Geolocator.isLocationServiceEnabled();
  } catch (e) {
    yield false;
  }

  try {
    await for (var status in Geolocator.getServiceStatusStream()) {
      yield status == ServiceStatus.enabled;
    }
  } catch (e) {
    // Se lo stream nativo fallisce (es. piattaforma non supportata)
    // resta semplicemente sull'ultimo valore noto, senza crashare.
  }
});

final posizioneAttualeProvider = FutureProvider<Position?>((ref) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  } catch (e) {
    return null;
  }
});

final matchInZonaProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final gpsAttivo = ref.watch(gpsAttivoProvider).value ?? false;

  if (!gpsAttivo) {
    throw Exception('GPS_SPENTO');
  }

  final posizione = await ref.watch(posizioneAttualeProvider.future);

  if (posizione == null) {
    return [];
  }

  final repository = PartitaRepository();

  try {
    final datiGrezzi = await repository.getMatchPubbliciApertiGeolocalizzati(
      latUtente: posizione.latitude,
      lonUtente: posizione.longitude,
      raggioKm: MatchThresholds.distanzaEstesa,
    );

    return datiGrezzi;
  } catch (e) {
    return [];
  }
});
