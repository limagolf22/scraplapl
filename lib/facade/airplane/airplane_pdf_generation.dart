import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:scraplapl/ui/fuel/fuel_page.dart';
import 'package:scraplapl/main.dart';
import 'package:scraplapl/tools.dart';
import 'package:scraplapl/ui/perfo/perfo_page.dart';

createPerfoPDF(List<String> arpts) async {
  final pdf = pw.Document();

  pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(children: [
          pw.Table(
              children: [
                    pw.TableRow(
                      children: (["OACI"] +
                                  headerPerfsInputs +
                                  headerPerfsOutputs)
                              .map((col) {
                            return addPadding(pw.Text(
                              col,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  background: pw.BoxDecoration(
                                      color: getBackColor(col))),
                            ));
                          }).toList() +
                          [
                            addPadding(pw.Text(
                              "check",
                              textAlign: pw.TextAlign.center,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ))
                          ],
                    )
                  ] +
                  [0, 1, 2, 3].map((row) {
                    return pw.TableRow(
                        children: [addPadding(pw.Text(airportsPerfs[row]))] +
                            headerPerfsInputs.map((col) {
                              return addPadding(pw.Text(
                                  perfsInputs[row][col].toString(),
                                  textAlign: pw.TextAlign.center,
                                  maxLines: 1,
                                  style: pw.TextStyle(
                                      background: pw.BoxDecoration(
                                          color: PdfColors.white))));
                            }).toList() +
                            headerPerfsOutputs.map((col) {
                              return addPadding(pw.Text(
                                  perfsResults[row][col].toString(),
                                  textAlign: pw.TextAlign.center,
                                  maxLines: 1,
                                  style: pw.TextStyle(
                                      background: pw.BoxDecoration(
                                          color: getBackColor(col)))));
                            }).toList() +
                            [
                              addPadding(airportsPerfs[row] != ""
                                  ? pw.Text("V")
                                  : pw.Text(""))
                            ]);
                  }).toList(),
              border: (pw.TableBorder.all())),
          File('data/flutter_assets/assets/images/perfoTab-$chosenAircraft.png')
                  .existsSync()
              ? addPadding(pw.Image(pw.MemoryImage(
                  File('data/flutter_assets/assets/images/perfoTab-$chosenAircraft.png')
                      .readAsBytesSync(),
                )))
              : pw.Text('no image found')
        ]);
        // Center
      })); // Page
  var dir = await AppUtil.createFolderInAppDocDir('pdfs');
  final file = File("$dir/Perfo_${arpts[0]}-${arpts[1]}.pdf");
  await file.writeAsBytes(await pdf.save());
}

pw.Widget addPadding(pw.Widget el) {
  return pw.Padding(padding: const pw.EdgeInsets.all(4.0), child: el);
}

PdfColor getBackColor(String col) {
  switch (col) {
    case "TOD":
      return PdfColors.blue100;
    case "TODA":
      return PdfColors.cyan100;
    case "LD":
      return PdfColors.green100;
    case "LDA":
      return PdfColors.lightGreen100;
    default:
      return PdfColors.white;
  }
}

createConsoPDF(List<String> arpts) async {
  final pdf = pw.Document();

  pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(children: [
          pw.Table(
              border: pw.TableBorder.all(),
              children: headersConso
                      .map((h) => pw.TableRow(children: [
                            addPadding(pw.Text(
                              h,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            )),
                            addPadding(pw.Text(
                              consoContent[h].toString(),
                              maxLines: 1,
                              style: pw.TextStyle(fontSize: 10),
                            ))
                          ]))
                      .toList() +
                  [
                    pw.TableRow(children: [
                      addPadding(pw.Text(
                        "total",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      )),
                      addPadding(pw.Text(
                          "${consoContent.values.reduce((a, b) => (a + b)).toString()} min\n${((consoContent.values.reduce((a, b) => (a + b)) * getFuelConso() / 60).floor() + 1).toString()} L",
                          textAlign: pw.TextAlign.center,
                          maxLines: 2,
                          style: const pw.TextStyle(
                              fontSize: 10,
                              background:
                                  pw.BoxDecoration(color: PdfColors.yellow))))
                    ])
                  ]),
        ]);
        // Center
      })); // Page
  var dir = await AppUtil.createFolderInAppDocDir('pdfs');
  final file = File("$dir/Conso_${arpts[0]}-${arpts[1]}.pdf");
  await file.writeAsBytes(await pdf.save());
}

int getFuelConso() {
  switch (chosenAircraft) {
    case "DR400-120":
      return 25;
    case "DR400-140B":
      return 35;
    case "TB10":
      return 40;
    default:
      return 0;
  }
}
