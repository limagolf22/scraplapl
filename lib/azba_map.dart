import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:scraplapl/kernel/azba/azba_zone.dart';

List<AzbaZone> azbaZones = [];

class AzbaMapWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AzbaMapWidgetState();
  }
}

class _AzbaMapWidgetState extends State<AzbaMapWidget> {
  @override
  Widget build(BuildContext context) {
    List<LatLng> polygonPoints = [
      LatLng(51.5, -0.09),
      LatLng(48.8566, 2.3522),
      LatLng(21.3851, 2.1734),
      LatLng(51.5, -39.09), // Fermeture du polygone
    ];

    List<LatLng> polygonPoints2 = [
      LatLng(31.5, -0.09),
      LatLng(28.8566, 2.3522),
      LatLng(1.3851, 2.1734),
      LatLng(31.5, -39.09), // Fermeture du polygone
    ];

    List<Widget> widgets = azbaZones
        .map((az) => CustomPaint(
            painter: PolygonPainter(az.coordinates),
            size: Size(MediaQuery.of(context).size.height * 0.707,
                MediaQuery.of(context).size.height)))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('AZBA Map'),
      ),
      body: Stack(children: widgets),
    );
  }
}

class PolygonPainter extends CustomPainter {
  final List<LatLng> points;

  PolygonPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red.withOpacity(0.5) // Couleur du polygone
      ..strokeWidth = 2 // Épaisseur de la bordure du polygone
      ..style = PaintingStyle.fill;

    List<Offset> offsets = [];
    for (var point in points) {
      // Convertir les coordonnées géographiques en coordonnées de dessin
      offsets.add(Offset(
        (point.longitude + 2) * (size.width / 12),
        size.height - (point.latitude - 41) * (size.height / 11),
      ));
    }

    // Dessiner le polygone
    canvas.drawPath(Path()..addPolygon(offsets, true), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
