import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:scraplapl/tools.dart';

var loggerPdfNotam = Logger();

Future<void> fileSaveNotamPdf(String dep, String arr, Uint8List bytes) async {
  String dir = await AppUtil.createFolderInAppDocDir('pdfs');
  File file = File("$dir/NotamSofia_$dep-$arr.pdf");
  await file.writeAsBytes(bytes);
  loggerPdfNotam.i("Notam Sofia Pdf written");
}
