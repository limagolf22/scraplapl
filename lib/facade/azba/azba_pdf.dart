import 'dart:io';
import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:scraplapl/kernel/azba/azba_coord.dart';
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
            az.isAzbaActive(activationsTimes[i])))
        .toList());
    widgets[i].addAll(azbaZones
        .where((az) => az.isAzbaActive(activationsTimes[i]))
        .map((az) => generateAzbaAsPolygon(
            az.coordinates
                .map((pt) => latLngToPixPoint(pt, 500.0, 500.0 / 0.707))
                .toList(),
            az.isAzbaActive(activationsTimes[i])))
        .toList());

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

pw.Widget addPadding(pw.Widget el) {
  return pw.Padding(padding: const pw.EdgeInsets.all(4.0), child: el);
}

pw.Widget generateFranceContour(List<Point<double>> points) {
  return pw.Polygon(
      points: points.map((pt) => PdfPoint(pt.x, pt.y)).toList(),
      strokeWidth: 1.0,
      strokeColor: PdfColors.grey);
}

pw.Widget generateAzbaAsPolygon(List<Point<double>> points, bool isActive) {
  return isActive
      ? pw.Polygon(
          points: points.map((pt) => PdfPoint(pt.x, pt.y)).toList(),
          strokeWidth: 2.0,
          strokeColor: PdfColors.red800,
          fillColor: PdfColors.red)
      : pw.Polygon(
          points: points.map((pt) => PdfPoint(pt.x, pt.y)).toList(),
          strokeWidth: 1.0,
          strokeColor: PdfColor(0, 0, 1, 0.6));
}
