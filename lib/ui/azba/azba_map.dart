import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:logger/logger.dart';
import 'package:scraplapl/kernel/azba/azba_coord.dart';
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:scraplapl/ui/azba/azba_utils.dart';
import 'package:polylabel/polylabel.dart';
import 'dart:math';

const lat45Coef = 0.707;

class AzbaMapWidget extends StatefulWidget {
  final DateTime dateTime;

  const AzbaMapWidget(this.dateTime, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _AzbaMapWidgetState();
  }
}

class _AzbaMapWidgetState extends State<AzbaMapWidget> {
  var azbaMapLogger = Logger();

  @override
  Widget build(BuildContext context) {
    var parentSize = MediaQuery.of(context).size;

    var widthSize = min(parentSize.height * lat45Coef, parentSize.width);

    return Stack(
        children: [
      CustomPaint(
          painter: ContourPainter(franceContour),
          size: Size(widthSize * 0.99, widthSize / lat45Coef * 0.99))
    ]
            .followedBy((azbaZones.map((az) => CustomPaint(
                painter: PolygonPainter('${az.type} ${az.name}', az.coordinates,
                    az.isAzbaActive(widget.dateTime)),
                size: Size(widthSize * 0.99, widthSize / lat45Coef * 0.99)))))
            .toList());
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
      ..color = materialColor.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    Paint paintStroke = Paint()
      ..color = materialColor.withOpacity(0.8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    List<Offset> offsets = [];
    for (var point in points) {
      var pt = latLngToPixPoint(point, size.width, size.height);
      offsets.add(Offset(pt.x, pt.y));
    }

    // Dessiner le polygone
    canvas.drawPath(Path()..addPolygon(offsets, true), paint);
    canvas.drawPath(Path()..addPolygon(offsets, true), paintStroke);
    var polylab = polylabel([offsets.map((o) => Point(o.dx, o.dy)).toList()]);

    TextPainter textPainterName = TextPainter(
        text: TextSpan(
            text: name,
            style: const TextStyle(
                color: Color.fromRGBO(26, 26, 26, 1), fontSize: 12)),
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
  bool shouldRepaint(PolygonPainter oldDelegate) {
    return isActive != oldDelegate.isActive;
  }
}

class ContourPainter extends CustomPainter {
  final List<LatLng> points;

  ContourPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 78, 78, 78).withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    List<Offset> offsets = [];
    for (var point in points) {
      var pt = latLngToPixPoint(point, size.width, size.height);
      offsets.add(Offset(pt.x, pt.y));
    }

    canvas.drawPath(Path()..addPolygon(offsets, true), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
