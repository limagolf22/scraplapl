import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:scraplapl/azba_utils.dart';
import 'package:scraplapl/kernel/azba/azba_zone.dart';
import 'package:polylabel/polylabel.dart';
import 'dart:math';

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

    var dateTimeNow = DateTime.now();

    List<Widget> widgets = [
      CustomPaint(
          painter: ContourPainter(franceContour),
          size: Size(MediaQuery.of(context).size.height * 0.707,
              MediaQuery.of(context).size.height))
    ];
    widgets.addAll(azbaZones
        .map((az) => CustomPaint(
            painter: PolygonPainter(az.type + ' ' + az.name, az.coordinates,
                az.isAzbaActive(dateTimeNow)),
            size: Size(MediaQuery.of(context).size.height * 0.707,
                MediaQuery.of(context).size.height)))
        .toList());
    return Scaffold(
      appBar: AppBar(
        title: Text('AZBA Map'),
      ),
      body: Stack(children: widgets),
    );
  }
}

class PolygonPainter extends CustomPainter {
  final String name;
  final List<LatLng> points;
  final bool isActive;

  PolygonPainter(this.name, this.points, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    var materialColor = (isActive ? Colors.red : Colors.blue);
    Paint paint = Paint()
      ..color = materialColor.withOpacity(0.4) // Couleur du polygone
      ..strokeWidth = 1 // Épaisseur de la bordure du polygone
      ..style = PaintingStyle.fill;
    Paint paintStroke = Paint()
      ..color = materialColor.withOpacity(0.8) // Couleur du polygone
      ..strokeWidth = 1 // Épaisseur de la bordure du polygone
      ..style = PaintingStyle.stroke;

    List<Offset> offsets = [];
    for (var point in points) {
      // Convertir les coordonnées géographiques en coordonnées de dessin
      offsets.add(Offset(
        (point.longitude + 5) * (size.width / 15),
        size.height - (point.latitude - 41) * (size.height / 11),
      ));
    }

    // Dessiner le polygone
    canvas.drawPath(Path()..addPolygon(offsets, true), paint);
    canvas.drawPath(Path()..addPolygon(offsets, true), paintStroke);
    var polylab = polylabel([offsets.map((o) => Point(o.dx, o.dy)).toList()]);

    TextPainter textPainterName = TextPainter(
        text: TextSpan(
            text: this.name,
            style:
                TextStyle(color: Color.fromRGBO(26, 26, 26, 1), fontSize: 12)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left);
    textPainterName.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainterName.paint(canvas,
        Offset(polylab.point.x as double, polylab.point.y - 5 as double));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ContourPainter extends CustomPainter {
  final List<LatLng> points;

  ContourPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color.fromARGB(255, 78, 78, 78)
          .withOpacity(0.3) // Couleur du polygone
      ..strokeWidth = 1 // Épaisseur de la bordure du polygone
      ..style = PaintingStyle.stroke;

    List<Offset> offsets = [];
    for (var point in points) {
      // Convertir les coordonnées géographiques en coordonnées de dessin
      offsets.add(Offset(
        (point.longitude + 5) * (size.width / 15),
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
