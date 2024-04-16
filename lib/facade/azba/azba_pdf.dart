import 'dart:io';
import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:polylabel/polylabel.dart';
import 'package:scraplapl/kernel/azba/azba_coord.dart';
import 'package:scraplapl/kernel/azba/azba_zone.dart';
import 'package:scraplapl/tools.dart';

import '../../ui/azba/azba_map.dart';
import '../../ui/azba/azba_utils.dart';

createAzbaPDF(String dep, String arr) async {
  final pdf = pw.Document();

  pw.Widget widgetContour = generateFranceContour(franceContour
      .map((pt) => latLngToPixPoint(pt, 500.0, 500.0 / 0.707))
      .toList());

  List<List<pw.Widget>> widgets =
      activationsTimes.map((_) => [widgetContour]).toList();

  for (var i = 0; i < activationsTimes.length; i++) {
    widgets[i].addAll(azbaZones
        .where((az) => !az.isAzbaActive(activationsTimes[i]))
        .map((az) => generateAzbaAsPolygon(
            az.coordinates
                .map((pt) => latLngToPixPoint(pt, 500.0, 500.0 / 0.707))
                .toList(),
            false)));

    widgets[i].addAll(azbaZones
        .where((az) => az.isAzbaActive(activationsTimes[i]))
        .map((az) => generateAzbaAsPolygon(
            az.coordinates
                .map((pt) => latLngToPixPoint(pt, 500.0, 500.0 / 0.707))
                .toList(),
            true)));

    //Map<String, Point<num>> nameZones = Map<String, Point<num>>.fromIterable(
    //    azbaZones.where((az) => az.isAzbaActive(activationsTimes[i])),
    //    key: (az) => (az as AzbaZone).type + ' ' + (az as AzbaZone).name,
    //    value: (d) => getCenterInPolygon(d as AzbaZone));

    var splitAzbas = azbaZones
        .where((az) => az.isAzbaActive(activationsTimes[i]))
        .map((az) => MapEntry(az.type + ' ' + az.name, getCenterInPolygon(az)))
        .toList();
    splitAzbas
        .sort((a, b) => (a.value.y as double) > (b.value.y as double) ? 1 : -1);
    for (var i = 0; i < splitAzbas.length; i++) {
      for (var j = i + 1; j < splitAzbas.length; j++) {
        if (splitAzbas[i].value.y + 4 > splitAzbas[j].value.y) {
          if (i > 0 && splitAzbas[i - 1].value.y + 4 < splitAzbas[i].value.y) {
            splitAzbas[i] = MapEntry(splitAzbas[i].key,
                Point(splitAzbas[i].value.x, splitAzbas[j].value.y - 4));
          } else {
            splitAzbas[j] = MapEntry(splitAzbas[j].key,
                Point(splitAzbas[j].value.x, splitAzbas[i].value.y + 4));
          }
        }
      }
    }

    widgets[i].addAll(splitAzbas.map((m) => generateAzbaName(m.key, m.value)));

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.SizedBox(
                child: pw.Stack(children: widgets[i]),
                width: 501,
                height: 501.0 / 0.707),
            pw.Text(activationsTimes[i].toString())
          ]);
        })); // Page
  }

  var dir = await AppUtil.createFolderInAppDocDir('pdfs');
  final file = File("$dir/Azba_${dep}-${arr}.pdf");
  await file.writeAsBytes(await pdf.save());
}

Point<num> getCenterInPolygon(AzbaZone azbaZone) {
  return polylabel([
    azbaZone.coordinates
        .map((pt) => latLngToPixPoint(pt, 500.0, 500.0 / 0.707))
        .toList()
  ]).point;
}

pw.Widget addPadding(pw.Widget el) {
  return pw.Padding(padding: const pw.EdgeInsets.all(4.0), child: el);
}

pw.Widget generateFranceContour(List<Point<double>> points) {
  return pw.Polygon(
      points: points.map((pt) => PdfPoint(pt.x, pt.y)).toList(),
      strokeWidth: 1.5,
      strokeColor: PdfColors.grey300);
}

pw.Widget generateAzbaAsPolygon(List<Point<double>> points, bool isActive) {
  return isActive
      ? pw.Polygon(
          points: points.map((pt) => PdfPoint(pt.x, pt.y)).toList(),
          strokeWidth: 1.0,
          strokeColor: PdfColors.red200,
          fillColor: PdfColors.red100)
      : pw.Polygon(
          points: points.map((pt) => PdfPoint(pt.x, pt.y)).toList(),
          strokeWidth: 0.5,
          strokeColor: PdfColors.blue200);
}

pw.Widget generateAzbaName(String name, Point<num> point) {
  return pw.Container(
    child:
        pw.Text(name, style: pw.TextStyle(color: PdfColors.black, fontSize: 5)),
    margin: pw.EdgeInsetsDirectional.only(
        start: point.x as double, top: point.y as double),
    height: 10.0,
  );
}
