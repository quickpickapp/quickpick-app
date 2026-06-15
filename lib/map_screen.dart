import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────
class Person {
  final String name;
  final LatLng position;

  const Person({required this.name, required this.position});

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  String get firstName => name.split(' ').first;
}

const List<Person> _people = [
  Person(name: 'Alice Smith', position: LatLng(50.7342, 7.0992)),
  Person(name: 'Bob Johnson', position: LatLng(50.9333, 6.9500)),
  Person(name: 'Carol White', position: LatLng(50.7500, 7.1500)),
  Person(name: 'Dan Brown', position: LatLng(50.6900, 7.1300)),
];

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Person? _selectedPerson;
  Set<Marker> _markers = {};

  CameraPosition _currentCamera = _initialPosition;
  final Map<String, Offset> _screenPositions = {};

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(50.7342, 7.0992),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildMarkers());
  }

  // ─── Bitmap rendering ────────────────────────────────────────────────────

  Future<void> _buildMarkers() async {
    final Set<Marker> markers = {};
    for (final person in _people) {
      final result = await _createBubbleBitmap(
        person.initials,
        person.firstName,
        isSelected: _selectedPerson?.name == person.name,
      );
      final isSelected = _selectedPerson?.name == person.name;
      markers.add(Marker(
        markerId: MarkerId(person.name),
        position: person.position,
        icon: result,
        anchor: const Offset(0.5, 1.0),
        onTap: () => _onPersonTap(person),
      ));
    }
    if (mounted) {
      setState(() => _markers = markers);
      _updateProjections();
    }
  }

  Future<BitmapDescriptor> _createBubbleBitmap(
    String initials,
    String label, {
    bool isSelected = false,
  }) async {
    const double scale = 3.0;
    const double avatarD = 32.0;
    const double hPad = 10.0;
    const double gap = 7.0;
    const double vPad = 9.0;
    const double cornerR = 16.0;
    const double tipW = 14.0;
    const double tipH = 10.0;

    // Measure name
    final namePara = _buildPara(label, 13.0,
        bold: true, color: isSelected ? Colors.white : const Color(0xFF1A1A2E));
    namePara.layout(const ui.ParagraphConstraints(width: 200));
    final nameW = namePara.longestLine.ceilToDouble();
    final nameH = namePara.height;

    final double bubbleW = hPad + avatarD + gap + nameW + hPad;
    final double bubbleH = vPad + avatarD + vPad;
    final double totalH = bubbleH + tipH;

    final int pw = (bubbleW * scale).ceil();
    final int ph = (totalH * scale).ceil();

    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromLTWH(0, 0, pw.toDouble(), ph.toDouble()));
    canvas.scale(scale, scale);

    // Shadow
    canvas.drawPath(
      _bubblePath(bubbleW, bubbleH, cornerR, tipW, tipH, oy: 2.5),
      Paint()
        ..color = Colors.black.withOpacity(0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Background
    canvas.drawPath(
      _bubblePath(bubbleW, bubbleH, cornerR, tipW, tipH),
      Paint()..color = isSelected ? Colors.indigo : Colors.white,
    );

    // Border
    canvas.drawPath(
      _bubblePath(bubbleW, bubbleH, cornerR, tipW, tipH),
      Paint()
        ..color = isSelected
            ? Colors.white.withOpacity(0.3)
            : Colors.indigo.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Avatar circle
    final double ax = hPad + avatarD / 2;
    final double ay = bubbleH / 2;
    canvas.drawCircle(
      Offset(ax, ay),
      avatarD / 2,
      Paint()
        ..color = isSelected ? Colors.white.withOpacity(0.22) : Colors.indigo,
    );

    // Initials
    final ip = _buildPara(initials, 11.0, bold: true, color: Colors.white);
    ip.layout(const ui.ParagraphConstraints(width: 200));
    canvas.drawParagraph(
        ip, Offset(ax - ip.longestLine / 2, ay - ip.height / 2));

    // Name
    canvas.drawParagraph(
        namePara, Offset(hPad + avatarD + gap, bubbleH / 2 - nameH / 2));

    final picture = recorder.endRecording();
    final image = await picture.toImage(pw, ph);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final bmp = BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
    return bmp;
  }

  ui.Paragraph _buildPara(String text, double size,
      {required bool bold, required Color color}) {
    return (ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontFamily: 'Roboto',
    ))
          ..pushStyle(ui.TextStyle(
            color: color,
            fontSize: size,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 0.2,
          ))
          ..addText(text))
        .build();
  }

  Path _bubblePath(double w, double h, double r, double tipW, double tipH,
      {double oy = 0}) {
    return Path()
      ..moveTo(r, oy)
      ..lineTo(w - r, oy)
      ..arcToPoint(Offset(w, r + oy),
          radius: Radius.circular(r), clockwise: true)
      ..lineTo(w, h - r + oy)
      ..arcToPoint(Offset(w - r, h + oy),
          radius: Radius.circular(r), clockwise: true)
      ..lineTo(w / 2 + tipW / 2, h + oy)
      ..lineTo(w / 2, h + tipH + oy)
      ..lineTo(w / 2 - tipW / 2, h + oy)
      ..lineTo(r, h + oy)
      ..arcToPoint(Offset(0, h - r + oy),
          radius: Radius.circular(r), clockwise: true)
      ..lineTo(0, r + oy)
      ..arcToPoint(Offset(r, oy), radius: Radius.circular(r), clockwise: true)
      ..close();
  }

  // ─── Projection ──────────────────────────────────────────────────────────

  Offset _project(LatLng point, Size screen) {
    double mercY(double lat) => log(tan(pi / 4 + lat * pi / 180 / 2));
    final s = 256.0 * pow(2.0, _currentCamera.zoom) / (2 * pi);
    final dx =
        (point.longitude - _currentCamera.target.longitude) * pi / 180 * s;
    final dy =
        (mercY(_currentCamera.target.latitude) - mercY(point.latitude)) * s;
    return Offset(screen.width / 2 + dx, screen.height / 2 + dy);
  }

  void _updateProjections() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    setState(() {
      for (final p in _people) {
        _screenPositions[p.name] = _project(p.position, size);
      }
    });
  }

  void _onCameraMove(CameraPosition pos) {
    _currentCamera = pos;
    _updateProjections();
  }

  // ─── Interaction ─────────────────────────────────────────────────────────

  void _onPersonTap(Person person) {
    setState(() => _selectedPerson = person);
    _mapController
        ?.animateCamera(CameraUpdate.newLatLngZoom(person.position, 14));
    _buildMarkers();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final size = MediaQuery.of(context).size;
    // Safe area for bubble clamping: top = below strip, bottom = above info card gap
    final double safeTop = padding.top + 80.0;
    final double safeBottom = padding.bottom + 40.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // ── Map (native markers, zero Flutter overlay lag) ──
          GoogleMap(
            onMapCreated: (c) {
              _mapController = c;
              _buildMarkers();
              Future.delayed(
                  const Duration(milliseconds: 300), _updateProjections);
            },
            initialCameraPosition: _initialPosition,
            mapType: MapType.hybrid,
            markers: _markers,
            onCameraMove: _onCameraMove,
            onCameraIdle: _updateProjections,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // ── Edge avatar circles ───────────────────────
          // Shown only when the native marker is truly off-screen.
          // The circle is always fully visible; a white radial gradient
          // on the screen edge gives the smooth "melting into the border" feel.
          ..._people.map((person) {
            final pos = _screenPositions[person.name];
            if (pos == null) return const SizedBox.shrink();

            const r = 30.0; // avatar radius (logical px)

            // Hide while the marker is still on-screen
            final offScreen = pos.dx < -r ||
                pos.dx > size.width + r ||
                pos.dy < -r ||
                pos.dy > size.height + r;
            if (!offScreen) return const SizedBox.shrink();

            final bool leftSide = pos.dx < size.width / 2;

            final cx = leftSide ? r : size.width - r;
            final cy = pos.dy.clamp(safeTop + r, size.height - safeBottom - r);

            final isSelected = _selectedPerson?.name == person.name;

            return Positioned(
              left: cx - r,
              top: cy - r,
              width: r * 2,
              height: r * 2,
              child: GestureDetector(
                onTap: () => _onPersonTap(person),
                child: Container(
                  width: r * 2,
                  height: r * 2,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                      if (isSelected)
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.45),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Transform.rotate(
                        angle: leftSide ? 0 : math.pi,
                        child: SvgPicture.asset(
                          'assets/images/marker.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: leftSide ? 5 : 25,
                            right: leftSide ? 25 : 5,
                          ),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Colors.indigo,
                          ),
                          child: Center(
                            child: Text(
                              person.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),

          // ── Top gradient ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: padding.top + 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── App bar ──
          Positioned(
            top: padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _people.map((p) {
                        final isSel = _selectedPerson?.name == p.name;
                        return GestureDetector(
                          onTap: () => _onPersonTap(p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? Colors.indigo
                                  : Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSel ? Colors.white : Colors.white30,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              p.firstName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                        _initialPosition.target, _initialPosition.zoom),
                  ),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.my_location,
                        color: Colors.white, size: 17),
                  ),
                ),
              ],
            ),
          ),

          // ── Info card ──
          if (_selectedPerson != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _InfoCard(
                person: _selectedPerson!,
                onClose: () {
                  setState(() => _selectedPerson = null);
                  _buildMarkers();
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Info card
// ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.person, required this.onClose});

  final Person person;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(18),
      shadowColor: Colors.black38,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigo,
              ),
              child: Center(
                child: Text(
                  person.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                person.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.grey[400],
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
