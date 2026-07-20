import 'dart:math' as math;

import 'package:flutter/foundation.dart' show Factory;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_campi/core/theme/app_theme.dart';
import 'package:app_campi/features/admin/presentation/pages/lista_campi_screen.dart';
import 'package:app_campi/core/services/location_provider.dart';
import 'package:app_campi/core/shared_widget/gps_banner.dart';

class RadarMapScreen extends ConsumerStatefulWidget {
  const RadarMapScreen({super.key});

  @override
  ConsumerState<RadarMapScreen> createState() => _RadarMapScreenState();
}

class _RadarMapScreenState extends ConsumerState<RadarMapScreen>
    with WidgetsBindingObserver {
  GoogleMapController? mapController;
  bool _isMapReady = false;

  LatLng _currentPosition = const LatLng(41.9028, 12.4964);
  bool _isLoadingLocation = true;
  bool _permessoNegatoPerSempre = false;
  Set<Marker> _markers = {};

  Offset _circleCenterPx = Offset.zero;
  double _circleRadiusPx = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ottieniPosizioneAttuale();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _ottieniPosizioneAttuale();
    }
  }

  Future<void> _ottieniPosizioneAttuale() async {
    if (!mounted) return;

    bool serviceEnabled;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint("Errore controllo servizio GPS: $e");
      _disabilitaCaricamentoEApriMappa();
      return;
    }

    if (!serviceEnabled) {
      if (mounted) setState(() => _permessoNegatoPerSempre = false);
      _disabilitaCaricamentoEApriMappa();
      return;
    }

    LocationPermission permission;
    try {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    } catch (e) {
      debugPrint("Errore controllo permessi GPS: $e");
      _disabilitaCaricamentoEApriMappa();
      return;
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _permessoNegatoPerSempre =
              permission == LocationPermission.deniedForever;
        });
      }
      _disabilitaCaricamentoEApriMappa();
      return;
    }

    if (mounted) setState(() => _permessoNegatoPerSempre = false);

    try {
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint("Timeout GPS: fallback su ultima posizione nota.");
        try {
          position = await Geolocator.getLastKnownPosition();
        } catch (e2) {
          debugPrint("Errore ultima posizione nota: $e2");
          position = null;
        }
      }

      if (position != null && mounted) {
        setState(() {
          _currentPosition = LatLng(position!.latitude, position.longitude);
          _isLoadingLocation = false;
        });

        if (_isMapReady) {
          _spostaTelecameraEScarica();
        }
      } else {
        _disabilitaCaricamentoEApriMappa();
      }
    } catch (e) {
      debugPrint("Errore critico GPS: $e");
      _disabilitaCaricamentoEApriMappa();
    }
  }

  void _disabilitaCaricamentoEApriMappa() {
    if (mounted) {
      setState(() => _isLoadingLocation = false);
      if (_isMapReady) {
        _caricaCentriSportiviVicini();
      }
    }
  }

  void _spostaTelecameraEScarica() {
    if (!_isMapReady || mapController == null) return;
    mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 13.5),
    );
    _caricaCentriSportiviVicini();
  }

  void _centraSuDiMe() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);
    await _ottieniPosizioneAttuale();
  }

  Future<double> _calcolaRaggioCerchioInMetri() async {
    if (mapController == null || _circleRadiusPx <= 0) {
      return 1000;
    }
    try {
      final centroLatLng = await mapController!.getLatLng(
        ScreenCoordinate(
          x: _circleCenterPx.dx.round(),
          y: _circleCenterPx.dy.round(),
        ),
      );
      final bordoLatLng = await mapController!.getLatLng(
        ScreenCoordinate(
          x: _circleCenterPx.dx.round(),
          y: (_circleCenterPx.dy - _circleRadiusPx).round(),
        ),
      );
      return Geolocator.distanceBetween(
        centroLatLng.latitude,
        centroLatLng.longitude,
        bordoLatLng.latitude,
        bordoLatLng.longitude,
      );
    } catch (e) {
      debugPrint("Errore calcolo raggio cerchio: $e");
      return 1000;
    }
  }

  Future<void> _caricaCentriSportiviVicini() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);

    try {
      final raggioMetri = await _calcolaRaggioCerchioInMetri();
      final raggioKm = (raggioMetri / 1000.0).clamp(0.05, 50.0);

      final List<dynamic> data = await Supabase.instance.client.rpc(
        'get_centri_vicini',
        params: {
          'lat_utente': _currentPosition.latitude,
          'lon_utente': _currentPosition.longitude,
          'raggio_km': raggioKm,
        },
      );

      final Set<Marker> nuoviMarkers = {};
      for (final societa in data) {
        try {
          final lat = (societa['latitudine'] as num).toDouble();
          final lng = (societa['longitudine'] as num).toDouble();

          final distanzaCentro = Geolocator.distanceBetween(
            _currentPosition.latitude,
            _currentPosition.longitude,
            lat,
            lng,
          );
          if (distanzaCentro > raggioMetri) continue;

          nuoviMarkers.add(
            Marker(
              markerId: MarkerId(societa['id'].toString()),
              position: LatLng(lat, lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(100),
              onTap: () => _mostraDettaglioCentro(context, societa),
            ),
          );
        } catch (e) {
          debugPrint("Centro sportivo con dati non validi, salto: $e");
        }
      }

      if (mounted) {
        setState(() {
          _markers = nuoviMarkers;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint("Errore caricamento centri: $e");
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _forzaRicaricamento() async {
    if (!_isMapReady || mapController == null || !mounted) return;
    try {
      final size = MediaQuery.of(context).size;
      final centroMappa = await mapController!.getLatLng(
        ScreenCoordinate(
          x: (size.width / 2).round(),
          y: (size.height / 2).round(),
        ),
      );
      if (!mounted) return;
      setState(() => _currentPosition = centroMappa);
      await _caricaCentriSportiviVicini();
    } catch (e) {
      debugPrint("Errore ricaricamento manuale: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _isMapReady = true;

    if (!_isLoadingLocation) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _spostaTelecameraEScarica();
      });
    }
  }

  void _mostraDettaglioCentro(
    BuildContext context,
    Map<String, dynamic> societa,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stadium_rounded,
                      color: AppTheme.accent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      societa['nome_societa'] ?? "Centro Sportivo",
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      societa['indirizzo'] ?? "Indirizzo non disponibile",
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListaCampiScreen(societa: societa),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.darkBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                    "ESPLORA QUESTO CENTRO",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(gpsAttivoProvider, (previous, next) {
      final eraSpento = previous?.value == false;
      final oraAcceso = next.value == true;
      if (oraAcceso && eraSpento && mounted) {
        setState(() => _isLoadingLocation = true);
        _ottieniPosizioneAttuale();
      }
    });

    final gpsAttivo = ref.watch(gpsAttivoProvider).value ?? false;
    final mostraLocalizzazioneUtente = gpsAttivo && !_permessoNegatoPerSempre;

    final size = MediaQuery.of(context).size;
    final circleRadius = math.min(size.width, size.height) * 0.34;
    final center = Offset(size.width / 2, size.height / 2);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 12.0,
              ),
              markers: _markers,
              myLocationEnabled: mostraLocalizzazioneUtente,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              onCameraIdle: () async {
                if (!_isMapReady || mapController == null || !mounted) return;
                try {
                  final centroMappa = await mapController!.getLatLng(
                    ScreenCoordinate(
                      x: center.dx.round(),
                      y: center.dy.round(),
                    ),
                  );
                  if (!mounted) return;
                  setState(() => _currentPosition = centroMappa);
                  _caricaCentriSportiviVicini();
                } catch (e) {
                  debugPrint("Errore lettura centro mappa: $e");
                }
              },
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: ClipPath(
                clipper: _HoleClipper(center: center, radius: circleRadius),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.1,
                      colors: [
                        AppTheme.darkBg.withOpacity(0.55),
                        AppTheme.darkBg.withOpacity(0.72),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _RingPainter(
                  center: center,
                  radius: circleRadius,
                  color: AppTheme.accent,
                ),
              ),
            ),
          ),

          Positioned(
            left: center.dx - 16,
            top: center.dy - 34,
            child: const IgnorePointer(
              child: Icon(
                Icons.location_on_rounded,
                color: AppTheme.accent,
                size: 34,
                shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
              ),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 12,
                      bottom: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "RADAR CENTRI",
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

                  if (!gpsAttivo || _permessoNegatoPerSempre)
                    GpsBanner(
                      permessoNegatoPerSempre: _permessoNegatoPerSempre,
                    ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isLoadingLocation
                              ? "Scansione radar in corso..."
                              : "${_markers.length} Centri rilevati in quest'area",
                          style: TextStyle(
                            color: _isLoadingLocation
                                ? AppTheme.accent
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _isLoadingLocation
                                ? null
                                : _forzaRicaricamento,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.cardBg,
                              foregroundColor: AppTheme.accent,
                              side: BorderSide(
                                color: AppTheme.accent.withOpacity(0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: _isLoadingLocation
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.accent,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Icon(Icons.radar_rounded),
                            label: const Text(
                              "SCANSIONA L'AREA",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (gpsAttivo)
            Positioned(
              right: 20,
              bottom: 160,
              child: SafeArea(
                child: GestureDetector(
                  onTap: _centraSuDiMe,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accent.withOpacity(0.5),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: AppTheme.accent,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HoleClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _HoleClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    return Path.combine(PathOperation.difference, full, hole);
  }

  @override
  bool shouldReclip(covariant _HoleClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius;
  }
}

class _RingPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  _RingPainter({
    required this.center,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius, glow);

    final ring = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, ring);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.color != color;
  }
}
