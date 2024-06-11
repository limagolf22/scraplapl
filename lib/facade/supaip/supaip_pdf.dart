import 'dart:io';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:requests/requests.dart';
import 'package:scraplapl/facade/supaip/supaip_parsing.dart';
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:scraplapl/kernel/supaip/supaip_model.dart';
import 'package:scraplapl/tools.dart';

import 'package:http/http.dart' as http;

var loggerSupAipPdf = Logger();

Future<int> downloadSupAipPdfs(List<SupAip> supaips) async {
  if (supaips.isEmpty) {
    return 0;
  }
  return (await Future.wait(supaips
          .map((sa) => http
              .get(Uri.parse(sa.link))
              .then((res) => downloadSupAipPdf(res, adaptSupAipId(sa))))
          .toList()))
      .reduce((a, b) => a + b);
}

Future<void> fileSaveSupAipPdfs() async {
  for (var entry in pdfDownloadsSupAip.entries) {
    fileSaveSupAipPdf(entry.key, entry.value);
  }
}

Future<int> fileSaveSupAipPdf(String id, Uint8List pdfBytes) async {
  String dir = await AppUtil.createFolderInAppDocDir('pdfs');
  File file = File("$dir/SupAip_$id.pdf");
  if (file.existsSync()) {
    loggerSupAipPdf.i("Sup Aip $id file already saved");
    return 0;
  }
  if (pdfBytes.isNotEmpty) {
    await file.writeAsBytes(pdfDownloadsSupAip[id]!);
    loggerSupAipPdf.i("Sup Aip $id Pdf file written");
    return 0;
  } else {
    loggerSupAipPdf.w("Failed to get Sup Aip $id bytes (empty)");
    return 1;
  }
}

Future<int> downloadSupAipPdf(http.Response res, String id) async {
  if (pdfDownloadsSupAip.containsKey(id)) {
    loggerSupAipPdf.i("Sup Aip $id already downloaded");
    return 0;
  }
  if (res.success) {
    pdfDownloadsSupAip[id] = res.bodyBytes;
    loggerSupAipPdf.i("Sup Aip $id Pdf saved");
    return 0;
  } else {
    loggerSupAipPdf.w("Failed to get Sup Aip $id");
    return 1;
  }
}
