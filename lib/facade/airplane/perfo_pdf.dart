import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:scraplapl/facade/airplane/utils_pdf.dart';
import 'package:scraplapl/kernel/airplane/perfo.dart';
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:scraplapl/main.dart';
import 'package:scraplapl/tools.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> fileSavePerfoPDF(List<String> arpts) async {
  if (pdfDownloads['Perfo'] != null && pdfDownloads['Perfo']!.isNotEmpty) {
    var dir = await AppUtil.createFolderInAppDocDir('pdfs');
    final file = File("$dir/Perfo_${arpts[0]}-${arpts[1]}.pdf");
    await file.writeAsBytes(pdfDownloads['Perfo']!);
  }
}

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
                                  style: const pw.TextStyle(
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
  pdfDownloads['Perfo'] = await pdf.save();
}
