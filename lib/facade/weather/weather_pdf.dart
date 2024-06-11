import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:scraplapl/tools.dart';

var loggerPdfWeather = Logger();

Future<void> fileSaveWeatherPdf(String dep, String arr, Uint8List bytes) async {
  var dir = await AppUtil.createFolderInAppDocDir('pdfs');
  File file = File("$dir/MTO_$dep-$arr.pdf");
  await file.writeAsBytes(bytes);
  loggerPdfWeather.i("Weather Pdf written");
}
