import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:scraplapl/facade/airplane/utils_pdf.dart';
import 'package:scraplapl/kernel/airplane/fuel.dart';
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:scraplapl/main.dart';
import 'package:scraplapl/tools.dart';

Future<void> fileSaveConsoPDF(List<String> arpts) async {
  if (pdfDownloads['Conso'] != null && pdfDownloads['Conso']!.isNotEmpty) {
    var dir = await AppUtil.createFolderInAppDocDir('pdfs');
    final file = File("$dir/Conso_${arpts[0]}-${arpts[1]}.pdf");
    await file.writeAsBytes(pdfDownloads['Conso']!);
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
                              style: const pw.TextStyle(fontSize: 10),
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

  pdfDownloads['Conso'] = await pdf.save();
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
