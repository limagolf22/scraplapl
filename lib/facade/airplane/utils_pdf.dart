import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
